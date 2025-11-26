import 'package:flutter/material.dart';
import '../widgets/mexico_map_widget.dart';

class PolosScreen extends StatefulWidget {
  const PolosScreen({super.key});

  @override
  State<PolosScreen> createState() => _PolosScreenState();
}

class StatePoloData {
  final int count;
  final List<String> descriptions;

  const StatePoloData({required this.count, required this.descriptions});
}

class _PolosScreenState extends State<PolosScreen> {
  String? _selectedStateCode;
  String? _selectedStateName;
  String? _hoveredStateName;
  PoloInfo? _selectedPolo;
  
  // Estado para móvil con zoom y confirmación
  String? _pendingStateCode;
  String? _pendingStateName;
  bool _showMobileConfirmation = false;
  final TransformationController _transformationController = TransformationController();
  double _currentZoom = 1.0;
  
  // Límites de zoom
  static const double _minScale = 0.5;
  static const double _maxScale = 6.0;

  final Map<String, StatePoloData> _statePoloData = {
    'Sonora': const StatePoloData(
      count: 2,
      descriptions: [
        'Golfo de California – 555 ha (Hermosillo)',
        'Noroeste – Plan Sonora',
      ],
    ),
    'Tamaulipas': const StatePoloData(
      count: 2,
      descriptions: [
        'Franja Fronteriza – 300 ha, Nuevo Laredo',
        'Golfo – 935 ha, Puerto Seco',
      ],
    ),
    'Puebla': const StatePoloData(count: 1, descriptions: ['Centro – 462 ha']),
    'Durango': const StatePoloData(
      count: 1,
      descriptions: ['Durango – 470 ha'],
    ),
    'Yucatán': const StatePoloData(
      count: 1,
      descriptions: ['Maya – 223 ha (Mérida y Progreso)'],
    ),
    'Coahuila': const StatePoloData(
      count: 2,
      descriptions: [
        'Norte – AHMSA 740 ha',
        'Norte – Parque Binacional Piedras Negras (300 ha)',
      ],
    ),
    'Nuevo León': const StatePoloData(
      count: 1,
      descriptions: [
        'Franja Fronteriza / Border industrial zone (por ubicación multinodal incluye parte del corredor)',
      ],
    ),
    'Chihuahua': const StatePoloData(
      count: 1,
      descriptions: ['Norte (cadena de desarrollo en región multinodal)'],
    ),
    'Guanajuato': const StatePoloData(
      count: 1,
      descriptions: ['Bajío – 52 ha (Celaya)'],
    ),
    'Estado de México': const StatePoloData(
      count: 1,
      descriptions: ['AIFA – 300 ha (Corredor AIFA)'],
    ),
    'Distrito Federal': const StatePoloData(
      count: 1,
      descriptions: ['Polígono AIFA (por zona metropolitana)'],
    ),
    'Ciudad de México': const StatePoloData(
      count: 1,
      descriptions: ['Polígono AIFA (por zona metropolitana)'],
    ),
    'Oaxaca': const StatePoloData(
      count: 1,
      descriptions: ['Istmo – 12 polos dentro del corredor del CIIT'],
    ),
    'Veracruz': const StatePoloData(
      count: 1,
      descriptions: [
        'Istmo – 12 polos del CIIT (parte del corredor está en Veracruz)',
      ],
    ),
    'Tabasco': const StatePoloData(
      count: 1,
      descriptions: ['Istmo – polo sur del corredor'],
    ),
    'Campeche': const StatePoloData(
      count: 1,
      descriptions: ['Maya/Regiones conectadas por SE'],
    ),
  };

  final Map<String, List<String>> _stateSectors = {
    'Sonora': [
      'Automotriz y electromovilidad',
      'Aeroespacial',
      'Semiconductores',
      'Energía',
      'Bienes de consumo',
      'Agroindustria',
    ],
    'Tamaulipas': [
      'Automotriz y electromovilidad',
      'Bienes de consumo',
      'Textil y zapatos',
      'Petroquímica',
      'Química',
      'Agroindustria',
    ],
    'Coahuila': [
      'Automotriz y electromovilidad',
      'Aeroespacial',
      'Semiconductores',
      'Petroquímica/Química',
      'Bienes de consumo',
      'Textil y zapatos',
    ],
    'Durango': [
      'Automotriz y electromovilidad',
      'Textil',
      'Agroindustria',
      'Bienes de consumo',
    ],
    'Guanajuato': [
      'Automotriz y electromovilidad',
      'Textil y zapatos',
      'Bienes de consumo',
    ],
    'Estado de México': [
      'Aeroespacial',
      'Farmacéutica y dispositivos médicos',
      'Logística avanzada',
      'Semiconductores',
    ],
    'Distrito Federal': [
      'Aeroespacial',
      'Farmacéutica y dispositivos médicos',
      'Logística avanzada',
      'Semiconductores',
    ],
    'Ciudad de México': [
      'Aeroespacial',
      'Farmacéutica y dispositivos médicos',
      'Logística avanzada',
      'Semiconductores',
    ],
    'Puebla': ['Automotriz', 'Textil', 'Agroindustria', 'Bienes de consumo'],
    'Yucatán': ['Agroindustria', 'Bienes de consumo', 'Turismo'],
    'Oaxaca': [
      'Logística',
      'Petroquímica',
      'Automotriz',
      'Textil',
      'Agroindustria',
    ],
    'Veracruz': [
      'Logística',
      'Petroquímica',
      'Automotriz',
      'Textil',
      'Agroindustria',
    ],
  };

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onZoomChanged);
  }

  void _onZoomChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale != _currentZoom) {
      setState(() {
        _currentZoom = scale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onZoomChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(isDark, isDesktop),
              const SizedBox(height: 24),

              // Contenido principal
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(isDark)
                    : _buildMobileLayout(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF691C32).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Polos de Desarrollo',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona un estado para ver sus polos de desarrollo',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Mapa
        Expanded(flex: 3, child: _buildMapContainer(isDark)),
        const SizedBox(width: 24),
        // Panel de información
        Expanded(flex: 2, child: _buildInfoPanel(isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    // Si hay un polo seleccionado, dar más espacio al panel de información
    final mapFlex = _selectedPolo != null ? 2 : 3;
    final infoFlex = _selectedPolo != null ? 3 : 1;
    
    return Column(
      children: [
        // Mapa con zoom
        Expanded(
          flex: mapFlex,
          child: _buildMobileMapContainer(isDark),
        ),
        const SizedBox(height: 12),
        // Panel de información - más grande cuando hay polo seleccionado
        Expanded(
          flex: infoFlex,
          child: _buildInfoPanel(isDark),
        ),
      ],
    );
  }

  Widget _buildMobileMapContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Mapa general con InteractiveViewer (cuando no hay estado confirmado)
            if (_selectedStateCode == null)
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: const EdgeInsets.all(100),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: MexicoMapWidget(
                    selectedStateCode: null,
                    highlightedStates: _statePoloData.keys.toList(),
                    autoShowDetail: false, // En móvil NO mostrar detalle automático
                    zoomScale: _currentZoom, // Pasar el zoom para escalar tooltips
                    onStateSelected: (code, name) {
                      // En móvil, mostrar confirmación antes de navegar
                      if (code.isNotEmpty && name.isNotEmpty) {
                        setState(() {
                          _pendingStateCode = code;
                          _pendingStateName = name;
                          _showMobileConfirmation = true;
                        });
                      }
                    },
                    onPoloSelected: (polo) {
                      setState(() {
                        _selectedPolo = polo;
                      });
                    },
                    onBackToMap: () {},
                    onStateHover: (stateName) {
                      setState(() {
                        _hoveredStateName = stateName;
                      });
                    },
                  ),
                ),
              )
            else
              // Mapa del estado seleccionado SIN zoom (solo después de confirmar)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    MexicoMapWidget(
                      selectedStateCode: _selectedStateCode,
                      highlightedStates: _statePoloData.keys.toList(),
                      autoShowDetail: true, // En el estado confirmado SÍ mostrar detalle
                      onStateSelected: (code, name) {},
                      onPoloSelected: (polo) {
                        setState(() {
                          _selectedPolo = polo;
                        });
                      },
                      onBackToMap: () {
                        setState(() {
                          _selectedStateCode = null;
                          _selectedStateName = null;
                          _selectedPolo = null;
                        });
                      },
                      onStateHover: (stateName) {
                        setState(() {
                          _hoveredStateName = stateName;
                        });
                      },
                    ),
                    // Botón X para deseleccionar el estado
                    // Positioned(
                    //   top: 12,
                    //   right: 12,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       setState(() {
                    //         _selectedStateCode = null;
                    //         _selectedStateName = null;
                    //         _selectedPolo = null;
                    //       });
                    //     },
                    //     child: Container(
                    //       padding: const EdgeInsets.all(8),
                    //       decoration: BoxDecoration(
                    //         color: isDark
                    //             ? Colors.black.withValues(alpha: 0.6)
                    //             : Colors.white.withValues(alpha: 0.95),
                    //         borderRadius: BorderRadius.circular(10),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withValues(alpha: 0.1),
                    //             blurRadius: 6,
                    //             offset: const Offset(0, 2),
                    //           ),
                    //         ],
                    //       ),
                    //       // child: Icon(
                    //       //   Icons.close_rounded,
                    //       //   size: 20,
                    //       //   color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    //       // ),
                    //     ),
                    //   ),
                    // ),
                    // Nombre del estado seleccionado
                    // Positioned(
                    //   top: 12,
                    //   left: 12,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       gradient: const LinearGradient(
                    //         begin: Alignment.topLeft,
                    //         end: Alignment.bottomRight,
                    //         colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: const Color(0xFF691C32).withValues(alpha: 0.3),
                    //           blurRadius: 8,
                    //           offset: const Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: Text(
                    //       _selectedStateName ?? '',
                    //       style: const TextStyle(
                    //         fontSize: 13,
                    //         fontWeight: FontWeight.w600,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            
            // Nombre del estado pendiente de confirmar (solo cuando hay confirmación pendiente)
            if (_showMobileConfirmation && _pendingStateName != null && _selectedStateCode == null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildMobileStateLabel(isDark),
              ),
            
            // Botones de confirmación para móvil (solo cuando no hay estado seleccionado)
            if (_showMobileConfirmation && _selectedStateCode == null)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildMobileConfirmationButtons(isDark),
              ),
            
            // Instrucciones de zoom (solo cuando no hay selección pendiente ni estado seleccionado)
            if (!_showMobileConfirmation && _selectedStateCode == null)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _selectedStateName == null ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pinch_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pellizca para hacer zoom',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
            // Botón para restablecer zoom (solo cuando no hay estado seleccionado)
            if (_selectedStateCode == null)
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: !_showMobileConfirmation ? 1.0 : 0.3,
                  child: GestureDetector(
                    onTap: _resetZoom,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.zoom_out_map_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStateLabel(bool isDark) {
    // Escalar inversamente al zoom (más zoom = más pequeño)
    // Cuando zoom es 1.0, escala es 1.0
    // Cuando zoom es 6.0, escala es ~0.4
    final scale = (1.0 / _currentZoom).clamp(0.3, 1.0);
    
    return Center(
      child: Transform.scale(
        scale: scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF691C32),
                const Color(0xFF691C32).withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF691C32).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              _pendingStateName ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMobileConfirmationButtons(bool isDark) {
    return Row(
      children: [
        // Botón Cancelar
        Expanded(
          child: GestureDetector(
            onTap: _cancelMobileSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Confirmar
        Expanded(
          child: GestureDetector(
            onTap: _confirmMobileSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF691C32).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _cancelMobileSelection() {
    setState(() {
      _pendingStateCode = null;
      _pendingStateName = null;
      _showMobileConfirmation = false;
    });
    // Restablecer el zoom
    _resetZoom();
  }

  void _confirmMobileSelection() {
    if (_pendingStateCode != null && _pendingStateName != null) {
      // Restablecer el zoom antes de mostrar el estado
      _resetZoom();
      setState(() {
        _selectedStateCode = _pendingStateCode;
        _selectedStateName = _pendingStateName;
        _pendingStateCode = null;
        _pendingStateName = null;
        _showMobileConfirmation = false;
        _selectedPolo = null;
      });
    }
  }

  Widget _buildMapContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            MexicoMapWidget(
              selectedStateCode: _selectedStateCode,
              highlightedStates: _statePoloData.keys.toList(),
              onStateSelected: (code, name) {
                setState(() {
                  _selectedStateCode = code.isEmpty ? null : code;
                  _selectedStateName = name.isEmpty ? null : name;
                  _selectedPolo = null;
                });
              },
              onPoloSelected: (polo) {
                setState(() {
                  _selectedPolo = polo;
                });
              },
              onBackToMap: () {},
              onStateHover: (stateName) {
                setState(() {
                  _hoveredStateName = stateName;
                });
              },
            ),
            // Indicador de instrucciones
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _selectedStateName == null ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mouse_rounded,
                          size: 16,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pasa el cursor sobre un estado para elevarlo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: _selectedPolo != null
          ? _buildPoloInfo(isDark)
          : (_selectedStateName == null
                ? _buildEmptyState(isDark)
                : _buildStateInfo(isDark)),
    );
  }

  Widget _buildPoloInfo(bool isDark) {
    final polo = _selectedPolo!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón para volver
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPolo = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Información del Polo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Imagen principal
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPoloImage(
                polo.imagenes.isNotEmpty ? polo.imagenes[0] : '',
                isDark,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tipo de polo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nuevo Polo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Nombre del polo
          Text(
            polo.nombre,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),

          // Ubicación
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                polo.ubicacion,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            polo.descripcion,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Botón "Ir al lugar"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Abrir en Google Maps o navegador
                _openLocation(polo.latitud, polo.longitud);
              },
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Visitar virtualmente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Botón "Ir al lugar"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Abrir en Google Maps o navegador
                _openLocation(polo.latitud, polo.longitud);
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Dar mi punto de vista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLocation(double lat, double lng) {
    // Por ahora solo muestra un snackbar, pero aquí puedes implementar
    // la navegación a Google Maps usando url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo ubicación: $lat, $lng'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPoloImage(String imagePath, bool isDark) {
    if (imagePath.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
        child: Center(
          child: Icon(
            Icons.image_rounded,
            size: 48,
            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    // Si es una imagen local (assets)
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error cargando imagen: $error');
          return Container(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar imagen',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Si es una imagen de red
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          child: Center(
            child: Icon(
              Icons.image_rounded,
              size: 48,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: En marcha | A licitar o en proceso
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  isDark,
                  color: const Color(0xFF006847),
                  label: 'En marcha',
                  isSelected: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryButton(
                  isDark,
                  color: const Color(0xFFB8D4B8),
                  label: 'A licitar o en proceso',
                  isSelected: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila 2: Nuevos polos | En proceso de evaluación
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  isDark,
                  color: const Color(0xFF2563EB),
                  label: 'Nuevos polos',
                  isSelected: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryButton(
                  isDark,
                  color: const Color(0xFFE89005),
                  label: 'En proceso de evaluación',
                  isSelected: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila 3: Tercera etapa
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  isDark,
                  color: const Color(0xFFD4B896),
                  label: 'Tercera etapa: en evaluación',
                  isSelected: false,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // Espacio vacío
            ],
          ),

          const SizedBox(height: 32),

          // Sectores estratégicos
          if (_hoveredStateName == null ||
              (_hoveredStateName != null &&
                  _stateSectors.containsKey(_hoveredStateName)))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hoveredStateName != null &&
                      _stateSectors.containsKey(_hoveredStateName)) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Sectores en $_hoveredStateName',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    ..._buildDynamicSectors(
                      _stateSectors[_hoveredStateName]!,
                      isDark,
                    ),
                  ] else ...[
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.agriculture_rounded,
                        'Agroindustria',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.recycling_rounded,
                        'Economía circular',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.flight_rounded,
                        'Aeroespacial',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.wb_sunny_rounded,
                        'Energías limpias',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.electric_car_rounded,
                        'Automotriz y electromovilidad',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.factory_rounded,
                        'Industrias metálicas básicas',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.shopping_bag_rounded,
                        'Bienes de consumo',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.description_rounded,
                        'Industria del papel',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.medical_services_rounded,
                        'Farmacéutica y dispositivos médicos',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.science_rounded,
                        'Industria del plástico',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.memory_rounded,
                        'Electrónica y semiconductores',
                        isDark,
                      ),
                      _buildSectorItem(
                        Icons.local_shipping_rounded,
                        'Logística',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(Icons.bolt_rounded, 'Energía', isDark),
                      _buildSectorItem(
                        Icons.precision_manufacturing_rounded,
                        'Metalmecánica',
                        isDark,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.science_outlined,
                        'Química y petroquímica',
                        isDark,
                      ),
                      const Expanded(child: SizedBox()),
                    ]),
                    const SizedBox(height: 12),
                    _buildSectorRow([
                      _buildSectorItem(
                        Icons.checkroom_rounded,
                        'Textil y calzado',
                        isDark,
                      ),
                      const Expanded(child: SizedBox()),
                    ]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    bool isDark, {
    required Color color,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.15)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? color
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE5E7EB)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(List<Widget> children) {
    return Row(children: children);
  }

  List<Widget> _buildDynamicSectors(List<String> sectors, bool isDark) {
    final List<Widget> rows = [];
    for (int i = 0; i < sectors.length; i += 2) {
      final item1 = sectors[i];
      final item2 = (i + 1 < sectors.length) ? sectors[i + 1] : null;

      rows.add(
        _buildSectorRow([
          _buildSectorItem(_getIconForSector(item1), item1, isDark),
          if (item2 != null)
            _buildSectorItem(_getIconForSector(item2), item2, isDark)
          else
            const Expanded(child: SizedBox()),
        ]),
      );
      if (i + 2 < sectors.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    return rows;
  }

  IconData _getIconForSector(String sector) {
    final lower = sector.toLowerCase();
    if (lower.contains('agro')) return Icons.agriculture_rounded;
    if (lower.contains('auto')) return Icons.electric_car_rounded;
    if (lower.contains('aero')) return Icons.flight_rounded;
    if (lower.contains('semi') || lower.contains('electrónica'))
      return Icons.memory_rounded;
    if (lower.contains('energía')) return Icons.bolt_rounded;
    if (lower.contains('bienes')) return Icons.shopping_bag_rounded;
    if (lower.contains('textil')) return Icons.checkroom_rounded;
    if (lower.contains('química') || lower.contains('plástico'))
      return Icons.science_outlined;
    if (lower.contains('logística')) return Icons.local_shipping_rounded;
    if (lower.contains('turismo')) return Icons.beach_access_rounded;
    if (lower.contains('farmacéutica') || lower.contains('médicos'))
      return Icons.medical_services_rounded;
    if (lower.contains('metal')) return Icons.precision_manufacturing_rounded;
    return Icons.business_rounded;
  }

  Widget _buildSectorItem(IconData icon, String label, bool isDark) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateInfo(bool isDark) {
    final poloData = _selectedStateName != null
        ? _statePoloData[_selectedStateName]
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF691C32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Color(0xFF691C32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStateName ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Código: ${_selectedStateCode ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estadísticas
          _buildStatCard(
            isDark,
            icon: Icons.business_rounded,
            title: 'Polos de desarrollo',
            value: poloData?.count.toString() ?? '0',
            subtitle: 'En este estado',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.people_rounded,
            title: 'Población beneficiada',
            value: '--',
            subtitle: 'Habitantes',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.trending_up_rounded,
            title: 'Inversión proyectada',
            value: '--',
            subtitle: 'MXN',
          ),

          if (poloData != null && poloData.descriptions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Detalle de Polos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...poloData.descriptions.map(
              (desc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navegar a detalle del estado
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF691C32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ver detalles del estado',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF691C32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF691C32), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
