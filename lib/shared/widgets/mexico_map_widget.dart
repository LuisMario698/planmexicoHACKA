import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MexicoMapWidget extends StatefulWidget {
  final Function(String stateCode, String stateName)? onStateSelected;
  final Function(PoloInfo polo)? onPoloSelected;
  final Function(String? stateName)? onStateHover;
  final String? selectedStateCode;
  final VoidCallback? onBackToMap;
  final List<String>? highlightedStates;

  const MexicoMapWidget({
    super.key,
    this.onStateSelected,
    this.onPoloSelected,
    this.onStateHover,
    this.selectedStateCode,
    this.onBackToMap,
    this.highlightedStates,
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
    for (final controller in _stateHoverControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Mapa principal
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showStateDetail ? 0.3 : 1.0,
              child: MouseRegion(
                cursor: _hoveredStateCode != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                onHover: (event) => _handleHover(event, constraints),
                onExit: (_) => _handleHoverExit(),
                child: GestureDetector(
                  onTapDown: (details) => _handleTap(details, constraints),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: MexicoMapPainter(
                      states: _states,
                      minX: _minX,
                      maxX: _maxX,
                      minY: _minY,
                      maxY: _maxY,
                      selectedStateCode: widget.selectedStateCode,
                      hoveredStateCode: _hoveredStateCode,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                      hoverAnimations: _stateHoverAnimations,
                      highlightedStates: widget.highlightedStates,
                    ),
                  ),
                ),
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
                          // Mapa del estado individual
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: CustomPaint(
                                painter: SingleStatePainter(
                                  state: state,
                                  isDark: isDark,
                                  animationValue: animationValue,
                                ),
                              ),
                            ),
                          ),

                          // Marcador clickeable (solo para Campeche por ahora)
                          if (state.code == 'CM' || state.name == 'Campeche')
                            _buildClickableMarker(context, state, size, isDark),

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

  Widget _buildClickableMarker(
    BuildContext context,
    MexicoState state,
    Size size,
    bool isDark,
  ) {
    // Calcular bounds del estado para posicionar el marcador
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
    final availableWidth =
        size.width - padding * 2 - 48; // -48 por el padding del Positioned.fill
    final availableHeight = size.height - padding * 2 - 48;

    final dataWidth = maxX - minX;
    final dataHeight = maxY - minY;

    final scaleX = availableWidth / dataWidth;
    final scaleY = availableHeight / dataHeight;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - dataWidth * scale) / 2;
    final offsetY = (size.height - dataHeight * scale) / 2;

    // Posición del marcador: 55% desde la izquierda, 65% desde abajo
    final markerGeoX = minX + stateWidth * 0.55;
    final markerGeoY = minY + stateHeight * 0.65;

    final markerX = (markerGeoX - minX) * scale + offsetX;
    final markerY = size.height - ((markerGeoY - minY) * scale + offsetY);

    return Positioned(
      left: markerX - 20,
      top: markerY - 20,
      child: GestureDetector(
        onTap: () {
          // Crear información del polo
          final poloInfo = PoloInfo(
            id: 'campeche_polo_1',
            nombre: 'Polo de Desarrollo Campeche',
            estado: 'Campeche',
            descripcion:
                'Nuevo polo de desarrollo enfocado en energías renovables y desarrollo sustentable. '
                'Este proyecto busca impulsar la economía local mediante la creación de empleos verdes '
                'y la implementación de tecnologías limpias en la región.',
            tipo: 'nuevo',
            imagenes: ['assets/images/marina_campeche.png'],
            ubicacion: 'Campeche, México',
            latitud: 19.8301,
            longitud: -90.5349,
          );
          widget.onPoloSelected?.call(poloInfo);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2563EB), // Azul - Nuevo polo
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

      setState(() {
        _detailState = state;
        _showStateDetail = true;
      });
      _selectionController.forward(from: 0);
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

    // Ajustar posición para que el tooltip no se salga de la pantalla o tape el cursor
    double left = _hoverPosition!.dx - 60; // Centrado horizontalmente (aprox)
    double top = _hoverPosition!.dy - 50; // Arriba del cursor

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
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
    // Encontrar Campeche para calcular la posición del marcador
    final campeche = states
        .where((s) => s.code == 'CM' || s.name == 'Campeche')
        .firstOrNull;
    if (campeche != null) {
      // Calcular bounds de Campeche
      double stateMinX = double.infinity;
      double stateMaxX = double.negativeInfinity;
      double stateMinY = double.infinity;
      double stateMaxY = double.negativeInfinity;

      for (final polygon in campeche.polygons) {
        for (final point in polygon) {
          if (point.dx < stateMinX) stateMinX = point.dx;
          if (point.dx > stateMaxX) stateMaxX = point.dx;
          if (point.dy < stateMinY) stateMinY = point.dy;
          if (point.dy > stateMaxY) stateMaxY = point.dy;
        }
      }

      final stateWidth = stateMaxX - stateMinX;
      final stateHeight = stateMaxY - stateMinY;

      // Posición del marcador: 55% desde la izquierda, 65% desde abajo
      final markerGeoX = stateMinX + stateWidth * 0.55;
      final markerGeoY = stateMinY + stateHeight * 0.65;

      final markerX = (markerGeoX - minX) * scale + offsetX;
      final markerY = size.height - ((markerGeoY - minY) * scale + offsetY);

      // Tamaño pequeño para el mapa completo
      final markerSize = 6.0;

      // Sombra del marcador
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(markerX + 1, markerY + 1),
        markerSize,
        shadowPaint,
      );

      // Círculo exterior (borde blanco)
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX, markerY), markerSize + 2, borderPaint);

      // Círculo interior (punto azul - nuevo polo)
      final markerPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX, markerY), markerSize, markerPaint);
    }
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
                  : const Color(0xFF691C32).withValues(alpha: 0.3))
            : (isDark ? const Color(0xFF2D3748) : const Color(0xFFE8D5B7)),
        const Color(0xFF8B2942),
        hoverValue,
      )!;
    } else if (isHighlighted) {
      fillColor = isDark
          ? const Color(0xFF691C32).withValues(alpha: 0.4)
          : const Color(0xFF691C32).withValues(alpha: 0.2);
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
          ? Colors.white.withValues(alpha: 0.8)
          : (isHighlighted
                ? const Color(0xFF691C32).withValues(alpha: 0.6)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : const Color(0xFF8B7355)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 2.5 : (isSelected ? 2.0 : 0.8);

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

  SingleStatePainter({
    required this.state,
    required this.isDark,
    required this.animationValue,
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

    final padding = 30.0;
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

    // Dibujar marcador si es Campeche
    if (state.code == 'CM' || state.name == 'Campeche') {
      // Calcular posición del marcador como porcentaje del estado
      // El círculo verde está en la muesca superior del estado
      final stateWidth = maxX - minX;
      final stateHeight = maxY - minY;

      // Posición aproximada: 55% desde la izquierda, 65% desde abajo
      final markerGeoX = minX + stateWidth * 0.55;
      final markerGeoY = minY + stateHeight * 0.65;

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

      // Círculo exterior (borde)
      final markerBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(markerX, markerY), 14, markerBorderPaint);

      // Círculo interior (punto azul - nuevo polo)
      final markerPaint = Paint()
        ..color =
            const Color(0xFF2563EB) // Azul - Nuevo polo
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
