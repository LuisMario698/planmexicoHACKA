import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/polos_data.dart';

class MexicoMapWidget extends StatefulWidget {
  final Function(String stateCode, String stateName)? onStateSelected;
  final Function(PoloInfo polo)? onPoloSelected;
  final Function(String? stateName)? onStateHover;
  final String? selectedStateCode;
  final String? selectedPoloId; // ID del polo seleccionado para resaltarlo
  final VoidCallback? onBackToMap;
  final List<String>? highlightedStates;
  final bool autoShowDetail; // Si es false, no muestra detalle al hacer tap
  final double zoomScale; // Escala actual del zoom para ajustar tooltips
  final bool showOnlySelected; // Si es true, solo muestra el estado seleccionado (para mini preview)
  final bool hidePoloMarkers; // Si es true, no muestra los markers de polos
  final bool skipInitialAnimation; // Si es true, no ejecuta la animación al mostrar el estado

  const MexicoMapWidget({
    super.key,
    this.onStateSelected,
    this.onPoloSelected,
    this.onStateHover,
    this.selectedStateCode,
    this.selectedPoloId,
    this.onBackToMap,
    this.highlightedStates,
    this.autoShowDetail = true,
    this.zoomScale = 1.0,
    this.showOnlySelected = false,
    this.hidePoloMarkers = false,
    this.skipInitialAnimation = false,
  });

  @override
  State<MexicoMapWidget> createState() => _MexicoMapWidgetState();
}

// Clase para información del polo
class PoloInfo {
  final String id;
  final String nombre;
  final String estado;
  final String descripcion;
  final String tipo; // 'nuevo', 'en_marcha', 'en_proceso', etc.
  final List<String> imagenes;
  final String ubicacion;
  final double latitud;
  final double longitud;

  PoloInfo({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.descripcion,
    required this.tipo,
    required this.imagenes,
    required this.ubicacion,
    required this.latitud,
    required this.longitud,
  });
}

class _MexicoMapWidgetState extends State<MexicoMapWidget>
    with TickerProviderStateMixin {
  List<MexicoState> _states = [];
  bool _isLoading = true;
  String? _hoveredStateCode;
  Offset? _hoverPosition;
  bool _showStateDetail = false;
  MexicoState? _detailState;

  // Animaciones
  late AnimationController _hoverController;
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;
  late Animation<double> _elevationAnimation;

  // Zoom interactivo
  final TransformationController _transformationController = TransformationController();
  double _currentZoom = 1.0;
  static const double _minZoom = 1.0;
  static const double _maxZoom = 4.0;

  // Control de gestos para evitar selección accidental durante zoom/pan
  bool _isInteracting = false;
  Offset? _interactionStartPosition;
  DateTime? _interactionStartTime;
  int _interactionPointerCount = 0;

  // Bounds para normalizar las coordenadas
  double _minX = double.infinity;
  double _maxX = double.negativeInfinity;
  double _minY = double.infinity;
  double _maxY = double.negativeInfinity;

  // Para animación de hover por estado
  final Map<String, AnimationController> _stateHoverControllers = {};
  final Map<String, Animation<double>> _stateHoverAnimations = {};

  // Mapa de polos por estado
  final Map<String, String> _poloCounts = {
    'Sonora': '2',
    'Tamaulipas': '2',
    'Coahuila': '2',
    'Durango': '1',
    'Yucatán': '1',
    'Puebla': '1',
    'Guanajuato': '1',
    'Estado de México': '1',
    'Distrito Federal': '1', // CDMX en el GeoJSON suele ser Distrito Federal
    'Ciudad de México': '1', // Por si acaso
    'Nuevo León': '1',
    'Oaxaca': '1',
    'Veracruz': '1',
    'Tabasco': '1 (asociado)',
    'Campeche': '1 (asociado)',
  };

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutBack,
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeOutCubic),
    );

    _loadGeoJson();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _selectionController.dispose();
    _transformationController.dispose();
    for (final controller in _stateHoverControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MexicoMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si selectedStateCode cambió de null a un valor, mostrar el detalle
    if (widget.selectedStateCode != null && 
        oldWidget.selectedStateCode == null) {
      // Si skipInitialAnimation es true, mostrar sin animación
      if (widget.skipInitialAnimation) {
        _showStateDetailForCodeNoAnimation(widget.selectedStateCode!);
      } else {
        _showStateDetailForCode(widget.selectedStateCode!);
      }
    }
    
    // Si selectedStateCode cambió a null, ocultar el detalle
    if (widget.selectedStateCode == null && oldWidget.selectedStateCode != null) {
      _selectionController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showStateDetail = false;
            _detailState = null;
          });
        }
      });
    }
  }
  
  void _showStateDetailForCode(String stateCode) {
    if (_states.isEmpty) {
      // Si los estados no han cargado, esperar y reintentar
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.selectedStateCode != null) {
          _showStateDetailForCode(widget.selectedStateCode!);
        }
      });
      return;
    }
    
    // Buscar el estado correspondiente por código o nombre
    MexicoState? foundState;
    for (final state in _states) {
      if (state.code == stateCode || state.name == stateCode) {
        foundState = state;
        break;
      }
    }
    
    if (foundState != null) {
      setState(() {
        _detailState = foundState;
        _showStateDetail = true;
      });
      _selectionController.forward(from: 0);
    }
  }
  
  // Versión sin animación para cuando venimos de la animación de expansión
  void _showStateDetailForCodeNoAnimation(String stateCode) {
    if (_states.isEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.selectedStateCode != null) {
          _showStateDetailForCodeNoAnimation(widget.selectedStateCode!);
        }
      });
      return;
    }
    
    MexicoState? foundState;
    for (final state in _states) {
      if (state.code == stateCode || state.name == stateCode) {
        foundState = state;
        break;
      }
    }
    
    if (foundState != null) {
      setState(() {
        _detailState = foundState;
        _showStateDetail = true;
      });
      // Saltar la animación, ir directo al final
      _selectionController.value = 1.0;
    }
  }

  void _initHoverAnimationForState(String stateCode) {
    if (!_stateHoverControllers.containsKey(stateCode)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _stateHoverControllers[stateCode] = controller;
      _stateHoverAnimations[stateCode] = Tween<double>(begin: 0, end: 1)
          .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          );
      controller.addListener(() => setState(() {}));
    }
  }

  Future<void> _loadGeoJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/images/mx-all.geo.json',
      );
      final Map<String, dynamic> geoJson = json.decode(jsonString);

      final List<dynamic> features = geoJson['features'];
      final List<MexicoState> states = [];

      for (final feature in features) {
        final properties = feature['properties'];
        final geometry = feature['geometry'];

        final String? stateCode =
            properties['postal-code'] ?? properties['hc-key'];
        final String? stateName = properties['name'];

        if (stateCode == null || stateName == null) continue;

        final List<List<Offset>> polygons = [];

        if (geometry['type'] == 'Polygon') {
          final coords = geometry['coordinates'] as List;
          polygons.add(_parsePolygon(coords[0]));
        } else if (geometry['type'] == 'MultiPolygon') {
          final multiCoords = geometry['coordinates'] as List;
          for (final polygon in multiCoords) {
            polygons.add(_parsePolygon(polygon[0]));
          }
        }

        final state = MexicoState(
          code: stateCode,
          name: stateName,
          polygons: polygons,
        );
        states.add(state);
        _initHoverAnimationForState(stateCode);
      }

      // Calcular bounds
      for (final state in states) {
        for (final polygon in state.polygons) {
          for (final point in polygon) {
            if (point.dx < _minX) _minX = point.dx;
            if (point.dx > _maxX) _maxX = point.dx;
            if (point.dy < _minY) _minY = point.dy;
            if (point.dy > _maxY) _maxY = point.dy;
          }
        }
      }

      setState(() {
        _states = states;
        _isLoading = false;
      });
      
      // Si hay un selectedStateCode inicial, mostrar el detalle
      if (widget.selectedStateCode != null) {
        _showStateDetailForCode(widget.selectedStateCode!);
      }
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Offset> _parsePolygon(List<dynamic> coords) {
    return coords.map((coord) {
      final x = (coord[0] as num).toDouble();
      final y = (coord[1] as num).toDouble();
      return Offset(x, y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF691C32)),
      );
    }

    if (_states.isEmpty) {
      return const Center(child: Text('No se pudo cargar el mapa'));
    }

    // Modo mini preview - solo muestra el estado seleccionado
    if (widget.showOnlySelected && widget.selectedStateCode != null) {
      return _buildMiniStatePreview(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return Stack(
          children: [
            // Mapa principal con zoom interactivo
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showStateDetail ? 0.3 : 1.0,
              child: GestureDetector(
                // Detectar tap solo cuando NO hay gesto de zoom/pan
                onTapUp: (details) {
                  // Solo procesar tap si no hubo interacción de zoom/pan
                  if (!_isInteracting) {
                    _handleTapAtPosition(details.localPosition, constraints);
                  }
                },
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: _minZoom,
                  maxScale: _maxZoom,
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(100),
                  constrained: false,
                  onInteractionStart: (details) {
                    _isInteracting = false;
                    _interactionStartPosition = details.focalPoint;
                    _interactionStartTime = DateTime.now();
                    _interactionPointerCount = details.pointerCount;
                  },
                  onInteractionUpdate: (details) {
                    // Si hay más de un dedo o movimiento significativo, es zoom/pan
                    if (details.pointerCount > 1) {
                      _isInteracting = true;
                    } else if (_interactionStartPosition != null) {
                      final distance = (details.focalPoint - _interactionStartPosition!).distance;
                      if (distance > 10) {
                        _isInteracting = true;
                      }
                    }
                    setState(() {
                      _currentZoom = _transformationController.value.getMaxScaleOnAxis();
                    });
                  },
                  onInteractionEnd: (details) {
                    // Pequeño delay para que el GestureDetector no capture el tap
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) {
                        _isInteracting = false;
                      }
                    });
                  },
                  child: SizedBox(
                    width: mapSize.width,
                    height: mapSize.height,
                    child: MouseRegion(
                      cursor: _hoveredStateCode != null
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      onHover: (event) => _handleHover(event, constraints),
                      onExit: (_) => _handleHoverExit(),
                      child: CustomPaint(
                        size: mapSize,
                        painter: MexicoMapPainter(
                          states: _states,
                          minX: _minX,
                          maxX: _maxX,
                          minY: _minY,
                          maxY: _maxY,
                          selectedStateCode: widget.selectedStateCode,
                          hoveredStateCode: _hoveredStateCode,
                          isDark: isDark,
                          hoverAnimations: _stateHoverAnimations,
                          highlightedStates: widget.highlightedStates,
                          zoomScale: _currentZoom,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Botones de zoom (+ / -)
            if (!_showStateDetail)
              Positioned(
                right: 12,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildZoomButton(
                      icon: Icons.add,
                      onTap: _zoomIn,
                      isDark: isDark,
                      enabled: _currentZoom < _maxZoom,
                    ),
                    const SizedBox(height: 8),
                    _buildZoomButton(
                      icon: Icons.remove,
                      onTap: _zoomOut,
                      isDark: isDark,
                      enabled: _currentZoom > _minZoom,
                    ),
                    // Botón de reset solo si hay zoom aplicado
                    if (_currentZoom > 1.0) ...[
                      const SizedBox(height: 8),
                      _buildZoomButton(
                        icon: Icons.fullscreen_exit,
                        onTap: _resetZoom,
                        isDark: isDark,
                        enabled: true,
                      ),
                    ],
                  ],
                ),
              ),

            // Vista de detalle del estado
            if (_showStateDetail && _detailState != null)
              AnimatedBuilder(
                animation: _selectionAnimation,
                builder: (context, child) {
                  return _buildStateDetailView(
                    context,
                    constraints,
                    _detailState!,
                    _selectionAnimation.value,
                    _elevationAnimation.value,
                  );
                },
              ),

            // Tooltip del estado
            if (_hoveredStateCode != null &&
                _hoverPosition != null &&
                !_showStateDetail)
              _buildStateTooltip(context),
          ],
        );
      },
    );
  }

  // Widget para mostrar solo la silueta del estado seleccionado (mini preview)
  Widget _buildMiniStatePreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Buscar el estado seleccionado
    final selectedState = _states.firstWhere(
      (s) => s.code == widget.selectedStateCode,
      orElse: () => _states.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        return Stack(
          children: [
            // Silueta del estado - SIEMPRE ocultar marcadores del painter
            // porque los widgets clickeables los manejan
            CustomPaint(
              size: size,
              painter: SingleStatePainter(
                state: selectedState,
                isDark: isDark,
                animationValue: 1.0,
                hideMarkers: true, // Siempre true - los widgets manejan los markers
              ),
            ),
            // Marcadores clickeables como widgets (si no están ocultos)
            if (!widget.hidePoloMarkers)
              ..._buildClickableMarkers(context, selectedState, size, isDark),
          ],
        );
      },
    );
  }

  Widget _buildStateDetailView(
    BuildContext context,
    BoxConstraints constraints,
    MexicoState state,
    double animationValue,
    double elevationValue,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    return Positioned.fill(
      child: GestureDetector(
        onTap: _closeStateDetail,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Evitar que el tap en el estado cierre la vista
              child: Transform.scale(
                scale: 0.5 + (animationValue.clamp(0.0, 1.0) * 0.5),
                child: Opacity(
                  opacity: animationValue.clamp(0.0, 1.0),
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2029) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF691C32).withValues(
                            alpha: (0.3 * elevationValue).clamp(0.0, 1.0),
                          ),
                          blurRadius: 40 * elevationValue,
                          offset: Offset(0, 20 * elevationValue),
                          spreadRadius: 5 * elevationValue,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: (0.2 * elevationValue).clamp(0.0, 1.0),
                          ),
                          blurRadius: 60 * elevationValue,
                          offset: Offset(0, 30 * elevationValue),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Mapa del estado individual - hideMarkers porque widgets los manejan
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: CustomPaint(
                                painter: SingleStatePainter(
                                  state: state,
                                  isDark: isDark,
                                  animationValue: animationValue,
                                  hideMarkers: true, // Widgets manejan los markers
                                ),
                              ),
                            ),
                          ),

                          // Marcadores clickeables para todos los polos del estado
                          ..._buildClickableMarkers(context, state, size, isDark),

                          // Header con nombre del estado
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    isDark
                                        ? const Color(0xFF1E2029)
                                        : Colors.white,
                                    isDark
                                        ? const Color(
                                            0xFF1E2029,
                                          ).withValues(alpha: 0)
                                        : Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF691C32),
                                          Color(0xFF4A1525),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.name,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                        Text(
                                          'Código: ${state.code}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.6,
                                                  )
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botón de cerrar
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _closeStateDetail,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.1,
                                                )
                                              : const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1A1A2E),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Instrucción inferior
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.touch_app_rounded,
                                      size: 16,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Toca X para regresar al mapa',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.6,
                                              )
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye los marcadores clickeables para todos los polos de un estado
  List<Widget> _buildClickableMarkers(
    BuildContext context,
    MexicoState state,
    Size size,
    bool isDark, {
    double zoomScale = 1.0,
  }) {
    // Obtener los polos del estado
    final polos = PolosData.getPolosByEstado(state.code).isNotEmpty
        ? PolosData.getPolosByEstado(state.code)
        : PolosData.getPolosByEstado(state.name);

    if (polos.isEmpty) return [];

    // Escala inversa al zoom para que los marcadores se vean del mismo tamaño
    final markerScale = (1.0 / zoomScale).clamp(0.5, 1.0);
    final baseSize = 40.0 * markerScale;
    final innerSize = 28.0 * markerScale;
    final iconSize = 16.0 * markerScale;

    // Calcular bounds del estado para posicionar los marcadores
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final polygon in state.polygons) {
      for (final point in polygon) {
        if (point.dx < minX) minX = point.dx;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dy > maxY) maxY = point.dy;
      }
    }

    final stateWidth = maxX - minX;
    final stateHeight = maxY - minY;

    // Calcular escala y offset (mismo cálculo que SingleStatePainter)
    final padding = 30.0;
    final availableWidth = size.width - padding * 2 - 48;
    final availableHeight = size.height - padding * 2 - 48;

    final dataWidth = maxX - minX;
    final dataHeight = maxY - minY;

    final scaleX = availableWidth / dataWidth;
    final scaleY = availableHeight / dataHeight;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - dataWidth * scale) / 2;
    final offsetY = (size.height - dataHeight * scale) / 2;

    // Crear un marcador clickeable para cada polo
    return polos.map((polo) {
      final markerGeoX = minX + stateWidth * polo.relativeX;
      final markerGeoY = minY + stateHeight * polo.relativeY;

      final markerX = (markerGeoX - minX) * scale + offsetX;
      final markerY = size.height - ((markerGeoY - minY) * scale + offsetY);

      // Verificar si este polo está seleccionado
      final isSelected = widget.selectedPoloId == polo.idString;

      return Positioned(
        left: markerX - baseSize / 2,
        top: markerY - baseSize / 2,
        child: GestureDetector(
          onTap: () {
            // Crear información del polo desde PoloMarker
            final poloInfo = PoloInfo(
              id: polo.idString,
              nombre: polo.nombre,
              estado: polo.estado,
              descripcion: _buildPoloDescription(polo),
              tipo: polo.tipo,
              imagenes: [],
              ubicacion: '${polo.estado}, México',
              latitud: 0,
              longitud: 0,
            );
            widget.onPoloSelected?.call(poloInfo);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, isSelected ? -8 * markerScale : 0, 0),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: isSelected ? 1.3 : 1.0,
                child: Container(
                  width: baseSize,
                  height: baseSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFFBC955C),
                            width: 3 * markerScale,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFBC955C).withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.3),
                        blurRadius: (isSelected ? 16 : 8) * markerScale,
                        offset: Offset(0, (isSelected ? 6 : 2) * markerScale),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: innerSize,
                      height: innerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: polo.color,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Construye la descripción completa del polo
  String _buildPoloDescription(PoloMarker polo) {
    final buffer = StringBuffer();
    
    if (polo.vocacion.isNotEmpty) {
      buffer.writeln('📍 Vocación: ${polo.vocacion}');
      buffer.writeln();
    }
    
    if (polo.sectoresClave.isNotEmpty) {
      buffer.writeln('🏭 Sectores Clave:');
      for (final sector in polo.sectoresClave) {
        buffer.writeln('  • $sector');
      }
      buffer.writeln();
    }
    
    if (polo.infraestructura.isNotEmpty) {
      buffer.writeln('🏗️ Infraestructura: ${polo.infraestructura}');
      buffer.writeln();
    }
    
    if (polo.descripcion.isNotEmpty) {
      buffer.writeln(polo.descripcion);
    }
    
    return buffer.toString().trim();
  }

  void _closeStateDetail() {
    _selectionController.reverse().then((_) {
      setState(() {
        _showStateDetail = false;
        _detailState = null;
      });
      // Notificar que se deseleccionó el estado
      widget.onStateSelected?.call('', '');
      widget.onBackToMap?.call();
    });
  }

  // Métodos de zoom
  void _zoomIn() {
    final newZoom = (_currentZoom + 0.5).clamp(_minZoom, _maxZoom);
    _animateZoom(newZoom);
  }

  void _zoomOut() {
    final newZoom = (_currentZoom - 0.5).clamp(_minZoom, _maxZoom);
    _animateZoom(newZoom);
  }

  void _animateZoom(double targetZoom) {
    // Si es el mismo zoom, no hacer nada
    if (targetZoom == _currentZoom) return;
    
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    
    // Calcular el factor de escala
    final double scaleFactor = targetZoom / currentScale;
    
    // Obtener la traducción actual
    final translation = currentMatrix.getTranslation();
    
    // Crear nueva matriz manteniendo la posición relativa
    final newMatrix = Matrix4.identity()
      ..translate(translation.x * scaleFactor, translation.y * scaleFactor)
      ..scale(targetZoom);
    
    _transformationController.value = newMatrix;
    setState(() {
      _currentZoom = targetZoom;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _currentZoom = 1.0;
    });
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark 
              ? const Color(0xFF262830).withValues(alpha: 0.95) 
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF3A3D47) 
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled 
              ? const Color(0xFF691C32) 
              : (isDark ? Colors.white24 : Colors.grey.shade400),
        ),
      ),
    );
  }

  void _handleHover(PointerHoverEvent event, BoxConstraints constraints) {
    final state = _findStateAtPosition(event.localPosition, constraints);

    if (state?.code != _hoveredStateCode) {
      // Animar salida del estado anterior
      if (_hoveredStateCode != null) {
        _stateHoverControllers[_hoveredStateCode]?.reverse();
      }

      // Animar entrada del nuevo estado
      if (state != null) {
        _stateHoverControllers[state.code]?.forward();
      }

      setState(() {
        _hoveredStateCode = state?.code;
        _hoverPosition = event.localPosition;
      });

      // Notificar hover
      widget.onStateHover?.call(state?.name);
    } else {
      // Solo actualizar posición si ya estamos sobre el mismo estado
      if (_hoveredStateCode != null) {
        setState(() => _hoverPosition = event.localPosition);
      }
    }
  }

  void _handleHoverExit() {
    if (_hoveredStateCode != null) {
      _stateHoverControllers[_hoveredStateCode]?.reverse();
    }
    setState(() {
      _hoveredStateCode = null;
      _hoverPosition = null;
    });
    widget.onStateHover?.call(null);
  }

  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
    if (_showStateDetail) return;

    final state = _findStateAtPosition(details.localPosition, constraints);
    if (state != null) {
      widget.onStateSelected?.call(state.code, state.name);

      // Solo mostrar detalle automáticamente si autoShowDetail es true
      if (widget.autoShowDetail) {
        setState(() {
          _detailState = state;
          _showStateDetail = true;
        });
        _selectionController.forward(from: 0);
      }
    }
  }

  // Versión que acepta directamente la posición (para uso con GestureDetector externo)
  void _handleTapAtPosition(Offset position, BoxConstraints constraints) {
    if (_showStateDetail) return;

    // Transformar la posición según el zoom actual
    final matrix = _transformationController.value;
    final inverseMatrix = Matrix4.inverted(matrix);
    final transformedPoint = MatrixUtils.transformPoint(inverseMatrix, position);

    final state = _findStateAtPosition(transformedPoint, constraints);
    if (state != null) {
      widget.onStateSelected?.call(state.code, state.name);

      // Solo mostrar detalle automáticamente si autoShowDetail es true
      if (widget.autoShowDetail) {
        setState(() {
          _detailState = state;
          _showStateDetail = true;
        });
        _selectionController.forward(from: 0);
      }
    }
  }

  MexicoState? _findStateAtPosition(
    Offset position,
    BoxConstraints constraints,
  ) {
    final size = Size(constraints.maxWidth, constraints.maxHeight);

    for (final state in _states) {
      for (final polygon in state.polygons) {
        final scaledPolygon = _scalePolygon(polygon, size);
        if (_isPointInPolygon(position, scaledPolygon)) {
          return state;
        }
      }
    }
    return null;
  }

  List<Offset> _scalePolygon(List<Offset> polygon, Size size) {
    final padding = 20.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    final dataWidth = _maxX - _minX;
    final dataHeight = _maxY - _minY;

    final scaleX = availableWidth / dataWidth;
    final scaleY = availableHeight / dataHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - dataWidth * scale) / 2;
    final offsetY = (size.height - dataHeight * scale) / 2;

    return polygon.map((point) {
      final x = (point.dx - _minX) * scale + offsetX;
      final y = size.height - ((point.dy - _minY) * scale + offsetY);
      return Offset(x, y);
    }).toList();
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if (((polygon[i].dy > point.dy) != (polygon[j].dy > point.dy)) &&
          (point.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (point.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  Widget _buildStateTooltip(BuildContext context) {
    final state = _states.firstWhere(
      (s) => s.code == _hoveredStateCode,
      orElse: () => _states.first,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Escalar inversamente al zoom
    final tooltipScale = (1.0 / widget.zoomScale).clamp(0.25, 1.0);
    
    // Ajustar el offset base según el zoom para que el tooltip quede cerca del cursor
    final baseOffsetX = 60 * tooltipScale;
    final baseOffsetY = 50 * tooltipScale;

    // Ajustar posición para que el tooltip no se salga de la pantalla o tape el cursor
    double left = _hoverPosition!.dx - baseOffsetX;
    double top = _hoverPosition!.dy - baseOffsetY;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Transform.scale(
          scale: tooltipScale,
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                if (_poloCounts.containsKey(state.name)) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Polos: ${_poloCounts[state.name]}',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MexicoMapPainter extends CustomPainter {
  final List<MexicoState> states;
  final double minX, maxX, minY, maxY;
  final String? selectedStateCode;
  final String? hoveredStateCode;
  final bool isDark;
  final Map<String, Animation<double>> hoverAnimations;
  final List<String>? highlightedStates;
  final double zoomScale;

  MexicoMapPainter({
    required this.states,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    this.selectedStateCode,
    this.hoveredStateCode,
    required this.isDark,
    required this.hoverAnimations,
    this.highlightedStates,
    this.zoomScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 20.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    final dataWidth = maxX - minX;
    final dataHeight = maxY - minY;

    final scaleX = availableWidth / dataWidth;
    final scaleY = availableHeight / dataHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - dataWidth * scale) / 2;
    final offsetY = (size.height - dataHeight * scale) / 2;

    // Primero dibujamos los estados no hovered
    for (final state in states) {
      if (state.code != hoveredStateCode) {
        _drawState(canvas, size, state, scale, offsetX, offsetY, 0);
      }
    }

    // Luego dibujamos el estado hovered encima con elevación
    if (hoveredStateCode != null) {
      final hoveredState = states.firstWhere(
        (s) => s.code == hoveredStateCode,
        orElse: () => states.first,
      );
      if (hoveredState.code == hoveredStateCode) {
        final hoverValue = hoverAnimations[hoveredStateCode]?.value ?? 0;
        _drawState(
          canvas,
          size,
          hoveredState,
          scale,
          offsetX,
          offsetY,
          hoverValue,
        );
      }
    }

    // Dibujar marcadores de polos
    _drawMarkers(canvas, size, scale, offsetX, offsetY);
  }

  void _drawMarkers(
    Canvas canvas,
    Size size,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    // Dibujar todos los polos desde PolosData
    for (final polo in PolosData.polos) {
      final state = states
          .where((s) => s.code == polo.estadoCodigo || s.name == polo.estado)
          .firstOrNull;
      
      if (state != null) {
        _drawStateMarker(
          canvas, size, scale, offsetX, offsetY,
          state: state,
          relativeX: polo.relativeX,
          relativeY: polo.relativeY,
          color: polo.color,
        );
      }
    }
  }

  /// Dibuja un marcador circular en una posición relativa dentro de un estado
  void _drawStateMarker(
    Canvas canvas,
    Size size,
    double scale,
    double offsetX,
    double offsetY, {
    required MexicoState state,
    required double relativeX, // 0.0 = izquierda, 1.0 = derecha
    required double relativeY, // 0.0 = abajo, 1.0 = arriba
    required Color color,
  }) {
    // Calcular bounds del estado
    double stateMinX = double.infinity;
    double stateMaxX = double.negativeInfinity;
    double stateMinY = double.infinity;
    double stateMaxY = double.negativeInfinity;

    for (final polygon in state.polygons) {
      for (final point in polygon) {
        if (point.dx < stateMinX) stateMinX = point.dx;
        if (point.dx > stateMaxX) stateMaxX = point.dx;
        if (point.dy < stateMinY) stateMinY = point.dy;
        if (point.dy > stateMaxY) stateMaxY = point.dy;
      }
    }

    final stateWidth = stateMaxX - stateMinX;
    final stateHeight = stateMaxY - stateMinY;

    // Posición del marcador según porcentajes relativos
    final markerGeoX = stateMinX + stateWidth * relativeX;
    final markerGeoY = stateMinY + stateHeight * relativeY;

    final markerX = (markerGeoX - minX) * scale + offsetX;
    final markerY = size.height - ((markerGeoY - minY) * scale + offsetY);

    // Tamaño pequeño para el mapa completo, escalado inversamente al zoom
    final markerScale = (1.0 / zoomScale).clamp(0.4, 1.0);
    final markerSize = 6.0 * markerScale;
    final borderWidth = 2.0 * markerScale;

    // Sombra del marcador
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * markerScale);
    canvas.drawCircle(
      Offset(markerX + 1 * markerScale, markerY + 1 * markerScale),
      markerSize,
      shadowPaint,
    );

    // Círculo exterior (borde blanco)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), markerSize + borderWidth, borderPaint);

    // Círculo interior (punto de color)
    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), markerSize, markerPaint);
  }

  void _drawState(
    Canvas canvas,
    Size size,
    MexicoState state,
    double scale,
    double offsetX,
    double offsetY,
    double hoverValue,
  ) {
    final isSelected = state.code == selectedStateCode;
    final isHovered = state.code == hoveredStateCode;
    final isHighlighted = highlightedStates?.contains(state.name) ?? false;

    // Calcular el centro del estado para la elevación
    double centerX = 0, centerY = 0;
    int pointCount = 0;
    for (final polygon in state.polygons) {
      for (final point in polygon) {
        final x = (point.dx - minX) * scale + offsetX;
        final y = size.height - ((point.dy - minY) * scale + offsetY);
        centerX += x;
        centerY += y;
        pointCount++;
      }
    }
    if (pointCount > 0) {
      centerX /= pointCount;
      centerY /= pointCount;
    }

    // Aplicar transformación de elevación
    final elevationOffset = hoverValue * 8; // Pixels de elevación
    final scaleBoost = 1.0 + (hoverValue * 0.05); // 5% de aumento de escala

    Color fillColor;
    if (isSelected) {
      fillColor = const Color(0xFF691C32);
    } else if (isHovered) {
      fillColor = Color.lerp(
        isHighlighted
            ? (isDark
                  ? const Color(0xFF691C32).withValues(alpha: 0.5)
                  : const Color(0xFF691C32).withValues(alpha: 0.55))
            : (isDark ? const Color(0xFF2D3748) : const Color(0xFFE8D5B7)),
        const Color(0xFF8B2942),
        hoverValue,
      )!;
    } else if (isHighlighted) {
      fillColor = isDark
          ? const Color(0xFF691C32).withValues(alpha: 0.4)
          : const Color(0xFF691C32).withValues(alpha: 0.45);
    } else {
      fillColor = isDark ? const Color(0xFF2D3748) : const Color(0xFFE8D5B7);
    }

    // Sombra para efecto de elevación
    if (hoverValue > 0) {
      final clampedHoverValue = hoverValue.clamp(0.0, 1.0);
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3 * clampedHoverValue)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          10 * clampedHoverValue,
        );

      for (final polygon in state.polygons) {
        final shadowPath = Path();
        bool first = true;

        for (final point in polygon) {
          double x = (point.dx - minX) * scale + offsetX;
          double y = size.height - ((point.dy - minY) * scale + offsetY);

          // Aplicar escala desde el centro
          x = centerX + (x - centerX) * scaleBoost;
          y = centerY + (y - centerY) * scaleBoost;

          // Offset de sombra
          x += elevationOffset * 0.5;
          y += elevationOffset;

          if (first) {
            shadowPath.moveTo(x, y);
            first = false;
          } else {
            shadowPath.lineTo(x, y);
          }
        }
        shadowPath.close();
        canvas.drawPath(shadowPath, shadowPaint);
      }
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isHovered
          ? Colors.white.withValues(alpha: 0.9)
          : (isHighlighted
                ? Colors.white.withValues(alpha: 0.8)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : const Color(0xFF8B7355)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2.5 : (isHighlighted ? 1.5 : (isSelected ? 2.0 : 0.8));

    for (final polygon in state.polygons) {
      final path = Path();
      bool first = true;

      for (final point in polygon) {
        double x = (point.dx - minX) * scale + offsetX;
        double y = size.height - ((point.dy - minY) * scale + offsetY);

        // Aplicar escala y offset desde el centro
        x = centerX + (x - centerX) * scaleBoost;
        y = centerY + (y - centerY) * scaleBoost - elevationOffset;

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MexicoMapPainter oldDelegate) {
    return true; // Siempre repintar para animaciones suaves
  }
}

// Painter para dibujar un solo estado en la vista de detalle
class SingleStatePainter extends CustomPainter {
  final MexicoState state;
  final bool isDark;
  final double animationValue;
  final bool hideMarkers; // Para ocultar los markers de polos

  SingleStatePainter({
    required this.state,
    required this.isDark,
    required this.animationValue,
    this.hideMarkers = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calcular bounds del estado
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final polygon in state.polygons) {
      for (final point in polygon) {
        if (point.dx < minX) minX = point.dx;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dy > maxY) maxY = point.dy;
      }
    }

    // Padding más pequeño para mini preview
    final padding = hideMarkers ? 5.0 : 30.0;
    final availableWidth = size.width - padding * 2;
    final availableHeight = size.height - padding * 2;

    final dataWidth = maxX - minX;
    final dataHeight = maxY - minY;

    final scaleX = availableWidth / dataWidth;
    final scaleY = availableHeight / dataHeight;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - dataWidth * scale) / 2;
    final offsetY = (size.height - dataHeight * scale) / 2;

    // Gradiente para el estado
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF691C32),
        const Color(0xFF8B2942),
        const Color(0xFF4A1525),
      ],
    );

    // Calcular el rect del estado para el shader
    final stateRect = Rect.fromLTWH(
      offsetX,
      offsetY,
      dataWidth * scale,
      dataHeight * scale,
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(stateRect)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    for (final polygon in state.polygons) {
      final path = Path();
      final shadowPath = Path();
      bool first = true;

      for (final point in polygon) {
        final x = (point.dx - minX) * scale + offsetX;
        final y = size.height - ((point.dy - minY) * scale + offsetY);

        if (first) {
          path.moveTo(x, y);
          shadowPath.moveTo(x + 5, y + 10);
          first = false;
        } else {
          path.lineTo(x, y);
          shadowPath.lineTo(x + 5, y + 10);
        }
      }
      path.close();
      shadowPath.close();

      // Dibujar sombra primero
      canvas.drawPath(shadowPath, shadowPaint);

      // Dibujar estado
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    }

    // Dibujar marcadores según el estado (solo si no están ocultos)
    if (!hideMarkers) {
      _drawDetailMarkers(canvas, size, state, minX, minY, maxX, maxY, scale, offsetX, offsetY);
    }
  }

  /// Dibuja los marcadores de polos en la vista de detalle del estado
  void _drawDetailMarkers(
    Canvas canvas,
    Size size,
    MexicoState state,
    double minX,
    double minY,
    double maxX,
    double maxY,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    final stateWidth = maxX - minX;
    final stateHeight = maxY - minY;

    // Obtener polos del estado desde PolosData
    final polos = PolosData.getPolosByEstado(state.code).isNotEmpty
        ? PolosData.getPolosByEstado(state.code)
        : PolosData.getPolosByEstado(state.name);

    // Dibujar cada marcador
    for (final polo in polos) {
      final markerGeoX = minX + stateWidth * polo.relativeX;
      final markerGeoY = minY + stateHeight * polo.relativeY;

      final markerX = (markerGeoX - minX) * scale + offsetX;
      final markerY = size.height - ((markerGeoY - minY) * scale + offsetY);

      // Sombra del marcador
      final markerShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
        Offset(markerX + 2, markerY + 3),
        12,
        markerShadowPaint,
      );

      // Círculo exterior (borde blanco)
      final markerBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX, markerY), 14, markerBorderPaint);

      // Círculo interior (punto de color)
      final markerPaint = Paint()
        ..color = polo.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX, markerY), 10, markerPaint);

      // Pequeño destello
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX - 3, markerY - 3), 4, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SingleStatePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}

class MexicoState {
  final String code;
  final String name;
  final List<List<Offset>> polygons;

  MexicoState({required this.code, required this.name, required this.polygons});
}
