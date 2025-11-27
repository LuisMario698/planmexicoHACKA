import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/mexico_map_widget.dart';
import '../data/polos_data.dart';
import 'encuesta_polo_screen.dart';
import '../../service/encuesta_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/polos_tutorial_overlay.dart'; // Tutorial para el mapa
import '../widgets/state_tutorial_overlay.dart'; // Tutorial para estados
import '../widgets/polo_tutorial_overlay.dart'; // Tutorial para polos
import '../widgets/webview_dialog.dart'; // WebView para explorar polos
import '../widgets/polo_infografia_widget.dart'; // Infografía para compartir

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

class StateDetailData {
  final String poloOficial;
  final List<String> sectoresFuertes;
  final String poblacion;
  final String conectividad;
  final String superficie;
  final String inversion;
  final String poblacionBeneficiada;
  final String empleos;
  final String nombrePolo;
  final String municipio;
  final String sectorPolo;
  final String vocacion;
  final String organismos;
  final String oportunidades;
  final String beneficios;
  final List<String> proyectosFederales;

  const StateDetailData({
    required this.poloOficial,
    required this.sectoresFuertes,
    required this.poblacion,
    required this.conectividad,
    this.superficie = 'N.D.',
    this.inversion = 'N.D.',
    this.poblacionBeneficiada = 'N.D.',
    this.empleos = 'En integración',
    required this.nombrePolo,
    required this.municipio,
    required this.sectorPolo,
    required this.vocacion,
    required this.organismos,
    this.oportunidades = '',
    this.beneficios = '',
    required this.proyectosFederales,
  });
}

class _PolosScreenState extends State<PolosScreen>
    with TickerProviderStateMixin {
  String? _selectedStateCode;
  String? _selectedStateName;
  String? _hoveredStateName;
  PoloInfo? _selectedPolo;
  bool _showDetailedInfo = false;

  // Animación de expansión del mini mapa
  late AnimationController _expandController;
  bool _isExpanding = false;
  bool _isCollapsing = false; // Para animación inversa

  // Controller para capturar screenshots
  final ScreenshotController _screenshotController = ScreenshotController();

  // Variables para el tutorial
  bool _showTutorial = false;
  late GlobalKey _mapContainerKey;
  bool _mapUnlocked = false;

  // Variables para el tutorial de estado
  bool _showStateTutorial = false;
  late GlobalKey _stateInfoPanelKey;
  bool _stateUnlocked = false;

  // Variables para el tutorial de polo (múltiples pasos)
  bool _showPoloTutorial = false;
  int _poloTutorialStep = 1;
  late GlobalKey _poloHeaderKey;
  late GlobalKey _poloSectoresKey;
  late GlobalKey _explorarButtonKey;
  late GlobalKey _opinarButtonKey;
  bool _poloTutorialCompleted = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandController.addListener(() => setState(() {}));
    _mapContainerKey = GlobalKey();
    _stateInfoPanelKey = GlobalKey();
    _poloHeaderKey = GlobalKey();
    _poloSectoresKey = GlobalKey();
    _explorarButtonKey = GlobalKey();
    _opinarButtonKey = GlobalKey();
    _checkIfShowTutorial();
  }

  Future<void> _checkIfShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('polos_tutorial_seen') ?? false;

    if (mounted && !hasSeenTutorial) {
      // Esperar a que el widget se dibuje completamente
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showTutorial = true);
        }
      });
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('polos_tutorial_seen', true);
  }

  Future<void> _checkIfShowStateTutorial(String stateName) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenStateTutorial =
        prefs.getBool('polos_state_tutorial_seen_$stateName') ?? false;

    if (mounted && !hasSeenStateTutorial) {
      // Esperar a que el widget se dibuje completamente
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showStateTutorial = true);
        }
      });
    }
  }

  Future<void> _completeStateTutorial(String stateName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('polos_state_tutorial_seen_$stateName', true);
  }

  Future<void> _checkIfShowPoloTutorial(PoloInfo polo) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenPoloTutorial =
        prefs.getBool('polos_polo_tutorial_seen_${polo.id}') ?? false;

    if (mounted && !hasSeenPoloTutorial) {
      // Esperar a que el widget se dibuje completamente
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showPoloTutorial = true;
            _poloTutorialStep = 1;
            _poloTutorialCompleted = false;
          });
        }
      });
    }
  }

  void _nextPoloTutorialStep() {
    if (_poloTutorialStep < 4) {
      setState(() {
        _poloTutorialStep++;
      });
    } else {
      // Tutorial completado
      _completePoloTutorial();
    }
  }

  Future<void> _completePoloTutorial() async {
    if (_selectedPolo != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'polos_polo_tutorial_seen_${_selectedPolo!.id}',
        true,
      );
    }

    if (mounted) {
      setState(() {
        _showPoloTutorial = false;
        _poloTutorialStep = 1;
        _poloTutorialCompleted = true;
      });
    }
  }

  void _skipPoloTutorial() {
    if (mounted) {
      setState(() {
        _showPoloTutorial = false;
        _poloTutorialStep = 1;
      });
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

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

  final Map<String, StateDetailData> _stateDetailData = {
    'Sonora': const StateDetailData(
      poloOficial:
          'PODECOBI Hermosillo – Polo de Desarrollo Económico para el Bienestar e Innovación',
      sectoresFuertes: [
        'Minería (cobre, oro)',
        'Energía solar',
        'Manufactura',
        'Agroindustria',
        'Logística fronteriza',
      ],
      poblacion: '2.94 millones',
      conectividad:
          'Puerto de Guaymas, aeropuertos de Hermosillo y Ciudad Obregón, corredor carretero hacia Nogales y Cd. Juárez',
      superficie: 'En proceso de publicación',
      poblacionBeneficiada: '+1 millón de hab.',
      nombrePolo:
          'Polo de Desarrollo Económico para el Bienestar e Innovación de Hermosillo',
      municipio: 'Hermosillo',
      sectorPolo:
          'Manufactura avanzada, servicios tecnológicos, energía limpia',
      vocacion:
          'Innovación, tecnología, electromovilidad, semiconductores y cadenas de suministro ligadas a EE.UU.',
      organismos:
          'Secretaría de Economía federal, Gobierno de Sonora; se coordina con la agenda de Plan Sonora',
      oportunidades:
          'Parques industriales con energía solar, proveedores automotrices/EV, centros de datos, ensamble electrónico',
      beneficios:
          'Empleo calificado, infraestructura industrial, fortalecimiento de universidades y centros de I+D',
      proyectosFederales: [
        'PODECOBI Hermosillo',
        'Terminal especializada en graneles minerales en el puerto de Guaymas',
      ],
    ),
    'Tamaulipas': const StateDetailData(
      poloOficial: 'PODECOBI Altamira',
      sectoresFuertes: [
        'Energético (gas, petróleo)',
        'Petroquímico',
        'Automotriz/autopartes',
        'Logística portuaria',
        'Manufactura',
      ],
      poblacion: '3.53 millones',
      conectividad:
          'Puerto industrial de Altamira, cercanía con Tampico-Madero, corredor carretero Altamira–Monterrey, aeropuerto internacional de Tampico',
      superficie: '≈ 1,637.78 ha',
      poblacionBeneficiada: '≈ 905 mil habitantes',
      nombrePolo: 'PODECOBI Altamira',
      municipio: 'Altamira',
      sectorPolo: 'Industria / logística',
      vocacion: 'Clúster energético-industrial con salida marítima',
      organismos:
          'Secretaría de Economía, Gobierno de Tamaulipas; coordinación con SEMARNAT y autoridades portuarias',
      beneficios:
          'Consolidar el corredor industrial del sur de Tamaulipas, atracción de empresas de nearshoring, más empleo y derrama en servicios',
      proyectosFederales: [
        'PODECOBI Altamira',
        'Proyectos de infraestructura portuaria y energética en Tampico/Altamira',
      ],
    ),
    'Durango': const StateDetailData(
      poloOficial: 'PODECOBI Centro Logístico e Industrial de Durango (CLID)',
      sectoresFuertes: [
        'Automotriz-autopartes',
        'Agroindustria',
        'Manufactura ligera',
        'Logística hacia el norte y al puerto de Mazatlán',
      ],
      poblacion: 'N.D.',
      conectividad: 'Corredor económico del norte',
      superficie: '315.41 ha',
      nombrePolo: 'CLID Durango',
      municipio: 'Durango',
      sectorPolo: 'Industria / logística',
      vocacion:
          'Parque logístico-industrial con enfoque en manufactura y distribución hacia el norte y Golfo de California',
      organismos: 'Secretaría de Economía, Gobierno de Durango',
      proyectosFederales: ['CLID Durango (PODECOBI)'],
    ),
    'Puebla': const StateDetailData(
      poloOficial:
          'PODECOBI Futura Capital de la Tecnología y la Sostenibilidad',
      sectoresFuertes: [
        'Automotriz (VW y proveedores)',
        'Electrónica',
        'Agroindustria',
        'Servicios',
        'Tecnologías avanzadas',
      ],
      poblacion: 'N.D.',
      conectividad: 'Conectividad regional centro',
      superficie: '~220 ha',
      nombrePolo: 'Futura Capital de la Tecnología y la Sostenibilidad',
      municipio: 'San José Chiapa y Nopalucan',
      sectorPolo: 'Industria / tecnología',
      vocacion:
          'Electromovilidad, manufactura avanzada, economía verde y servicios tecnológicos',
      organismos: 'Secretaría de Economía, Gobierno de Puebla',
      proyectosFederales: [
        'PODECOBI Futura Capital de la Tecnología y la Sostenibilidad',
      ],
    ),
    'Guanajuato': const StateDetailData(
      poloOficial: 'PODECOBI Puerta Logística del Bajío (Celaya)',
      sectoresFuertes: [
        'Automotriz',
        'Autopartes',
        'Agroindustria',
        'Cuero-calzado',
        'Plásticos',
        'Logística',
      ],
      poblacion: '≈ 6.17 millones',
      conectividad: 'Logística multimodal para el Bajío',
      superficie: '52.40 ha',
      nombrePolo: 'Puerta Logística del Bajío',
      municipio: 'Celaya',
      sectorPolo: 'Logística / Industrial',
      vocacion:
          'Logística multimodal para el Bajío, manufactura y cadenas de suministro automotrices y agroindustriales',
      organismos: 'Secretaría de Economía, Gobierno de Guanajuato',
      proyectosFederales: ['PODECOBI Puerta Logística del Bajío'],
    ),
    'Estado de México': const StateDetailData(
      poloOficial: 'PODECOBI Nezahualcóyotl',
      sectoresFuertes: [
        'Manufactura (automotriz, química, alimentos)',
        'Logística metropolitana',
        'Servicios',
        'Comercio',
      ],
      poblacion: 'N.D.',
      conectividad: 'Logística metropolitana ZMVM',
      superficie: 'En publicación',
      nombrePolo: 'PODECOBI Nezahualcóyotl',
      municipio: 'Nezahualcóyotl',
      sectorPolo: 'Servicios / Logística',
      vocacion:
          'Servicios, logística urbana, reconversión industrial y economía circular para el oriente del Valle de México',
      organismos: 'Secretaría de Economía, Gobierno del Estado de México',
      proyectosFederales: [
        'PODECOBI Nezahualcóyotl',
        'Tren México-Toluca (asociado)',
      ],
    ),
    'Veracruz': const StateDetailData(
      poloOficial: 'PODECOBI Tuxpan',
      sectoresFuertes: [
        'Petróleo y petroquímica',
        'Energético',
        'Agroindustria',
        'Portuario-logístico',
      ],
      poblacion: 'N.D.',
      conectividad: 'Puerto de Tuxpan, Corredor Interoceánico',
      superficie: '≈ 235 ha',
      nombrePolo: 'PODECOBI Tuxpan',
      municipio: 'Tuxpan',
      sectorPolo: 'Industria / logística portuaria',
      vocacion:
          'Polo energético-logístico para el norte de Veracruz (hidrocarburos, carga general, agroexportación)',
      organismos: 'Secretaría de Economía, Gobierno de Veracruz',
      proyectosFederales: [
        'PODECOBI Tuxpan',
        'Proyectos del Corredor Interoceánico',
      ],
    ),
    'Campeche': const StateDetailData(
      poloOficial: 'PODECOBI Seybaplaya I',
      sectoresFuertes: [
        'Hidrocarburos costa afuera',
        'Logística portuaria',
        'Pesca',
        'Agroindustria',
        'Turismo',
      ],
      poblacion: 'N.D.',
      conectividad: 'Puerto de Seybaplaya',
      superficie: '≈ 99.98 ha',
      nombrePolo: 'PODECOBI Seybaplaya I',
      municipio: 'Seybaplaya',
      sectorPolo: 'Industria / logística',
      vocacion:
          'Logística ligada al Golfo de México, industrias vinculadas a energía, agroindustria y manufactura ligera',
      organismos: 'Secretaría de Economía, Gobierno de Campeche',
      proyectosFederales: ['PODECOBI Seybaplaya I'],
    ),
  };

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
              ? [const Color(0xFF13151A), const Color(0xFF1E2029)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
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
          // Tutorial Overlay - Mapa
          if (_showTutorial && !_mapUnlocked) _buildTutorialOverlay(),
          // Tutorial Overlay - Estado
          if (_showStateTutorial &&
              !_stateUnlocked &&
              _selectedStateName != null)
            _buildStateTutorialOverlay(),
          // Tutorial Overlay - Polo
          if (_showPoloTutorial && _selectedPolo != null)
            _buildPoloTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return PolosTutorialOverlay(
      targetRect: _getMapTargetRect(),
      onTargetTap: () {
        setState(() => _mapUnlocked = true);
        // El tutorial se cierra después de desbloquear el mapa
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _showTutorial = false);
            _completeTutorial();
          }
        });
      },
      onSkip: () {
        setState(() => _showTutorial = false);
        _completeTutorial();
      },
    );
  }

  Rect _getMapTargetRect() {
    final RenderBox? renderBox =
        _mapContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }
    // Rect por defecto si no se puede obtener
    return Rect.fromLTWH(0, 200, 400, 300);
  }

  Widget _buildStateTutorialOverlay() {
    return StateTutorialOverlay(
      targetRect: _getStateInfoPanelRect(),
      onTargetTap: () {
        setState(() => _stateUnlocked = true);
        // El tutorial se cierra después de desbloquear el panel
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _selectedStateName != null) {
            setState(() => _showStateTutorial = false);
            _completeStateTutorial(_selectedStateName!);
          }
        });
      },
      onSkip: () {
        setState(() => _showStateTutorial = false);
        if (_selectedStateName != null) {
          _completeStateTutorial(_selectedStateName!);
        }
      },
    );
  }

  Rect _getStateInfoPanelRect() {
    final RenderBox? renderBox =
        _stateInfoPanelKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }
    // Rect por defecto si no se puede obtener
    return Rect.fromLTWH(0, 300, 400, 300);
  }

  Widget _buildPoloTutorialOverlay() {
    Rect? targetRect;

    // Determinar qué elemento mostrar según el paso
    switch (_poloTutorialStep) {
      case 1:
        // Paso 1: Información general (sin target específico)
        return PoloTutorialOverlay(
          step: 1,
          targetRect: null,
          onNext: _nextPoloTutorialStep,
          onSkip: _skipPoloTutorial,
        );
      case 2:
        // Paso 2: Sectores clave
        targetRect = _getPoloElementRect(_poloSectoresKey);
      case 3:
        // Paso 3: Botón Explorar
        targetRect = _getPoloElementRect(_explorarButtonKey);
      case 4:
        // Paso 4: Botón Opinar
        targetRect = _getPoloElementRect(_opinarButtonKey);
      default:
        return const SizedBox.shrink();
    }

    return PoloTutorialOverlay(
      step: _poloTutorialStep,
      targetRect: targetRect,
      onNext: _nextPoloTutorialStep,
      onSkip: _skipPoloTutorial,
    );
  }

  Rect _getPoloElementRect(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }
    // Rect por defecto si no se puede obtener
    return Rect.fromLTWH(0, 400, 300, 60);
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
    // Animación de expansión o colapso en progreso
    if (_isExpanding) {
      return _buildExpandingMapAnimation(isDark);
    }
    if (_isCollapsing) {
      return _buildCollapsingMapAnimation(isDark);
    }

    // Si hay un polo seleccionado, mostrar layout scrolleable con mini preview
    if (_selectedPolo != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini mapa preview
            _buildMiniMapPreview(isDark),
            const SizedBox(height: 12),
            // Panel de información expandido (sin scroll interno)
            _buildInfoPanelNoScroll(isDark),
            // Espacio extra al final para mejor scroll
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    // Si hay un estado seleccionado (pero no polo), mostrar mapa del estado + info scrolleable
    else if (_selectedStateName != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mapa del estado (altura fija) - usa showOnlySelected para evitar animación de México
            SizedBox(height: 350, child: _buildStateOnlyMapContainer(isDark)),
            const SizedBox(height: 16),
            // Panel de información del estado desplegado
            _buildStateInfoPanel(isDark),
            // Espacio extra al final
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    // Sin nada seleccionado: mapa + leyenda + sectores todo scrolleable
    else {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mapa con altura fija
            SizedBox(height: 380, child: _buildMapContainer(isDark)),
            const SizedBox(height: 16),
            // Panel inicial expandido (leyenda + sectores)
            _buildInitialInfoPanel(isDark),
            // Espacio extra al final
            const SizedBox(height: 20),
          ],
        ),
      );
    }
  }

  // Contenedor del mapa que solo muestra el estado seleccionado (sin animación de México)
  Widget _buildStateOnlyMapContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
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
        child: MexicoMapWidget(
          selectedStateCode: _selectedStateCode,
          selectedPoloId: _selectedPolo?.id,
          highlightedStates: _statePoloData.keys.toList(),
          showOnlySelected: true, // CLAVE: Solo muestra el estado, no México
          hidePoloMarkers: false,
          skipInitialAnimation: true,
          onStateSelected: (code, name) {
            // Volver al mapa completo
            setState(() {
              _selectedStateCode = null;
              _selectedStateName = null;
              _selectedPolo = null;
              _showDetailedInfo = false;
            });
          },
          onPoloSelected: (polo) {
            setState(() {
              _selectedPolo = polo;
              _showDetailedInfo = false;
            });
            // Mostrar tutorial del polo si aún no lo ha visto
            _checkIfShowPoloTutorial(polo);
          },
          onBackToMap: () {
            setState(() {
              _selectedStateCode = null;
              _selectedStateName = null;
            });
          },
          onStateHover: (stateName) {
            setState(() {
              _hoveredStateName = stateName;
            });
          },
        ),
      ),
    );
  }

  // Animación de expansión del mini mapa - transición simple y fluida
  Widget _buildExpandingMapAnimation(bool isDark) {
    // Usar curva suave
    final curvedProgress = Curves.easeOutCubic.transform(
      _expandController.value,
    );

    // Solo animar la altura del contenedor y opacidad
    final mapHeight = 110.0 + (curvedProgress * 240.0); // 110 -> 350
    final panelOpacity = Curves.easeIn.transform(
      ((_expandController.value - 0.4) / 0.6).clamp(0.0, 1.0),
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contenedor del mapa que se expande suavemente
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: mapHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2029) : Colors.white,
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
              child: MexicoMapWidget(
                key: const ValueKey('expanding_state'),
                selectedStateCode: _selectedStateCode,
                selectedPoloId: _selectedPolo?.id,
                highlightedStates: _statePoloData.keys.toList(),
                showOnlySelected: true,
                hidePoloMarkers: false,
                skipInitialAnimation: true,
                onStateSelected: (_, __) {},
                onPoloSelected: (polo) {
                  _expandController.stop();
                  setState(() {
                    _selectedPolo = polo;
                    _isExpanding = false;
                  });
                  // Mostrar tutorial del polo si aún no lo ha visto
                  _checkIfShowPoloTutorial(polo);
                },
                onBackToMap: () {},
                onStateHover: (_) {},
              ),
            ),
          ),

          // Panel de información del estado (aparece con fade)
          const SizedBox(height: 16),
          Opacity(opacity: panelOpacity, child: _buildStateInfoPanel(isDark)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Animación de colapso - transición inversa (de estado a mini preview)
  Widget _buildCollapsingMapAnimation(bool isDark) {
    // Usar curva suave inversa
    final curvedProgress = Curves.easeInCubic.transform(
      _expandController.value,
    );

    // Animar la altura del contenedor de forma inversa
    final mapHeight = 110.0 + (curvedProgress * 240.0); // 350 -> 110

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contenedor del mapa que se colapsa suavemente
          AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: mapHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2029) : Colors.white,
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
              child: MexicoMapWidget(
                key: const ValueKey('collapsing_state'),
                selectedStateCode: _selectedStateCode,
                selectedPoloId: _selectedPolo?.id,
                highlightedStates: _statePoloData.keys.toList(),
                showOnlySelected: true,
                hidePoloMarkers: false,
                skipInitialAnimation: true,
                onStateSelected: (_, __) {},
                onPoloSelected: (_) {},
                onBackToMap: () {},
                onStateHover: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Mini preview del mapa cuando hay polo seleccionado en móvil
  Widget _buildMiniMapPreview(bool isDark) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Info del estado
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF691C32), Color(0xFF4A1525)],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedStateName ?? 'Estado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Código: ${_selectedStateCode ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 13,
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
              ),
              // Botón con silueta del estado para volver al mapa completo
              GestureDetector(
                onTap: () {
                  // Iniciar animación de expansión
                  setState(() {
                    _isExpanding = true;
                  });
                  _expandController.forward(from: 0).then((_) {
                    // Al terminar la animación, simplemente desactivar el modo expansión
                    // El layout ya está mostrando el estado final
                    if (mounted) {
                      setState(() {
                        _selectedPolo = null;
                        _showDetailedInfo = false;
                        _isExpanding = false;
                      });
                    }
                  });
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262830)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3A3D47)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      children: [
                        // Mini silueta del estado
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: MexicoMapWidget(
                              selectedStateCode: _selectedStateCode,
                              highlightedStates: const [],
                              showOnlySelected: true,
                              hidePoloMarkers: true,
                              onStateSelected: (_, __) {},
                            ),
                          ),
                        ),
                        // Overlay con icono de expandir
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF691C32),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
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
    );
  }

  Widget _buildMapContainer(bool isDark) {
    return Container(
      key: _mapContainerKey,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
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
              selectedPoloId: _selectedPolo?.id,
              highlightedStates: _statePoloData.keys.toList(),
              onStateSelected: (code, name) {
                setState(() {
                  _selectedStateCode = code.isEmpty ? null : code;
                  _selectedStateName = name.isEmpty ? null : name;
                  _selectedPolo = null;
                  _showDetailedInfo = false;
                  _stateUnlocked = false; // Reset estado del tutorial
                });
                // Mostrar tutorial del estado si aún no lo ha visto
                if (name.isNotEmpty) {
                  _checkIfShowStateTutorial(name);
                }
              },
              onPoloSelected: (polo) {
                setState(() {
                  _selectedPolo = polo;
                  _showDetailedInfo = false;
                });
                // Mostrar tutorial del polo si aún no lo ha visto
                _checkIfShowPoloTutorial(polo);
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
                          ? const Color(0xFF262830).withValues(alpha: 0.95)
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
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
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

  // Panel de información sin scroll interno (para móvil con scroll de pantalla completa)
  Widget _buildInfoPanelNoScroll(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
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
          ? _buildPoloInfoNoScroll(isDark)
          : (_selectedStateName == null
                ? _buildEmptyState(isDark)
                : _buildStateInfo(isDark)),
    );
  }

  // Panel inicial para móvil - leyenda + sectores desplegados
  Widget _buildInitialInfoPanel(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Leyenda de Polos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          // Título sectores
          Text(
            'Sectores Estratégicos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // Sectores estratégicos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262830) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF3A3D47)
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
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
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
                    _buildSectorItem(
                      Icons.checkroom_rounded,
                      'Textil y calzado',
                      isDark,
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Versión de PoloInfo sin scroll interno
  Widget _buildPoloInfoNoScroll(bool isDark) {
    final polo = _selectedPolo!;

    // Obtener información adicional del polo desde PolosData
    final poloData = PolosData.getPoloByStringId(polo.id);

    // Colores del tema del programa
    final cardColor = isDark ? const Color(0xFF262830) : Colors.white;
    final surfaceColor = isDark
        ? const Color(0xFF1E2029)
        : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? const Color(0xFF3A3D47)
        : const Color(0xFFE5E7EB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_showDetailedInfo) {
                    setState(() {
                      _showDetailedInfo = false;
                    });
                  } else {
                    // Animación de colapso al volver
                    setState(() {
                      _isCollapsing = true;
                    });
                    _expandController.reverse(from: 1.0).then((_) {
                      if (mounted) {
                        setState(() {
                          _selectedPolo = null;
                          _isCollapsing = false;
                        });
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF691C32).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      polo.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _showDetailedInfo ? 'Información detallada' : polo.estado,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFA0A0A0)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Contenido (sin scroll, se despliega completo)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _showDetailedInfo
              ? _buildDetailedContent(
                  isDark,
                  poloData,
                  polo,
                  cardColor,
                  borderColor,
                )
              : _buildSummaryContent(
                  isDark,
                  poloData,
                  polo,
                  cardColor,
                  borderColor,
                ),
        ),

        // Botones
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  key: _explorarButtonKey,
                  child: _buildActionButton(
                    icon: Icons.explore_rounded,
                    label: 'Explorar',
                    color: const Color(0xFF691C32),
                    onTap: () => _handleExplorarPolo(polo),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Compartir',
                  color: const Color(0xFFBC955C),
                  onTap: () => _sharePolo(polo, poloData),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  key: _opinarButtonKey,
                  child: _buildActionButton(
                    icon: Icons.rate_review_rounded,
                    label: 'Opinar',
                    color: const Color(0xFF2563EB),
                    onTap: () => _showFeedbackDialog(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoloInfo(bool isDark) {
    final polo = _selectedPolo!;

    // Obtener información adicional del polo desde PolosData
    final poloData = PolosData.getPoloByStringId(polo.id);

    // Colores del tema del programa
    final cardColor = isDark ? const Color(0xFF262830) : Colors.white;
    final surfaceColor = isDark
        ? const Color(0xFF1E2029)
        : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? const Color(0xFF3A3D47)
        : const Color(0xFFE5E7EB);

    return Column(
      children: [
        // Header fijo
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(
                color: borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_showDetailedInfo) {
                    setState(() {
                      _showDetailedInfo = false;
                    });
                  } else {
                    // Animación de colapso al volver
                    setState(() {
                      _isCollapsing = true;
                    });
                    _expandController.reverse(from: 1.0).then((_) {
                      if (mounted) {
                        setState(() {
                          _selectedPolo = null;
                          _isCollapsing = false;
                        });
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF691C32).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      polo.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _showDetailedInfo ? 'Información detallada' : polo.estado,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFA0A0A0)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16),
            child: _showDetailedInfo
                ? _buildDetailedContent(
                    isDark,
                    poloData,
                    polo,
                    cardColor,
                    borderColor,
                  )
                : _buildSummaryContent(
                    isDark,
                    poloData,
                    polo,
                    cardColor,
                    borderColor,
                  ),
          ),
        ),

        // Botones fijos en la parte inferior
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              top: BorderSide(
                color: borderColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  key: _explorarButtonKey,
                  child: _buildActionButton(
                    icon: Icons.explore_rounded,
                    label: 'Explorar',
                    color: const Color(0xFF691C32),
                    onTap: () => _handleExplorarPolo(polo),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Compartir',
                  color: const Color(0xFFBC955C),
                  onTap: () => _sharePolo(polo, poloData),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  key: _opinarButtonKey,
                  child: _buildActionButton(
                    icon: Icons.rate_review_rounded,
                    label: 'Opinar',
                    color: const Color(0xFF2563EB),
                    onTap: () => _showFeedbackDialog(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contenido resumido (vista inicial) - Mini Dashboard
  Widget _buildSummaryContent(
    bool isDark,
    PoloMarker? poloData,
    PoloInfo polo,
    Color cardColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con Tipo, Región y botón Saber más
        Row(
          children: [
            _buildTypeBadge(poloData?.tipo ?? polo.tipo, poloData?.color),
            const SizedBox(width: 8),
            if (poloData?.region.isNotEmpty ?? false)
              _buildRegionBadge(poloData!.region, isDark),
            const Spacer(),
            // Botón Saber más pequeño a la derecha
            GestureDetector(
              onTap: () {
                setState(() {
                  _showDetailedInfo = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBC955C), Color(0xFFD4AF37)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBC955C).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Saber más',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dashboard - Cards horizontales de ancho completo
        // Card Empleo - Verde
        _buildDashboardCardHorizontal(
          icon: Icons.groups_rounded,
          title: 'Empleo Estimado',
          value: poloData?.empleoEstimado ?? '+10,000 empleos',
          gradientColors: [const Color(0xFF16A34A), const Color(0xFF15803D)],
        ),
        const SizedBox(height: 10),

        // Card Sectores - Naranja
        Container(
          key: _poloSectoresKey,
          child: _buildDashboardCardHorizontal(
            icon: Icons.factory_rounded,
            title: 'Sectores Clave',
            value: (poloData?.sectoresClave ?? ['Industrial', 'Tecnológico'])
                .take(3)
                .map((s) => s.split('(').first.trim())
                .join(', '),
            gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          ),
        ),
        const SizedBox(height: 10),

        // Card Infraestructura - Azul
        _buildDashboardCardHorizontal(
          icon: Icons.construction_rounded,
          title: 'Infraestructura',
          value: poloData?.infraestructura ?? 'En desarrollo',
          gradientColors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        ),
        const SizedBox(height: 10),

        // Card Beneficios - Morado
        _buildDashboardCardHorizontal(
          icon: Icons.trending_up_rounded,
          title: 'Beneficios',
          value: poloData?.beneficiosLargoPlazo ?? 'Desarrollo regional',
          gradientColors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Card horizontal de ancho completo con icono a la izquierda - Estilo sobrio
  Widget _buildDashboardCardHorizontal({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradientColors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = gradientColors[0]; // El icono mantiene su color

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262830) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
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
        children: [
          // Icono con color correspondiente
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Altura fija para todas las cards del dashboard (ya no se usa pero lo mantengo por si acaso)
  static const double _dashboardCardHeight = 140.0;

  // Card estilo dashboard con gradiente de color
  Widget _buildDashboardCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradientColors,
    required Color iconBgColor,
  }) {
    return SizedBox(
      height: _dashboardCardHeight,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Icono en círculo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const Spacer(),
            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            // Valor
            Text(
              value.length > 45 ? '${value.substring(0, 42)}...' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Card especial para sectores con tags
  Widget _buildDashboardCardSectores({
    required bool isDark,
    required List<String> sectores,
  }) {
    // Obtener los primeros 3 sectores y formatear
    final sectoresTexto = sectores
        .take(3)
        .map((sector) {
          final sectorCorto = sector.split('(').first.trim();
          return sectorCorto.length > 15
              ? '${sectorCorto.substring(0, 12)}...'
              : sectorCorto;
        })
        .join(', ');

    return SizedBox(
      height: _dashboardCardHeight,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Icono en círculo
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.factory_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Título
            Text(
              'Sectores Clave',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            // Sectores como texto normal
            Text(
              sectoresTexto,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Contenido detallado (al presionar "Saber más")
  Widget _buildDetailedContent(
    bool isDark,
    PoloMarker? poloData,
    PoloInfo polo,
    Color cardColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card de Vocación Principal
        if (poloData?.vocacion.isNotEmpty ?? false) ...[
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.hub_rounded,
            iconColor: const Color(0xFF691C32),
            title: 'Vocación Principal',
            child: Text(
              poloData!.vocacion,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFF1A1A2E),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Card de Sectores Clave (detallado)
        if (poloData?.sectoresClave.isNotEmpty ?? false) ...[
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.factory_rounded,
            iconColor: const Color(0xFF2563EB),
            title: 'Sectores Clave',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: poloData!.sectoresClave.map((sector) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sector,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFFA0A0A0)
                                : const Color(0xFF4B5563),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Card de Infraestructura
        if (poloData?.infraestructura.isNotEmpty ?? false) ...[
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.construction_rounded,
            iconColor: const Color(0xFF16A34A),
            title: 'Infraestructura',
            child: Text(
              poloData!.infraestructura,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Card de Empleo Estimado
        if (poloData?.empleoEstimado.isNotEmpty ?? false) ...[
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.groups_rounded,
            iconColor: const Color(0xFF16A34A),
            title: 'Empleo Estimado',
            child: Text(
              poloData!.empleoEstimado,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16A34A),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Card de Beneficios a Largo Plazo
        if (poloData?.beneficiosLargoPlazo.isNotEmpty ?? false) ...[
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Beneficios a Largo Plazo',
            child: Text(
              poloData!.beneficiosLargoPlazo,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Card de Descripción
        if (poloData?.descripcion.isNotEmpty ?? polo.descripcion.isNotEmpty)
          _buildSectionCard(
            isDark,
            cardColor: cardColor,
            borderColor: borderColor,
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFFBC955C),
            title: 'Descripción',
            child: Text(
              poloData?.descripcion ?? polo.descripcion,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFFA0A0A0)
                    : const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Card de highlight para información resumida
  Widget _buildHighlightCard(
    bool isDark, {
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFA0A0A0)
                        : const Color(0xFF6B7280),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFF5F5F5)
                        : const Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    bool isDark, {
    required Widget child,
    Color? cardColor,
    Color? borderColor,
  }) {
    final bgColor =
        cardColor ?? (isDark ? const Color(0xFF262830) : Colors.white);
    final border =
        borderColor ??
        (isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _buildSectionCard(
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
    Color? cardColor,
    Color? borderColor,
  }) {
    final bgColor =
        cardColor ?? (isDark ? const Color(0xFF262830) : Colors.white);
    final border =
        borderColor ??
        (isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String tipo, Color? color) {
    String label;
    Color badgeColor;
    IconData icon;

    switch (tipo) {
      case 'estrategico':
        label = 'Estratégico';
        badgeColor = const Color(0xFFF59E0B);
        icon = Icons.star_rounded;
        break;
      case 'en_marcha':
        label = 'En Marcha';
        badgeColor = const Color(0xFF16A34A);
        icon = Icons.play_circle_rounded;
        break;
      default:
        label = 'Nuevo Polo';
        badgeColor = color ?? const Color(0xFF2563EB);
        icon = Icons.fiber_new_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionBadge(String region, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFF691C32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_rounded,
            size: 14,
            color: isDark ? Colors.white70 : const Color(0xFF691C32),
          ),
          const SizedBox(width: 6),
          Text(
            region,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF691C32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
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

  void _showFeedbackDialog() {
    if (_selectedPolo == null) return;

    final polo = _selectedPolo!;
    final poloData = PolosData.getPoloByStringId(polo.id);

    // Obtener el ID numérico del polo para la base de datos
    int poloId =
        poloData?.id ??
        PolosDatabase.findPoloIdByName(polo.nombre, polo.estado) ??
        1; // Fallback a 1 si no se encuentra

    // Usar el método estático que maneja web vs móvil
    EncuestaPoloScreen.show(
      context,
      poloId: poloId,
      poloNombre: polo.nombre,
      poloEstado: polo.estado,
      poloDescripcion: poloData?.descripcion ?? polo.descripcion,
      onEncuestaEnviada: () {
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('¡Opinión registrada con éxito!'),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  // Método para compartir información del polo como imagen
  Future<void> _sharePolo(PoloInfo polo, PoloMarker? poloData) async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF691C32)),
                SizedBox(height: 16),
                Text('Generando infografía...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Capturar la infografía como imagen
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Material(
            color: Colors.transparent,
            child: PoloInfografiaWidget(
              polo: polo,
              poloData: poloData,
            ),
          ),
        ),
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0, // Alta resolución
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.pop(context);

      if (imageBytes == null) {
        throw Exception('No se pudo generar la imagen');
      }

      // Detectar si es móvil o escritorio
      final isDesktop = MediaQuery.of(context).size.width >= 768;
      final isMobileDevice = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

      if (isMobileDevice) {
        // En móvil: compartir la imagen
        await _shareImageMobile(imageBytes, polo.nombre);
      } else if (kIsWeb) {
        // En web: descargar la imagen
        await _downloadImageWeb(imageBytes, polo.nombre);
      } else {
        // En desktop: guardar la imagen
        await _saveImageDesktop(imageBytes, polo.nombre);
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar imagen: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Compartir imagen en móvil
  Future<void> _shareImageMobile(Uint8List imageBytes, String poloName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'plan_mexico_${poloName.replaceAll(' ', '_').toLowerCase()}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '🇲🇽 Conoce el polo de desarrollo: $poloName\n#PlanMéxico',
        subject: 'Plan México - $poloName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al compartir imagen'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Descargar imagen en web
  Future<void> _downloadImageWeb(Uint8List imageBytes, String poloName) async {
    try {
      // ignore: avoid_web_libraries_in_flutter
      // En web usamos dart:html para descargar
      // Por ahora mostramos un mensaje de éxito y usamos share_plus
      await Share.shareXFiles(
        [XFile.fromData(imageBytes, name: 'plan_mexico_$poloName.png', mimeType: 'image/png')],
        text: '🇲🇽 Conoce el polo de desarrollo: $poloName\n#PlanMéxico',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Imagen lista para compartir'),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al descargar imagen'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Guardar imagen en desktop
  Future<void> _saveImageDesktop(Uint8List imageBytes, String poloName) async {
    try {
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final fileName = 'plan_mexico_${poloName.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Imagen guardada en: ${file.path}'),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al guardar imagen'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
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

  /// Maneja el clic en el botón "Explorar" del polo
  /// Para el polo AIFA (DF/CDMX), abre un WebView 3D interactivo
  void _handleExplorarPolo(PoloInfo polo) {
    // URLs de experiencias 3D por polo
    const Map<String, String> poloWebViews = {
      'cdmx_poligono': 'https://aifa-zfgbfa1lsvxu-zxmejh.needle.run/',
      'edomex_aifa': 'https://aifa-zfgbfa1lsvxu-zxmejh.needle.run/',
    };

    // Verificar si el polo tiene una experiencia 3D
    if (poloWebViews.containsKey(polo.id)) {
      WebViewDialog.show(
        context,
        url: poloWebViews[polo.id]!,
        title: 'Explorar ${polo.nombre}',
      );
    } else {
      // Para otros polos, abrir la ubicación en el mapa
      _openLocation(polo.latitud, polo.longitud);
    }
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
                color: isDark ? const Color(0xFF262830) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A3D47)
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
            : (isDark ? const Color(0xFF262830) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? color
              : (isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB)),
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

  // Panel de estado para móvil - desplegado sin scroll interno (scroll de pantalla completa)
  Widget _buildStateInfoPanel(bool isDark) {
    final poloData = _selectedStateName != null
        ? _statePoloData[_selectedStateName]
        : null;
    final detailData = _selectedStateName != null
        ? _stateDetailData[_selectedStateName]
        : null;

    if (_showDetailedInfo && detailData != null) {
      return _buildDetailedStateInfoNoScroll(detailData, isDark);
    } else if (_showDetailedInfo && detailData == null) {
      return _buildNoInfoFound(isDark);
    }

    return Container(
      key: _stateInfoPanelKey,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con info del estado
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
              // Botón para cerrar
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedStateName = null;
                    _selectedStateCode = null;
                    _showDetailedInfo = false;
                  });
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
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
            value: detailData?.poblacionBeneficiada ?? '--',
            subtitle: 'Habitantes',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.trending_up_rounded,
            title: 'Inversión proyectada',
            value: detailData?.inversion ?? '--',
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
                      ? const Color(0xFF262830)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3D47)
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
                setState(() {
                  _showDetailedInfo = true;
                });
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

  Widget _buildStateInfo(bool isDark) {
    final poloData = _selectedStateName != null
        ? _statePoloData[_selectedStateName]
        : null;
    final detailData = _selectedStateName != null
        ? _stateDetailData[_selectedStateName]
        : null;

    if (_showDetailedInfo && detailData != null) {
      return _buildDetailedStateInfo(detailData, isDark);
    } else if (_showDetailedInfo && detailData == null) {
      return _buildNoInfoFound(isDark);
    }

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
            value: detailData?.poblacionBeneficiada ?? '--',
            subtitle: 'Habitantes',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.trending_up_rounded,
            title: 'Inversión proyectada',
            value: detailData?.inversion ?? '--',
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
                      ? const Color(0xFF262830)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3D47)
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
                setState(() {
                  _showDetailedInfo = true;
                });
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

  // Versión sin scroll interno para usar en layout de pantalla completa scrolleable
  Widget _buildDetailedStateInfoNoScroll(StateDetailData data, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botón de regreso
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDetailedInfo = false;
                  });
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.nombrePolo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              // Botón para cerrar
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedStateName = null;
                    _selectedStateCode = null;
                    _showDetailedInfo = false;
                  });
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildDetailSection(isDark, 'Resumen del Estado', [
            _buildDetailItem(isDark, 'Polo Oficial', data.poloOficial),
            _buildDetailItem(
              isDark,
              'Sectores Fuertes',
              data.sectoresFuertes.join(', '),
            ),
            _buildDetailItem(isDark, 'Población', data.poblacion),
            _buildDetailItem(isDark, 'Conectividad', data.conectividad),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Indicadores Clave', [
            _buildDetailItem(isDark, 'Superficie', data.superficie),
            _buildDetailItem(isDark, 'Inversión Estimada', data.inversion),
            _buildDetailItem(
              isDark,
              'Población Beneficiada',
              data.poblacionBeneficiada,
            ),
            _buildDetailItem(isDark, 'Empleos / Empresas Ancla', data.empleos),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Detalle del Polo', [
            _buildDetailItem(isDark, 'Municipio', data.municipio),
            _buildDetailItem(isDark, 'Sector', data.sectorPolo),
            _buildDetailItem(isDark, 'Vocación', data.vocacion),
            _buildDetailItem(isDark, 'Organismos', data.organismos),
            if (data.oportunidades.isNotEmpty)
              _buildDetailItem(isDark, 'Oportunidades', data.oportunidades),
            if (data.beneficios.isNotEmpty)
              _buildDetailItem(isDark, 'Beneficios', data.beneficios),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Proyectos Federales Asociados', [
            ...data.proyectosFederales.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: const Color(0xFF691C32),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailedStateInfo(StateDetailData data, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botón de regreso
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDetailedInfo = false;
                  });
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.nombrePolo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildDetailSection(isDark, 'Resumen del Estado', [
            _buildDetailItem(isDark, 'Polo Oficial', data.poloOficial),
            _buildDetailItem(
              isDark,
              'Sectores Fuertes',
              data.sectoresFuertes.join(', '),
            ),
            _buildDetailItem(isDark, 'Población', data.poblacion),
            _buildDetailItem(isDark, 'Conectividad', data.conectividad),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Indicadores Clave', [
            _buildDetailItem(isDark, 'Superficie', data.superficie),
            _buildDetailItem(isDark, 'Inversión Estimada', data.inversion),
            _buildDetailItem(
              isDark,
              'Población Beneficiada',
              data.poblacionBeneficiada,
            ),
            _buildDetailItem(isDark, 'Empleos / Empresas Ancla', data.empleos),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Detalle del Polo', [
            _buildDetailItem(isDark, 'Municipio', data.municipio),
            _buildDetailItem(isDark, 'Sector', data.sectorPolo),
            _buildDetailItem(isDark, 'Vocación', data.vocacion),
            _buildDetailItem(isDark, 'Organismos', data.organismos),
            if (data.oportunidades.isNotEmpty)
              _buildDetailItem(isDark, 'Oportunidades', data.oportunidades),
            if (data.beneficios.isNotEmpty)
              _buildDetailItem(isDark, 'Beneficios', data.beneficios),
          ]),

          const SizedBox(height: 20),

          _buildDetailSection(isDark, 'Proyectos Federales Asociados', [
            ...data.proyectosFederales.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: const Color(0xFF691C32),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNoInfoFound(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 64,
          color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 16),
        Text(
          'Información no encontrada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No se encontró información detallada en PODECOBI para este estado.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showDetailedInfo = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF691C32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Regresar'),
        ),
      ],
    );
  }

  Widget _buildDetailSection(bool isDark, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262830) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF691C32),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              height: 1.4,
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
        color: isDark ? const Color(0xFF262830) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3D47) : const Color(0xFFE5E7EB),
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
                        ? const Color(0xFFA0A0A0)
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
