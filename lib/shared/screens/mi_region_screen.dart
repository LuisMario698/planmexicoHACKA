import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/polos_data.dart';
import 'encuesta_polo_screen.dart';
import 'registro_screen.dart';
import '../../service/encuesta_service.dart';
import '../../service/user_session_service.dart';
import '../widgets/mi_region_tutorial.dart';
import '../widgets/module_tutorial_overlay.dart';

// Colores institucionales
const Color guinda = Color(0xFF691C32);
const Color dorado = Color(0xFFBC955C);
const Color verde = Color(0xFF006847);

class MiRegionScreen extends StatefulWidget {
  const MiRegionScreen({super.key});

  @override
  State<MiRegionScreen> createState() => _MiRegionScreenState();
}

class _MiRegionScreenState extends State<MiRegionScreen> {
  // Servicio de sesión de usuario
  final UserSessionService _sessionService = UserSessionService();
  
  // Getters que obtienen datos del usuario logueado o valores por defecto
  bool get _isLoggedIn => _sessionService.isLoggedIn;
  String get _municipioUsuario => _sessionService.currentUser?.ciudad ?? 'Tu Ciudad';
  String get _estadoUsuario => _sessionService.currentUser?.estado ?? 'Tu Estado';
  String get _nombreUsuario => _sessionService.currentUser?.primerNombre ?? 'Ciudadano';
  String get _descripcionMunicipio => _getDescripcionMunicipio();

  // Helper para detectar si es pantalla ancha (web/desktop)
  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  // Helper para mostrar modal adaptativo (diálogo en desktop, bottom sheet en mobile)
  void _mostrarModalAdaptativo({
    required BuildContext context,
    required Widget Function(ScrollController? scrollController) contentBuilder,
    required bool isDark,
    double desktopWidth = 600,
    double desktopMaxHeight = 0.85,
  }) {
    if (_isWideScreen(context)) {
      // Desktop: Diálogo centrado
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Container(
            width: desktopWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * desktopMaxHeight,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con botón cerrar
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
                // Contenido scrolleable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: contentBuilder(null),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mobile: Bottom sheet deslizable
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Contenido
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: contentBuilder(scrollController),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // Preguntas del día (5 predefinidas, se elige aleatoriamente)
  static const List<String> _preguntasDelDia = [
    '¿Qué tipo de empleo te gustaría encontrar en tu región?',
    '¿Qué curso o capacitación consideras más útil para tu comunidad?',
    '¿Qué proyecto de infraestructura mejoraría más tu zona?',
    '¿Cómo crees que podría mejorar el transporte público local?',
    '¿Qué servicio público necesita más atención en tu municipio?',
  ];

  late String _preguntaActual;
  final TextEditingController _respuestaController = TextEditingController();
  bool _respuestaEnviada = false;

  // Tutorial state
  bool _showTutorial = false;
  int _tutorialStep = 1;

  @override
  void initState() {
    super.initState();
    // Seleccionar pregunta aleatoria
    final random = Random();
    _preguntaActual = _preguntasDelDia[random.nextInt(_preguntasDelDia.length)];

    // Verificar tutorial
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Usar una key única para este tutorial
    bool seen = prefs.getBool('seen_mi_region_tutorial') ?? false;

    if (!seen) {
      // Pequeño delay para que la UI cargue primero
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showTutorial = true;
          _tutorialStep = 1;
        });
      }
    }
  }

  void _nextTutorialStep() {
    if (_tutorialStep < 3) {
      setState(() => _tutorialStep++);
    } else {
      _closeTutorial();
    }
  }

  void _closeTutorial() async {
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_mi_region_tutorial', true);
  }

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  // Datos de ejemplo para los módulos
  final int _empleosNuevos = 4;
  final int _cursosDisponibles = 2;
  final double _avanceObras = 3.0;
  final int _noticiasRecientes = 1;
  final int _eventosProximos = 1;

  List<PoloMarker> get _polosCercanos {
    return PolosData.polos.where((p) => p.estado == _estadoUsuario).toList();
  }

  // Helpers responsivos
  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 32;
    if (width > 400) return 20;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final horizontalPadding = _getHorizontalPadding(context);

    final isWide = _isWideScreen(context);
    final maxContentWidth = 1200.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: isWide
                ? _buildWebLayout(
                    context,
                    isDark,
                    cardColor,
                    textColor,
                    subtextColor,
                    horizontalPadding,
                    maxContentWidth,
                  )
                : _buildMobileLayout(
                    context,
                    isDark,
                    cardColor,
                    textColor,
                    subtextColor,
                    horizontalPadding,
                  ),
          ),

          // Tutorial Overlay
          if (_showTutorial)
            MiRegionTutorialOverlay(
              step: _tutorialStep,
              onNext: _nextTutorialStep,
              onSkip: _closeTutorial,
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LAYOUT MOBILE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    double horizontalPadding,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero como SliverAppBar para que esté pegado arriba
        SliverToBoxAdapter(child: _buildHeroSection(isDark, isWide: false)),
        // Contenido scrolleable
        SliverToBoxAdapter(
          child: _buildModulosPanel(
            context,
            isDark,
            cardColor,
            textColor,
            subtextColor,
            horizontalPadding,
            isWide: false,
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LAYOUT WEB/DESKTOP - Rediseñado
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    double horizontalPadding,
    double maxContentWidth,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero full width pegado arriba
        SliverToBoxAdapter(child: _buildHeroSection(isDark, isWide: true)),
        // Contenido principal con nuevo diseño
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: _buildDesktopDashboard(
                  context,
                  isDark,
                  cardColor,
                  textColor,
                  subtextColor,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }

  // Dashboard principal para desktop
  Widget _buildDesktopDashboard(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
  ) {
    final modulos = _getModulos(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebar = screenWidth > 1100;

    if (showSidebar) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna principal (módulos)
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de sección
                _buildSectionHeader(isDark, textColor, subtextColor),
                const SizedBox(height: 24),
                
                // Módulos destacados (Empleos y Cursos) - Cards grandes
                Row(
                  children: [
                    Expanded(
                      child: _buildPrimaryModuleCard(
                        modulo: modulos[0], // Empleos
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildPrimaryModuleCard(
                        modulo: modulos[1], // Cursos
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Módulos secundarios en grid de 4
                Row(
                  children: [
                    Expanded(
                      child: _buildSecondaryModuleCard(
                        modulo: modulos[2], // Obras
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSecondaryModuleCard(
                        modulo: modulos[3], // Noticias
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSecondaryModuleCard(
                        modulo: modulos[4], // Polos
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSecondaryModuleCard(
                        modulo: modulos[5], // Eventos
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 28),
          // Sidebar derecha - Solo pregunta del día
          SizedBox(
            width: 320,
            child: _buildPreguntaDelDia(isDark, cardColor, textColor, subtextColor),
          ),
        ],
      );
    } else {
      // Layout de una columna para pantallas medianas
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(isDark, textColor, subtextColor),
          const SizedBox(height: 24),
          // Módulos destacados
          Row(
            children: [
              Expanded(
                child: _buildPrimaryModuleCard(
                  modulo: modulos[0],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPrimaryModuleCard(
                  modulo: modulos[1],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid de 3x2 para los demás
          Row(
            children: [
              Expanded(
                child: _buildSecondaryModuleCard(
                  modulo: modulos[2],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecondaryModuleCard(
                  modulo: modulos[3],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSecondaryModuleCard(
                  modulo: modulos[4],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryModuleCard(
                  modulo: modulos[5],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 28),
          _buildPreguntaDelDia(isDark, cardColor, textColor, subtextColor),
        ],
      );
    }
  }

  // Header de sección mejorado
  Widget _buildSectionHeader(bool isDark, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFF1E1E2E), const Color(0xFF252536)]
              : [Colors.white, const Color(0xFFFAFAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(10) : guinda.withAlpha(15),
        ),
        boxShadow: [
          BoxShadow(
            color: guinda.withAlpha(isDark ? 20 : 12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [guinda, Color(0xFF8B2346)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: guinda.withAlpha(80),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.explore_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explora Tu Región',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Descubre servicios, oportunidades y proyectos disponibles en tu comunidad',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Badge de actualizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [verde.withAlpha(25), verde.withAlpha(12)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: verde.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: verde,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: verde.withAlpha(150), blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Actualizado hoy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: verde,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card de módulo principal (grande) para desktop
  Widget _buildPrimaryModuleCard({
    required Map<String, dynamic> modulo,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final color = modulo['color'] as Color;
    final gradient = modulo['gradient'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: modulo['onTap'] as VoidCallback,
        borderRadius: BorderRadius.circular(24),
        hoverColor: color.withAlpha(8),
        splashColor: color.withAlpha(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(8) : color.withAlpha(20),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isDark ? 20 : 15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(modulo['icon'] as IconData, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        modulo['valor'] as String,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withAlpha(18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          modulo['unidad'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                modulo['titulo'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modulo['descripcion'] as String,
                style: TextStyle(fontSize: 12, color: subtextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              _buildExploreButton(color, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Card de módulo secundario (compacto) para desktop
  Widget _buildSecondaryModuleCard({
    required Map<String, dynamic> modulo,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final color = modulo['color'] as Color;
    final gradient = modulo['gradient'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: modulo['onTap'] as VoidCallback,
        borderRadius: BorderRadius.circular(20),
        hoverColor: color.withAlpha(8),
        splashColor: color.withAlpha(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(8) : color.withAlpha(15),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isDark ? 15 : 10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(modulo['icon'] as IconData, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    modulo['valor'] as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                modulo['titulo'] as String,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                modulo['descripcion'] as String,
                style: TextStyle(fontSize: 11, color: subtextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botón de explorar reutilizable
  Widget _buildExploreButton(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(10)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Explorar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, size: 16, color: color),
        ],
      ),
    );
  }

  // Card de resumen rápido para sidebar
  Widget _buildQuickSummaryCard(bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(10) : Colors.grey.withAlpha(20),
        ),
        boxShadow: [
          BoxShadow(
            color: guinda.withAlpha(isDark ? 15 : 8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [guinda, Color(0xFF8B2346)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen de Tu Región',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats en grid
          _buildSummaryItem(
            icon: Icons.work_rounded,
            label: 'Empleos disponibles',
            value: '$_empleosNuevos nuevos',
            color: verde,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.school_rounded,
            label: 'Cursos activos',
            value: '$_cursosDisponibles disponibles',
            color: const Color(0xFF2563EB),
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.location_city_rounded,
            label: 'Polos cercanos',
            value: '${_polosCercanos.length} en tu estado',
            color: guinda,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.event_rounded,
            label: 'Eventos próximos',
            value: '$_eventosProximos esta semana',
            color: const Color(0xFF0D9488),
            isDark: isDark,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  // Item del resumen
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(isDark ? 30 : 15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withAlpha(150),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HERO SECTION - Ubicación del usuario (Full Width)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeroSection(bool isDark, {required bool isWide}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B1538), guinda, Color(0xFF4A1525)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: isWide ? _buildHeroContentWide() : _buildHeroContentMobile(),
      ),
    );
  }

  Widget _buildHeroContentMobile() {
    // Si no está logueado, mostrar hero de bienvenida con botón de registro
    if (!_isLoggedIn) {
      return _buildWelcomeHeroMobile();
    }
    
    // Usuario logueado: mostrar su ubicación
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        children: [
          // Header con ubicación
          Row(
            children: [
              // Icono de ubicación con animación visual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(40),
                      Colors.white.withAlpha(20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _municipioUsuario,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: dorado.withAlpha(60),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: dorado.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            color: dorado,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _estadoUsuario,
                            style: const TextStyle(
                              fontSize: 14,
                              color: dorado,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Descripción del municipio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _descripcionMunicipio,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(200),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Hero de bienvenida para usuarios no registrados (Mobile)
  Widget _buildWelcomeHeroMobile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          // Icono de bienvenida
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(40),
                  Colors.white.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: dorado,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          // Texto de bienvenida
          const Text(
            '¡Bienvenido a Plan México!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Regístrate para ver información personalizada de tu región',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withAlpha(200),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Botón de registro
          Material(
            color: dorado,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _navegarARegistro(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContentWide() {
    // Si no está logueado, mostrar hero de bienvenida con botón de registro
    if (!_isLoggedIn) {
      return _buildWelcomeHeroWide();
    }
    
    // Usuario logueado: mostrar su ubicación con diseño mejorado
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono de ubicación con efecto glassmorphism
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(50),
                  Colors.white.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 28),
          // Info del municipio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ciudad y Estado
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    Text(
                      _municipioUsuario,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [dorado.withAlpha(180), dorado],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: dorado.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _estadoUsuario,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _descripcionMunicipio,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withAlpha(200),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Stats rápidas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: Column(
              children: [
                _buildQuickStat(Icons.work_rounded, '$_empleosNuevos', 'Empleos'),
                const SizedBox(height: 14),
                _buildQuickStat(Icons.school_rounded, '$_cursosDisponibles', 'Cursos'),
                const SizedBox(height: 14),
                _buildQuickStat(Icons.location_city_rounded, '${_polosCercanos.length}', 'Polos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para stats rápidas en el hero
  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: dorado, size: 18),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(180),
          ),
        ),
      ],
    );
  }
  
  // Hero de bienvenida para usuarios no registrados (Wide/Web)
  Widget _buildWelcomeHeroWide() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono de bienvenida
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withAlpha(40),
                  Colors.white.withAlpha(15),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: dorado,
              size: 52,
            ),
          ),
          const SizedBox(width: 40),
          // Texto de bienvenida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Bienvenido a Plan México!',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Regístrate para ver información personalizada de empleos, cursos y proyectos en tu región',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white.withAlpha(200),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          // Botón de registro
          Material(
            color: dorado,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => _navegarARegistro(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PANEL DE MÓDULOS - Grid de botones de navegación
  // ════════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _getModulos(BuildContext context) {
    return [
      {
        'icon': Icons.work_rounded,
        'titulo': 'Empleos',
        'valor': '$_empleosNuevos',
        'unidad': 'nuevos',
        'color': verde,
        'gradient': [verde, const Color(0xFF059669)],
        'descripcion': 'Oportunidades laborales cerca de ti',
        'onTap': () => _navegarAModulo(context, 'empleos'),
      },
      {
        'icon': Icons.school_rounded,
        'titulo': 'Cursos',
        'valor': '$_cursosDisponibles',
        'unidad': 'disponibles',
        'color': const Color(0xFF2563EB),
        'gradient': [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
        'descripcion': 'Capacitación y talleres',
        'onTap': () => _navegarAModulo(context, 'cursos'),
      },
      {
        'icon': Icons.construction_rounded,
        'titulo': 'Obras',
        'valor': '+${_avanceObras.toStringAsFixed(0)}%',
        'unidad': 'avance',
        'color': dorado,
        'gradient': [dorado, const Color(0xFFD4A853)],
        'descripcion': 'Proyectos en construcción',
        'onTap': () => _navegarAModulo(context, 'obras'),
      },
      {
        'icon': Icons.newspaper_rounded,
        'titulo': 'Noticias',
        'valor': '$_noticiasRecientes',
        'unidad': 'recientes',
        'color': const Color(0xFF9333EA),
        'gradient': [const Color(0xFF9333EA), const Color(0xFFA855F7)],
        'descripcion': 'Últimas novedades locales',
        'onTap': () => _navegarAModulo(context, 'noticias'),
      },
      {
        'icon': Icons.location_city_rounded,
        'titulo': 'Polos',
        'valor': '${_polosCercanos.length}',
        'unidad': 'cercanos',
        'color': guinda,
        'gradient': [guinda, const Color(0xFF8B2346)],
        'descripcion': 'Polos de desarrollo',
        'onTap': () => _navegarAModulo(context, 'polos'),
      },
      {
        'icon': Icons.event_rounded,
        'titulo': 'Eventos',
        'valor': '$_eventosProximos',
        'unidad': 'próximos',
        'color': const Color(0xFF0D9488),
        'gradient': [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
        'descripcion': 'Ferias y conferencias',
        'onTap': () => _navegarAModulo(context, 'eventos'),
      },
    ];
  }

  Widget _buildModulosPanel(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    double horizontalPadding, {
    required bool isWide,
  }) {
    final modulos = _getModulos(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          
          // Header de sección con diseño premium
          Container(
            padding: EdgeInsets.all(isWide ? 24 : 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF1E1E2E), const Color(0xFF252536)]
                    : [Colors.white, const Color(0xFFFAFAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(10) : guinda.withAlpha(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: guinda.withAlpha(isDark ? 15 : 10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono decorativo
                Container(
                  padding: EdgeInsets.all(isWide ? 14 : 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [guinda, Color(0xFF8B2346)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: guinda.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: isWide ? 26 : 22,
                  ),
                ),
                SizedBox(width: isWide ? 18 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explora Tu Región',
                        style: TextStyle(
                          fontSize: isWide ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isWide 
                            ? 'Accede a servicios, oportunidades y proyectos en tu comunidad'
                            : 'Servicios y oportunidades cerca de ti',
                        style: TextStyle(
                          fontSize: isWide ? 14 : 12,
                          color: subtextColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Cards destacadas (Empleos y Cursos)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[0],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[1],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // Segunda fila (Obras y Noticias)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[2],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[3],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // Tercera fila (Polos y Eventos)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[4],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeaturedCard(
                  modulo: modulos[5],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLarge: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Pregunta del Día
          _buildPreguntaDelDia(isDark, cardColor, textColor, subtextColor),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard({
    required Map<String, dynamic> modulo,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required bool isLarge,
  }) {
    final color = modulo['color'] as Color;
    final gradient = modulo['gradient'] as List<Color>;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular tamaños responsivos basados en el ancho disponible
        final cardWidth = constraints.maxWidth;
        final isCompact = cardWidth < 160;
        final iconSize = isCompact ? 20.0 : (isLarge ? 24.0 : 22.0);
        final iconPadding = isCompact ? 10.0 : 12.0;
        final statSize = isCompact ? 22.0 : (isLarge ? 28.0 : 24.0);
        final titleSize = isCompact ? 15.0 : (isLarge ? 18.0 : 16.0);
        final cardPadding = isCompact ? 14.0 : 18.0;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: modulo['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(8) : color.withAlpha(20),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(isDark ? 25 : 15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con icono y estadística
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono con gradiente
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha(60),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          modulo['icon'] as IconData,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                      const Spacer(),
                      // Estadística
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            modulo['valor'] as String,
                            style: TextStyle(
                              fontSize: statSize,
                              fontWeight: FontWeight.bold,
                              color: color,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            modulo['unidad'] as String,
                            style: TextStyle(
                              fontSize: isCompact ? 10 : 11,
                              color: color.withAlpha(180),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isCompact ? 14 : 18),
                  
                  // Título
                  Text(
                    modulo['titulo'] as String,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Descripción
                  Text(
                    modulo['descripcion'] as String,
                    style: TextStyle(
                      fontSize: isCompact ? 10 : 12,
                      color: subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: isCompact ? 10 : 14),
                  
                  // Botón explorar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 12,
                      vertical: isCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 35 : 18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCompact ? 'Ver' : 'Explorar',
                          style: TextStyle(
                            fontSize: isCompact ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: isCompact ? 12 : 14,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreguntaDelDia(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(30),
        ),
        boxShadow: [
          BoxShadow(
            color: guinda.withAlpha(isDark ? 15 : 10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título mejorado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [dorado.withAlpha(180), dorado],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: dorado.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta del Día',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¡Tu opinión nos ayuda a mejorar!',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pregunta con diseño mejorado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [guinda.withAlpha(25), guinda.withAlpha(15)]
                    : [guinda.withAlpha(12), guinda.withAlpha(6)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: guinda.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: guinda.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: guinda,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _preguntaActual,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Campo de respuesta mejorado
          if (!_respuestaEnviada) ...[
            TextField(
              controller: _respuestaController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe tu respuesta aquí...',
                hintStyle: TextStyle(color: subtextColor.withAlpha(150)),
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(8) : Colors.grey.withAlpha(15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: guinda, width: 2),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
              style: TextStyle(color: textColor, fontSize: 15),
            ),
            const SizedBox(height: 16),
            // Botón de enviar mejorado
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_respuestaController.text.trim().isNotEmpty) {
                    setState(() {
                      _respuestaEnviada = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '¡Gracias por tu respuesta!',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: verde,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text(
                  'Enviar Respuesta',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: guinda,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ] else ...[
            // Mensaje de agradecimiento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: verde.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: verde.withAlpha(50)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.celebration_rounded, color: verde, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    '¡Gracias por participar!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu opinión ha sido registrada',
                    style: TextStyle(fontSize: 13, color: subtextColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PANEL DE MÓDULOS WEB - Grid de 3 columnas
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildModulosPanelWeb(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
  ) {
    final modulos = _getModulos(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header premium con gradiente
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                  ? [const Color(0xFF1E1E2E), const Color(0xFF252536)]
                  : [Colors.white, const Color(0xFFFAFAFC)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(10) : guinda.withAlpha(15),
            ),
            boxShadow: [
              BoxShadow(
                color: guinda.withAlpha(isDark ? 25 : 15),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono decorativo premium
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [guinda, Color(0xFF8B2346)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: guinda.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explora Tu Región',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre servicios, oportunidades y proyectos disponibles en tu comunidad',
                      style: TextStyle(
                        fontSize: 15,
                        color: subtextColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [verde.withAlpha(30), verde.withAlpha(15)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: verde.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: verde,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: verde.withAlpha(150),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Actualizado hoy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: verde,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Grid de módulos - 3 columnas en web
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            const spacing = 20.0;
            const columns = 3;
            final cardWidth = (screenWidth - (spacing * (columns - 1))) / columns;

            return Column(
              children: [
                // Primera fila - Cards grandes
                Row(
                  children: [
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[0],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 200,
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[1],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 200,
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[2],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: spacing),
                // Segunda fila
                Row(
                  children: [
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[3],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 180,
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[4],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 180,
                      ),
                    ),
                    const SizedBox(width: spacing),
                    Expanded(
                      child: _buildWebModuleCard(
                        modulo: modulos[5],
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtextColor: subtextColor,
                        height: 180,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Card de módulo para Web - Diseño premium
  Widget _buildWebModuleCard({
    required Map<String, dynamic> modulo,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required double height,
  }) {
    final color = modulo['color'] as Color;
    final gradient = modulo['gradient'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: modulo['onTap'] as VoidCallback,
        borderRadius: BorderRadius.circular(24),
        hoverColor: color.withAlpha(10),
        splashColor: color.withAlpha(20),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(8) : color.withAlpha(25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isDark ? 25 : 18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y estadística
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono con gradiente
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(100),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      modulo['icon'] as IconData,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  // Estadística grande
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        modulo['valor'] as String,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          modulo['unidad'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Título
              Text(
                modulo['titulo'] as String,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                modulo['descripcion'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: subtextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Botón explorar con hover effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withAlpha(25), color.withAlpha(15)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withAlpha(30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explorar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // NAVEGACIÓN A MÓDULOS
  // ════════════════════════════════════════════════════════════════════════════
  void _navegarAModulo(BuildContext context, String modulo) {
    switch (modulo) {
      case 'empleos':
        _mostrarModuloEmpleos(context);
        break;
      case 'cursos':
        _mostrarModuloCursos(context);
        break;
      case 'obras':
        _mostrarModuloObras(context);
        break;
      case 'noticias':
        _mostrarModuloNoticias(context);
        break;
      case 'polos':
        _mostrarModuloPolos(context);
        break;
      case 'eventos':
        _mostrarModuloEventos(context);
        break;
    }
  }

  // Mostrar diálogo de beneficios antes de ir al registro
  void _navegarARegistro(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 600;
    
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isWide ? 100 : 24,
          vertical: 40,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isWide ? 500 : double.infinity,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono decorativo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [guinda, Color(0xFF8B2346)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: guinda.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  Text(
                    '¡Únete a Plan México!',
                    style: TextStyle(
                      fontSize: isWide ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Descripción
                  Text(
                    'Regístrate para acceder a contenido personalizado de tu región y muchos beneficios más.',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark 
                          ? Colors.white.withOpacity(0.7) 
                          : const Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  
                  // Lista de beneficios
                  _buildBeneficiosRegistro(isDark),
                  const SizedBox(height: 28),
                  
                  // Botones
                  Row(
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón Registrarme
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cerrar el diálogo
                            // Navegar al registro y esperar resultado
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RegistroScreen(
                                  onRegistroExitoso: () {
                                    // El RegistroScreen se encarga de hacer pop
                                    // Solo actualizamos el estado
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: guinda,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: guinda.withOpacity(0.4),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Registrarme',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para mostrar la lista de beneficios
  Widget _buildBeneficiosRegistro(bool isDark) {
    final beneficios = [
      {'icon': Icons.location_on_rounded, 'text': 'Información de tu región', 'color': verde},
      {'icon': Icons.work_rounded, 'text': 'Ofertas de empleo cercanas', 'color': const Color(0xFF2563EB)},
      {'icon': Icons.school_rounded, 'text': 'Cursos y capacitaciones', 'color': const Color(0xFF9333EA)},
      {'icon': Icons.emoji_events_rounded, 'text': 'Logros y recompensas', 'color': dorado},
      {'icon': Icons.notifications_rounded, 'text': 'Alertas personalizadas', 'color': Colors.teal},
    ];

    return Column(
      children: beneficios.map((beneficio) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (beneficio['color'] as Color).withOpacity(isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  beneficio['icon'] as IconData,
                  color: beneficio['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  beneficio['text'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: verde.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Obtener descripción del municipio basada en la ubicación
  String _getDescripcionMunicipio() {
    if (!_isLoggedIn) {
      return 'Regístrate para ver información de tu región';
    }
    // Descripción genérica basada en el estado
    final descripciones = {
      'Sonora': 'Destino turístico del noroeste mexicano, conocido por sus playas y desarrollo industrial sostenible.',
      'Jalisco': 'Centro cultural y económico del occidente de México, cuna del tequila y el mariachi.',
      'Nuevo León': 'Polo industrial y de innovación del norte de México.',
      'Ciudad de México': 'Capital del país y centro político, cultural y económico.',
      'Estado de México': 'Estado más poblado del país, con gran diversidad económica y cultural.',
      'Yucatán': 'Tierra de la cultura maya, con rica historia y gastronomía única.',
      'Quintana Roo': 'Paraíso turístico del Caribe mexicano.',
      'Puebla': 'Ciudad patrimonio con rica tradición gastronómica y arquitectónica.',
      'Guanajuato': 'Corazón industrial y cultural del Bajío mexicano.',
      'Veracruz': 'Puerto histórico con rica cultura afromestiza y tradición jarocha.',
    };
    return descripciones[_estadoUsuario] ?? 
        'Descubre las oportunidades de desarrollo en $_municipioUsuario, $_estadoUsuario.';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MODALES DE MÓDULOS (Cada uno se puede expandir después)
  // ════════════════════════════════════════════════════════════════════════════
  void _mostrarModuloEmpleos(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Oportunidades Laborales',
      icono: Icons.work_rounded,
      color: verde,
      contenido: _buildContenidoEmpleos,
      moduleName: 'Empleos',
    );
  }

  void _mostrarModuloCursos(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Cursos y Talleres',
      icono: Icons.school_rounded,
      color: const Color(0xFF2563EB),
      contenido: _buildContenidoCursos,
      moduleName: 'Cursos',
    );
  }

  void _mostrarModuloObras(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Avances de Obras',
      icono: Icons.construction_rounded,
      color: dorado,
      contenido: _buildContenidoObras,
      moduleName: 'Obras',
    );
  }

  void _mostrarModuloNoticias(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Noticias Locales',
      icono: Icons.newspaper_rounded,
      color: Colors.purple,
      contenido: _buildContenidoNoticias,
      moduleName: 'Noticias',
    );
  }

  void _mostrarModuloPolos(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Polos de Desarrollo',
      icono: Icons.location_city_rounded,
      color: guinda,
      contenido: _buildContenidoPolos,
      moduleName: 'Polos',
    );
  }

  void _mostrarModuloEventos(BuildContext context) {
    _mostrarModalModulo(
      context: context,
      titulo: 'Eventos Próximos',
      icono: Icons.event_rounded,
      color: Colors.teal,
      contenido: _buildContenidoEventos,
      moduleName: 'Eventos',
    );
  }

  void _mostrarModalModulo({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget Function(BuildContext, bool, Color, Color, Color, Color)
    contenido,
    String? moduleName,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final screenSize = MediaQuery.of(context).size;
    final isWide = screenSize.width > 800;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withAlpha(150),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ModuleDialog(
          titulo: titulo,
          icono: icono,
          color: color,
          contenidoBuilder: contenido,
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          isWide: isWide,
          screenSize: screenSize,
          moduleName: moduleName ?? titulo,
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CONTENIDO DE CADA MÓDULO - MEJORADO
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildContenidoEmpleos(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    final empleos = [
      {
        'titulo': 'Técnico Soldador',
        'empresa': 'Constructora Norte',
        'sector': 'Manufactura',
        'salario': '\$18,000/mes',
        'distancia': '12 km',
        'tipo': 'Tiempo completo',
        'descripcion': 'Buscamos técnico soldador con experiencia en soldadura MIG/TIG para proyectos de construcción industrial. Ofrecemos prestaciones de ley, seguro de gastos médicos y vales de despensa.',
        'requisitos': ['2+ años de experiencia', 'Certificación en soldadura', 'Disponibilidad de horario'],
        'beneficios': ['Seguro médico', 'Vales de despensa', 'Fondo de ahorro'],
        'icono': Icons.construction_rounded,
        'imagen': 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=400',
      },
      {
        'titulo': 'Operador de Maquinaria',
        'empresa': 'Minera Sonora',
        'sector': 'Minería',
        'salario': '\$22,000/mes',
        'distancia': '25 km',
        'tipo': 'Tiempo completo',
        'descripcion': 'Operador de maquinaria pesada para extracción minera. Turno rotativo con transporte incluido. Excelente ambiente laboral y oportunidades de crecimiento.',
        'requisitos': ['Licencia tipo E', '3+ años de experiencia', 'Disponibilidad para rotar turnos'],
        'beneficios': ['Transporte', 'Comedor', 'Bono de productividad'],
        'icono': Icons.precision_manufacturing_rounded,
        'imagen': 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=400',
      },
      {
        'titulo': 'Ingeniero de Procesos',
        'empresa': 'Planta Solar MX',
        'sector': 'Energía Renovable',
        'salario': '\$35,000/mes',
        'distancia': '8 km',
        'tipo': 'Tiempo completo',
        'descripcion': 'Ingeniero para optimización de procesos en planta de energía solar. Participarás en proyectos de innovación y sustentabilidad con impacto nacional.',
        'requisitos': ['Ing. Industrial o afín', 'Inglés intermedio', 'Conocimiento en Lean Manufacturing'],
        'beneficios': ['Home office parcial', 'Capacitación continua', 'Bono anual'],
        'icono': Icons.solar_power_rounded,
        'imagen': 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=400',
      },
      {
        'titulo': 'Supervisor de Producción',
        'empresa': 'Alimentos del Norte',
        'sector': 'Agroindustria',
        'salario': '\$28,000/mes',
        'distancia': '15 km',
        'tipo': 'Tiempo completo',
        'descripcion': 'Supervisión de líneas de producción en planta procesadora de alimentos. Liderazgo de equipos de trabajo y cumplimiento de estándares de calidad.',
        'requisitos': ['Experiencia en supervisión', 'Conocimiento en BPM', 'Liderazgo comprobado'],
        'beneficios': ['Producto gratis', 'Aguinaldo superior', 'Caja de ahorro'],
        'icono': Icons.factory_rounded,
        'imagen': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [verde.withAlpha(20), verde.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: verde.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded, color: verde, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${empleos.length} empleos disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'En $_estadoUsuario • Actualizados hoy',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+15% esta semana',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de empleos
        ...empleos.map((empleo) => _buildEmpleoCardMejorado(
          empleo,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
        )),
      ],
    );
  }

  Widget _buildEmpleoCardMejorado(
    Map<String, dynamic> empleo,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetalleEmpleo(context, empleo, isDark, textColor, subtextColor),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: verde.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icono representativo
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [verde, verde.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: verde.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        empleo['icono'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            empleo['titulo'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.business_rounded, size: 14, color: subtextColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    empleo['empresa'] as String,
                                    style: TextStyle(fontSize: 13, color: subtextColor),
                                  ),
                                ],
                              ),
                              Text('•', style: TextStyle(color: subtextColor)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: subtextColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    empleo['distancia'] as String,
                                    style: TextStyle(fontSize: 13, color: subtextColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Tags - usando Wrap para responsividad
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTag(empleo['sector'] as String, verde.withAlpha(25), verde),
                    _buildTag(empleo['tipo'] as String, Colors.blue.withAlpha(25), Colors.blue),
                    // Salario destacado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [verde, verde.withAlpha(200)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        empleo['salario'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Preview descripción
                Text(
                  (empleo['descripcion'] as String).length > 80
                      ? '${(empleo['descripcion'] as String).substring(0, 80)}...'
                      : empleo['descripcion'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Call to action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: verde,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: verde),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _mostrarDetalleEmpleo(
    BuildContext context,
    Map<String, dynamic> empleo,
    bool isDark,
    Color textColor,
    Color subtextColor,
  ) {
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 650,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [verde, verde.withAlpha(180)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: verde.withAlpha(80),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  empleo['icono'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleo['titulo'] as String,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      empleo['empresa'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Salario destacado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [verde.withAlpha(20), verde.withAlpha(8)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: verde.withAlpha(40)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Salario', empleo['salario'] as String, Icons.payments_rounded, verde),
                _buildInfoColumn('Distancia', empleo['distancia'] as String, Icons.location_on_rounded, dorado),
                _buildInfoColumn('Tipo', empleo['tipo'] as String, Icons.schedule_rounded, Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Descripción
          Text(
            'Descripción del puesto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            empleo['descripcion'] as String,
            style: TextStyle(
              fontSize: 15,
              color: subtextColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Requisitos
          Text(
            'Requisitos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...(empleo['requisitos'] as List<String>).map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: verde, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    req,
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          // Beneficios
          Text(
            'Beneficios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (empleo['beneficios'] as List<String>).map((ben) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: dorado.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dorado.withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: dorado, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    ben,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? dorado : Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          // Botón aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Aplicación enviada! Te contactaremos pronto.'),
                    backgroundColor: verde,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: verde.withAlpha(100),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Aplicar ahora',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpleoCard(
    Map<String, String> empleo,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: verde.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_rounded, color: verde, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empleo['titulo']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${empleo['empresa']} • ${empleo['distancia']}',
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: verde.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              empleo['salario']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: verde,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoCursos(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    const Color azul = Color(0xFF2563EB);
    final cursos = [
      {
        'nombre': 'Soldadura Industrial Avanzada',
        'institucion': 'CONALEP',
        'duracion': '40 horas',
        'modalidad': 'Presencial',
        'precio': 'Gratuito',
        'fechaInicio': '15 Dic 2025',
        'cupoDisponible': 12,
        'descripcion': 'Curso práctico de soldadura MIG/TIG para proyectos industriales. Incluye certificación oficial reconocida por la SEP.',
        'temario': ['Fundamentos de soldadura', 'Técnicas MIG', 'Técnicas TIG', 'Seguridad industrial', 'Proyecto final'],
        'icono': Icons.construction_rounded,
        'nivel': 'Intermedio',
      },
      {
        'nombre': 'Excel y Análisis de Datos',
        'institucion': 'Capacítate para el Empleo',
        'duracion': '20 horas',
        'modalidad': 'En línea',
        'precio': 'Gratuito',
        'fechaInicio': 'Inmediato',
        'cupoDisponible': 999,
        'descripcion': 'Domina Excel desde nivel básico hasta avanzado. Aprende tablas dinámicas, fórmulas complejas y visualización de datos.',
        'temario': ['Fórmulas básicas', 'Tablas dinámicas', 'Gráficos', 'Macros básicos', 'Dashboard'],
        'icono': Icons.table_chart_rounded,
        'nivel': 'Básico-Avanzado',
      },
      {
        'nombre': 'Electricidad Residencial',
        'institucion': 'CFE - Programa Social',
        'duracion': '60 horas',
        'modalidad': 'Presencial',
        'precio': 'Gratuito',
        'fechaInicio': '8 Ene 2026',
        'cupoDisponible': 8,
        'descripcion': 'Aprende instalaciones eléctricas residenciales con estándares de seguridad. Incluye materiales y herramientas básicas.',
        'temario': ['Fundamentos eléctricos', 'Instalaciones básicas', 'Tableros', 'Normatividad NOM', 'Práctica supervisada'],
        'icono': Icons.electrical_services_rounded,
        'nivel': 'Básico',
      },
      {
        'nombre': 'Inglés para el Trabajo',
        'institucion': 'SEP - Prepa en Línea',
        'duracion': '80 horas',
        'modalidad': 'En línea',
        'precio': 'Gratuito',
        'fechaInicio': 'Inmediato',
        'cupoDisponible': 999,
        'descripcion': 'Curso de inglés enfocado en el ámbito laboral. Desde vocabulario básico hasta conversaciones de negocios.',
        'temario': ['Vocabulario laboral', 'Emails profesionales', 'Entrevistas', 'Presentaciones', 'Negociación'],
        'icono': Icons.translate_rounded,
        'nivel': 'Básico-Intermedio',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [azul.withAlpha(20), azul.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: azul.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.school_rounded, color: azul, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cursos.length} cursos disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Capacitación gratuita para tu desarrollo',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '100% Gratis',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de cursos
        ...cursos.map((curso) => _buildCursoCardMejorado(
          curso,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
          azul,
        )),
      ],
    );
  }

  Widget _buildCursoCardMejorado(
    Map<String, dynamic> curso,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
    Color azul,
  ) {
    final cupos = curso['cupoDisponible'] as int;
    final cuposColor = cupos < 10 ? Colors.orange : verde;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetalleCurso(context, curso, isDark, textColor, subtextColor, azul),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: azul.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [azul, azul.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        curso['icono'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            curso['nombre'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            curso['institucion'] as String,
                            style: TextStyle(fontSize: 13, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: verde.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        curso['precio'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: verde,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Info row
                Row(
                  children: [
                    _buildCursoInfoChip(Icons.schedule_rounded, curso['duracion'] as String, subtextColor),
                    const SizedBox(width: 12),
                    _buildCursoInfoChip(
                      curso['modalidad'] == 'En línea' ? Icons.laptop_rounded : Icons.location_on_rounded,
                      curso['modalidad'] as String,
                      subtextColor,
                    ),
                    const SizedBox(width: 12),
                    _buildCursoInfoChip(Icons.signal_cellular_alt_rounded, curso['nivel'] as String, subtextColor),
                  ],
                ),
                const SizedBox(height: 14),
                // Fecha y cupos
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: subtextColor),
                    const SizedBox(width: 6),
                    Text(
                      'Inicia: ${curso['fechaInicio']}',
                      style: TextStyle(fontSize: 13, color: subtextColor),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cuposColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_rounded, size: 14, color: cuposColor),
                          const SizedBox(width: 4),
                          Text(
                            cupos > 100 ? 'Cupo abierto' : '$cupos lugares',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cuposColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: azul,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: azul),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCursoInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  void _mostrarDetalleCurso(
    BuildContext context,
    Map<String, dynamic> curso,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color azul,
  ) {
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 650,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [azul, azul.withAlpha(180)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  curso['icono'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curso['nombre'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      curso['institucion'] as String,
                      style: TextStyle(fontSize: 15, color: subtextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Info cards
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [azul.withAlpha(20), azul.withAlpha(8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Duración', curso['duracion'] as String, Icons.schedule_rounded, azul),
                _buildInfoColumn('Modalidad', curso['modalidad'] as String, Icons.laptop_rounded, dorado),
                _buildInfoColumn('Nivel', curso['nivel'] as String, Icons.signal_cellular_alt_rounded, verde),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Descripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          Text(
            curso['descripcion'] as String,
            style: TextStyle(fontSize: 15, color: subtextColor, height: 1.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Temario',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          ...(curso['temario'] as List<String>).asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: azul.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: azul),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(entry.value, style: TextStyle(fontSize: 14, color: textColor)),
              ],
            ),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('¡Inscripción exitosa! Revisa tu correo para más detalles.'),
                    backgroundColor: azul,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_reg_rounded, size: 22),
                  SizedBox(width: 10),
                  Text('Inscribirme ahora', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContenidoObras(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    final obras = [
      {
        'nombre': 'Centro Logístico Regional Peñasco',
        'descripcion': 'Hub de distribución intermodal con conexión a autopista y ferrocarril. Incluirá bodegas, oficinas y estación de transferencia.',
        'avance': 0.67,
        'etapa': 'Construcción',
        'inversion': '\$1,200 MDP',
        'empleosGenerados': 320,
        'empleosPermanentes': 850,
        'fechaInicio': 'Mar 2024',
        'fechaFin': 'Dic 2025',
        'actualizado': 'Hace 3 días',
        'ubicacion': 'Zona Industrial Norte',
        'responsable': 'SCT / Gobierno Estatal',
        'icono': Icons.local_shipping_rounded,
        'color': dorado,
        'hitos': [
          {'nombre': 'Estudios de factibilidad', 'completado': true},
          {'nombre': 'Adquisición de terreno', 'completado': true},
          {'nombre': 'Cimentación y estructura', 'completado': true},
          {'nombre': 'Instalaciones eléctricas', 'completado': false},
          {'nombre': 'Equipamiento y pruebas', 'completado': false},
        ],
      },
      {
        'nombre': 'Parque Industrial Tecnológico',
        'descripcion': 'Complejo para empresas de manufactura avanzada y desarrollo tecnológico con laboratorios de innovación y centro de capacitación.',
        'avance': 0.45,
        'etapa': 'Edificación',
        'inversion': '\$2,800 MDP',
        'empleosGenerados': 540,
        'empleosPermanentes': 3200,
        'fechaInicio': 'Ene 2024',
        'fechaFin': 'Ago 2026',
        'actualizado': 'Hace 1 semana',
        'ubicacion': 'Corredor Industrial Este',
        'responsable': 'SEDECO / Iniciativa Privada',
        'icono': Icons.precision_manufacturing_rounded,
        'color': const Color(0xFF2563EB),
        'hitos': [
          {'nombre': 'Aprobación del proyecto', 'completado': true},
          {'nombre': 'Infraestructura básica', 'completado': true},
          {'nombre': 'Construcción Fase 1', 'completado': false},
          {'nombre': 'Construcción Fase 2', 'completado': false},
          {'nombre': 'Inauguración', 'completado': false},
        ],
      },
      {
        'nombre': 'Hospital Regional de Especialidades',
        'descripcion': 'Centro médico de tercer nivel con urgencias, quirófanos, UCI y unidades de diagnóstico. Atenderá a 15 municipios de la región.',
        'avance': 0.82,
        'etapa': 'Acabados',
        'inversion': '\$890 MDP',
        'empleosGenerados': 280,
        'empleosPermanentes': 420,
        'fechaInicio': 'Sep 2023',
        'fechaFin': 'Mar 2025',
        'actualizado': 'Hoy',
        'ubicacion': 'Zona Centro',
        'responsable': 'IMSS-Bienestar',
        'icono': Icons.local_hospital_rounded,
        'color': guinda,
        'hitos': [
          {'nombre': 'Diseño arquitectónico', 'completado': true},
          {'nombre': 'Obra civil', 'completado': true},
          {'nombre': 'Instalaciones especiales', 'completado': true},
          {'nombre': 'Acabados interiores', 'completado': true},
          {'nombre': 'Equipamiento médico', 'completado': false},
        ],
      },
      {
        'nombre': 'Planta de Tratamiento de Aguas',
        'descripcion': 'Planta con capacidad para tratar 500 litros por segundo, beneficiando a más de 80,000 habitantes con agua potable de calidad.',
        'avance': 0.23,
        'etapa': 'Cimentación',
        'inversion': '\$450 MDP',
        'empleosGenerados': 120,
        'empleosPermanentes': 45,
        'fechaInicio': 'Jun 2024',
        'fechaFin': 'Dic 2026',
        'actualizado': 'Hace 5 días',
        'ubicacion': 'Zona Sur',
        'responsable': 'CONAGUA / CEAS',
        'icono': Icons.water_drop_rounded,
        'color': verde,
        'hitos': [
          {'nombre': 'Estudios ambientales', 'completado': true},
          {'nombre': 'Excavación', 'completado': false},
          {'nombre': 'Cimentación', 'completado': false},
          {'nombre': 'Instalación de equipos', 'completado': false},
          {'nombre': 'Puesta en marcha', 'completado': false},
        ],
      },
    ];

    final inversionTotal = obras.fold<double>(0, (sum, obra) {
      final inv = (obra['inversion'] as String).replaceAll(RegExp(r'[^\d.]'), '');
      return sum + (double.tryParse(inv) ?? 0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con estadísticas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [dorado.withAlpha(20), dorado.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dorado.withAlpha(30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.construction_rounded, color: dorado, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${obras.length} obras en desarrollo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Inversión total: \$${inversionTotal.toStringAsFixed(0)} MDP',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildObraStat(
                      Icons.engineering_rounded,
                      '${obras.fold<int>(0, (s, o) => s + (o['empleosGenerados'] as int))}',
                      'Empleos en obra',
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildObraStat(
                      Icons.work_rounded,
                      '${obras.fold<int>(0, (s, o) => s + (o['empleosPermanentes'] as int))}',
                      'Empleos futuros',
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de obras
        ...obras.map((obra) => _buildObraCardMejorado(
          obra,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
        )),
      ],
    );
  }

  Widget _buildObraStat(IconData icon, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: dorado),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObraCardMejorado(
    Map<String, dynamic> obra,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
  ) {
    final avance = obra['avance'] as double;
    final color = obra['color'] as Color;
    
    Color avanceColor;
    if (avance >= 0.75) {
      avanceColor = verde;
    } else if (avance >= 0.4) {
      avanceColor = dorado;
    } else {
      avanceColor = Colors.orange;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetalleObra(context, obra, isDark, textColor, subtextColor, borderColor),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        obra['icono'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obra['nombre'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  obra['etapa'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.location_on_rounded, size: 12, color: subtextColor),
                              const SizedBox(width: 3),
                              Text(
                                obra['ubicacion'] as String,
                                style: TextStyle(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(avance * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: avanceColor,
                          ),
                        ),
                        Text(
                          obra['actualizado'] as String,
                          style: TextStyle(fontSize: 10, color: subtextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barra de progreso mejorada
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: avance,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [avanceColor, avanceColor.withAlpha(180)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Info resumida
                Row(
                  children: [
                    Icon(Icons.attach_money_rounded, size: 16, color: dorado),
                    const SizedBox(width: 4),
                    Text(
                      obra['inversion'] as String,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const Spacer(),
                    Icon(Icons.people_rounded, size: 16, color: subtextColor),
                    const SizedBox(width: 4),
                    Text(
                      '${obra['empleosPermanentes']} empleos',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleObra(
    BuildContext context,
    Map<String, dynamic> obra,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    final avance = obra['avance'] as double;
    final color = obra['color'] as Color;
    final hitos = obra['hitos'] as List<Map<String, dynamic>>;
    
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 700,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withAlpha(180)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        obra['icono'] as IconData,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(avance * 100).toInt()}% completado',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  obra['nombre'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        obra['etapa'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      obra['ubicacion'] as String,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats cards
          Row(
            children: [
              Expanded(child: _buildObraStatCard(Icons.attach_money_rounded, obra['inversion'] as String, 'Inversión', dorado, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildObraStatCard(Icons.engineering_rounded, '${obra['empleosGenerados']}', 'En obra', Colors.orange, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildObraStatCard(Icons.work_rounded, '${obra['empleosPermanentes']}', 'Permanentes', verde, isDark)),
            ],
          ),
          const SizedBox(height: 24),
          // Descripción
          Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          Text(
            obra['descripcion'] as String,
            style: TextStyle(fontSize: 15, color: subtextColor, height: 1.6),
          ),
          const SizedBox(height: 24),
          // Fechas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.play_circle_outline_rounded, color: verde, size: 28),
                      const SizedBox(height: 6),
                      Text('Inicio', style: TextStyle(fontSize: 12, color: subtextColor)),
                      Text(obra['fechaInicio'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: borderColor),
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.flag_rounded, color: guinda, size: 28),
                      const SizedBox(height: 6),
                      Text('Fin estimado', style: TextStyle(fontSize: 12, color: subtextColor)),
                      Text(obra['fechaFin'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Hitos
          Text('Avance del proyecto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          ...hitos.asMap().entries.map((entry) {
            final index = entry.key;
            final hito = entry.value;
            final completado = hito['completado'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: completado ? verde : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: completado
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.grey))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      hito['nombre'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: completado ? textColor : subtextColor,
                        fontWeight: completado ? FontWeight.w600 : FontWeight.normal,
                        decoration: completado ? TextDecoration.none : null,
                      ),
                    ),
                  ),
                  if (completado)
                    Icon(Icons.verified_rounded, color: verde, size: 20),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          // Responsable
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(30)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Responsable', style: TextStyle(fontSize: 12, color: subtextColor)),
                      Text(obra['responsable'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Botones
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Recibirás actualizaciones de esta obra'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Seguir esta obra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded),
              label: const Text('Compartir información'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: color),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildObraStatCard(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContenidoNoticias(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    const Color morado = Color(0xFF9333EA);
    final noticias = [
      {
        'titulo': 'Inauguran nueva planta solar con capacidad de 500 MW en Sonora',
        'resumen': 'La planta generará energía limpia para más de 200,000 hogares y creará 800 empleos permanentes en la región.',
        'tiempo': 'Hace 2 horas',
        'categoria': 'Energía',
        'categoriaColor': verde,
        'fuente': 'Secretaría de Energía',
        'icono': Icons.solar_power_rounded,
        'contenido': 'El Gobierno de México inauguró hoy la planta solar "Sol del Norte" en el municipio de Hermosillo, Sonora. Con una inversión de 450 millones de dólares, esta instalación representa un avance significativo en la transición energética del país.\n\nLa planta cuenta con más de 1.2 millones de paneles solares distribuidos en 800 hectáreas, convirtiéndose en una de las más grandes de Latinoamérica. Se espera que genere aproximadamente 1,100 GWh al año.',
        'imagen': 'solar_plant',
      },
      {
        'titulo': 'Polo Industrial Norte genera 500 nuevos empleos en manufactura',
        'resumen': 'Tres nuevas empresas se instalan en el parque industrial con inversión combinada de 120 millones de dólares.',
        'tiempo': 'Hace 5 horas',
        'categoria': 'Economía',
        'categoriaColor': dorado,
        'fuente': 'Secretaría de Economía',
        'icono': Icons.factory_rounded,
        'contenido': 'El Polo de Desarrollo Industrial Norte anunció la llegada de tres empresas del sector manufacturero que generarán 500 empleos directos en los próximos meses.\n\nLas compañías, provenientes de Estados Unidos y Alemania, iniciarán operaciones en el primer trimestre de 2026 con una inversión combinada de 120 millones de dólares.',
        'imagen': 'factory',
      },
      {
        'titulo': 'Gobierno lanza programa de becas para jóvenes en tecnología',
        'resumen': 'Más de 10,000 becas disponibles para cursos de programación, inteligencia artificial y ciberseguridad.',
        'tiempo': 'Ayer',
        'categoria': 'Educación',
        'categoriaColor': const Color(0xFF2563EB),
        'fuente': 'SEP',
        'icono': Icons.school_rounded,
        'contenido': 'La Secretaría de Educación Pública presentó el programa "Código Futuro", que otorgará 10,000 becas para jóvenes de 18 a 29 años interesados en formarse en tecnologías de la información.\n\nEl programa incluye cursos en programación, inteligencia artificial, ciberseguridad y análisis de datos, con una duración de 6 a 12 meses y certificación oficial.',
        'imagen': 'education',
      },
      {
        'titulo': 'Avanza construcción del Tren Interoceánico con 78% de avance',
        'resumen': 'El megaproyecto conectará los océanos Pacífico y Atlántico, impulsando el comercio internacional.',
        'tiempo': 'Hace 2 días',
        'categoria': 'Infraestructura',
        'categoriaColor': guinda,
        'fuente': 'SICT',
        'icono': Icons.train_rounded,
        'contenido': 'La Secretaría de Infraestructura reportó un avance del 78% en la construcción del Corredor Interoceánico del Istmo de Tehuantepec.\n\nEste proyecto estratégico modernizará 300 km de vías férreas y creará 10 polos de desarrollo industrial a lo largo de su trayecto, generando más de 100,000 empleos directos e indirectos.',
        'imagen': 'train',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [morado.withAlpha(20), morado.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: morado.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.newspaper_rounded, color: morado, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Noticias de tu región',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Mantente informado de lo que pasa en $_estadoUsuario',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de noticias
        ...noticias.map((noticia) => _buildNoticiaCardMejorada(
          noticia,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
          morado,
        )),
      ],
    );
  }

  Widget _buildNoticiaCardMejorada(
    Map<String, dynamic> noticia,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
    Color morado,
  ) {
    final categoriaColor = noticia['categoriaColor'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetalleNoticia(context, noticia, isDark, textColor, subtextColor, morado),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: morado.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [categoriaColor, categoriaColor.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        noticia['icono'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: categoriaColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  noticia['categoria'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: categoriaColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.access_time_rounded, size: 12, color: subtextColor),
                              const SizedBox(width: 4),
                              Text(
                                noticia['tiempo'] as String,
                                style: TextStyle(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            noticia['titulo'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  noticia['resumen'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtextColor,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.source_rounded, size: 14, color: subtextColor),
                    const SizedBox(width: 6),
                    Text(
                      noticia['fuente'] as String,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                    const Spacer(),
                    Text(
                      'Leer más',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: morado,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: morado),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleNoticia(
    BuildContext context,
    Map<String, dynamic> noticia,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color morado,
  ) {
    final categoriaColor = noticia['categoriaColor'] as Color;
    
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 700,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen representativa (placeholder con gradiente)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [categoriaColor, categoriaColor.withAlpha(150)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    noticia['icono'] as IconData,
                    size: 80,
                    color: Colors.white.withAlpha(60),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(noticia['icono'] as IconData, size: 16, color: categoriaColor),
                        const SizedBox(width: 6),
                        Text(
                          noticia['categoria'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: categoriaColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Metadata
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: subtextColor),
              const SizedBox(width: 6),
              Text(noticia['tiempo'] as String, style: TextStyle(color: subtextColor)),
              const SizedBox(width: 16),
              Icon(Icons.source_rounded, size: 16, color: subtextColor),
              const SizedBox(width: 6),
              Text(noticia['fuente'] as String, style: TextStyle(color: subtextColor)),
            ],
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            noticia['titulo'] as String,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          // Contenido
          Text(
            noticia['contenido'] as String,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          // Acciones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: morado,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: morado),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_rounded),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: morado,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContenidoPolos(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    // Datos de ejemplo de polos de desarrollo
    final polosEjemplo = [
      {
        'nombre': 'Polo de Desarrollo Tecnológico Norte',
        'region': 'Zona Metropolitana Norte',
        'descripcion': 'Hub de innovación tecnológica con incubadoras de startups, laboratorios de I+D y espacios de coworking para emprendedores.',
        'sector': 'Tecnología',
        'empresas': 45,
        'empleos': 2800,
        'inversion': '\$4,500 MDP',
        'servicios': ['Incubadora de empresas', 'Laboratorio de prototipos', 'Centro de capacitación', 'Bolsa de trabajo'],
        'icono': Icons.computer_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'nombre': 'Parque Agroindustrial del Valle',
        'region': 'Corredor Agrícola Sur',
        'descripcion': 'Centro de procesamiento y transformación de productos agrícolas con certificaciones de calidad internacional.',
        'sector': 'Agroindustria',
        'empresas': 28,
        'empleos': 1500,
        'inversion': '\$2,200 MDP',
        'servicios': ['Plantas de procesamiento', 'Almacenamiento frío', 'Laboratorio de calidad', 'Centro de exportación'],
        'icono': Icons.agriculture_rounded,
        'color': verde,
      },
      {
        'nombre': 'Corredor Industrial de Manufactura',
        'region': 'Zona Industrial Este',
        'descripcion': 'Complejo manufacturero especializado en electrónica, automotriz y aeroespacial con acceso a mercados internacionales.',
        'sector': 'Manufactura',
        'empresas': 62,
        'empleos': 8500,
        'inversion': '\$12,800 MDP',
        'servicios': ['Naves industriales', 'Centro logístico', 'Aduana interior', 'Parque de proveedores'],
        'icono': Icons.precision_manufacturing_rounded,
        'color': dorado,
      },
      {
        'nombre': 'Polo de Energías Renovables',
        'region': 'Zona Desértica Oeste',
        'descripcion': 'Desarrollo integral de proyectos de energía solar y eólica con capacitación especializada y centro de investigación.',
        'sector': 'Energía',
        'empresas': 18,
        'empleos': 950,
        'inversion': '\$6,100 MDP',
        'servicios': ['Plantas solares', 'Parque eólico', 'Centro de capacitación', 'Laboratorio de baterías'],
        'icono': Icons.solar_power_rounded,
        'color': Colors.orange,
      },
    ];

    final totalEmpresas = polosEjemplo.fold<int>(0, (s, p) => s + (p['empresas'] as int));
    final totalEmpleos = polosEjemplo.fold<int>(0, (s, p) => s + (p['empleos'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [guinda.withAlpha(20), guinda.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: guinda.withAlpha(30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.hub_rounded, color: guinda, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${polosEjemplo.length} polos de desarrollo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Zonas estratégicas de inversión en tu región',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildPoloStatBadge(Icons.business_rounded, '$totalEmpresas', 'Empresas', guinda, isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPoloStatBadge(Icons.people_rounded, '$totalEmpleos', 'Empleos', verde, isDark),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de polos
        ...polosEjemplo.map((polo) => _buildPoloCardMejorado(
          polo,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
        )),
      ],
    );
  }

  Widget _buildPoloStatBadge(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoloCardMejorado(
    Map<String, dynamic> polo,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
  ) {
    final color = polo['color'] as Color;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetallePoloMejorado(context, polo, isDark, textColor, subtextColor),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        polo['icono'] as IconData,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            polo['nombre'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  polo['sector'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Ubicación
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: subtextColor),
                    const SizedBox(width: 4),
                    Text(
                      polo['region'] as String,
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats en línea
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPoloMiniStat(Icons.business_rounded, '${polo['empresas']}', 'Empresas', color),
                      Container(width: 1, height: 30, color: borderColor),
                      _buildPoloMiniStat(Icons.people_rounded, '${polo['empleos']}', 'Empleos', verde),
                      Container(width: 1, height: 30, color: borderColor),
                      _buildPoloMiniStat(Icons.attach_money_rounded, (polo['inversion'] as String).replaceAll(' MDP', ''), 'MDP', dorado),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoloMiniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  void _mostrarDetallePoloMejorado(
    BuildContext context,
    Map<String, dynamic> polo,
    bool isDark,
    Color textColor,
    Color subtextColor,
  ) {
    final color = polo['color'] as Color;
    final servicios = polo['servicios'] as List<String>;
    
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 700,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withAlpha(180)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        polo['icono'] as IconData,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        polo['sector'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  polo['nombre'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      polo['region'] as String,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats cards
          Row(
            children: [
              Expanded(child: _buildPoloDetailStat(Icons.business_rounded, '${polo['empresas']}', 'Empresas', color, isDark)),
              const SizedBox(width: 10),
              Expanded(child: _buildPoloDetailStat(Icons.people_rounded, '${polo['empleos']}', 'Empleos', verde, isDark)),
              const SizedBox(width: 10),
              Expanded(child: _buildPoloDetailStat(Icons.attach_money_rounded, polo['inversion'] as String, 'Inversión', dorado, isDark)),
            ],
          ),
          const SizedBox(height: 24),
          // Descripción
          Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          Text(
            polo['descripcion'] as String,
            style: TextStyle(fontSize: 15, color: subtextColor, height: 1.6),
          ),
          const SizedBox(height: 24),
          // Servicios
          Text('Servicios e Infraestructura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: servicios.map((servicio) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    servicio,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          // Botones
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Solicitud de información enviada'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('Solicitar más información'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Ver en mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPoloDetailStat(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContenidoEventos(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    const Color teal = Color(0xFF0D9488);
    final eventos = [
      {
        'titulo': 'Feria del Empleo 2025',
        'fecha': '15 Dic',
        'hora': '9:00 - 18:00',
        'lugar': 'Centro de Convenciones',
        'direccion': 'Av. Reforma 123, Centro',
        'descripcion': 'Más de 50 empresas ofreciendo vacantes en manufactura, tecnología, servicios y más. Trae tu CV impreso y vístete formal.',
        'tipo': 'Empleo',
        'tipoColor': verde,
        'icono': Icons.work_rounded,
        'cupoMaximo': 500,
        'registrados': 312,
        'esGratis': true,
      },
      {
        'titulo': 'Taller de Emprendimiento Social',
        'fecha': '18 Dic',
        'hora': '10:00 - 14:00',
        'lugar': 'Biblioteca Pública',
        'direccion': 'Calle Juárez 45, Zona Centro',
        'descripcion': 'Aprende a desarrollar proyectos de impacto social. Incluye mentoría con emprendedores exitosos y certificado de participación.',
        'tipo': 'Capacitación',
        'tipoColor': const Color(0xFF2563EB),
        'icono': Icons.lightbulb_rounded,
        'cupoMaximo': 40,
        'registrados': 28,
        'esGratis': true,
      },
      {
        'titulo': 'Expo Agroindustria Norte',
        'fecha': '20-22 Dic',
        'hora': '10:00 - 20:00',
        'lugar': 'Parque Industrial',
        'direccion': 'Carretera Norte km 5',
        'descripcion': 'Exposición de maquinaria agrícola, tecnología de riego, semillas y productos orgánicos. Conferencias magistrales y rueda de negocios.',
        'tipo': 'Exposición',
        'tipoColor': dorado,
        'icono': Icons.agriculture_rounded,
        'cupoMaximo': 2000,
        'registrados': 856,
        'esGratis': false,
      },
      {
        'titulo': 'Conferencia: Energías Renovables',
        'fecha': '28 Dic',
        'hora': '17:00 - 19:00',
        'lugar': 'Auditorio Municipal',
        'direccion': 'Plaza Principal s/n',
        'descripcion': 'Expertos nacionales e internacionales hablarán sobre el futuro de las energías limpias en México y las oportunidades de inversión.',
        'tipo': 'Conferencia',
        'tipoColor': guinda,
        'icono': Icons.solar_power_rounded,
        'cupoMaximo': 300,
        'registrados': 187,
        'esGratis': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [teal.withAlpha(20), teal.withAlpha(8)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: teal.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.event_rounded, color: teal, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${eventos.length} eventos próximos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Ferias, talleres y conferencias en tu región',
                      style: TextStyle(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Esta semana',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Lista de eventos
        ...eventos.map((evento) => _buildEventoCardMejorado(
          evento,
          isDark,
          textColor,
          subtextColor,
          borderColor,
          context,
          teal,
        )),
      ],
    );
  }

  Widget _buildEventoCardMejorado(
    Map<String, dynamic> evento,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
    BuildContext context,
    Color teal,
  ) {
    final tipoColor = evento['tipoColor'] as Color;
    final registrados = evento['registrados'] as int;
    final cupoMaximo = evento['cupoMaximo'] as int;
    final porcentajeOcupado = registrados / cupoMaximo;
    final cuposDisponibles = cupoMaximo - registrados;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _mostrarDetalleEvento(context, evento, isDark, textColor, subtextColor, teal),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252530) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: teal.withAlpha(isDark ? 15 : 8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha destacada
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tipoColor, tipoColor.withAlpha(180)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (evento['fecha'] as String).split(' ')[0],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        (evento['fecha'] as String).contains(' ')
                            ? (evento['fecha'] as String).split(' ')[1]
                            : 'Dic',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Info del evento
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tipoColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              evento['tipo'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: tipoColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (evento['esGratis'] as bool)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: verde.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'GRATIS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: verde,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evento['titulo'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: subtextColor),
                          const SizedBox(width: 4),
                          Text(
                            evento['hora'] as String,
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: subtextColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              evento['lugar'] as String,
                              style: TextStyle(fontSize: 12, color: subtextColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Barra de cupo
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: porcentajeOcupado,
                                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(
                                      porcentajeOcupado > 0.8 ? Colors.orange : teal,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$cuposDisponibles lugares disponibles',
                                  style: TextStyle(fontSize: 11, color: subtextColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 18, color: teal),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleEvento(
    BuildContext context,
    Map<String, dynamic> evento,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color teal,
  ) {
    final tipoColor = evento['tipoColor'] as Color;
    final registrados = evento['registrados'] as int;
    final cupoMaximo = evento['cupoMaximo'] as int;
    final cuposDisponibles = cupoMaximo - registrados;
    
    _mostrarModalAdaptativo(
      context: context,
      isDark: isDark,
      desktopWidth: 650,
      contentBuilder: (scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tipoColor, tipoColor.withAlpha(180)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        evento['icono'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    if (evento['esGratis'] as bool)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✓ ENTRADA GRATIS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  evento['titulo'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    evento['tipo'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Info cards
          Row(
            children: [
              Expanded(
                child: _buildEventoInfoCard(
                  Icons.calendar_today_rounded,
                  'Fecha',
                  evento['fecha'] as String,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEventoInfoCard(
                  Icons.schedule_rounded,
                  'Horario',
                  evento['hora'] as String,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEventoInfoCard(
            Icons.location_on_rounded,
            evento['lugar'] as String,
            evento['direccion'] as String,
            isDark,
          ),
          const SizedBox(height: 24),
          // Descripción
          Text(
            'Descripción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),
          Text(
            evento['descripcion'] as String,
            style: TextStyle(fontSize: 15, color: subtextColor, height: 1.6),
          ),
          const SizedBox(height: 24),
          // Cupo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: teal.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: teal.withAlpha(30)),
            ),
            child: Row(
              children: [
                Icon(Icons.people_rounded, color: teal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cuposDisponibles lugares disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '$registrados de $cupoMaximo registrados',
                        style: TextStyle(fontSize: 13, color: subtextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Botón registrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Te has registrado a "${evento['titulo']}"!'),
                    backgroundColor: teal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded, size: 22),
                  SizedBox(width: 10),
                  Text('Registrarme al evento', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded),
              label: const Text('Compartir evento'),
              style: OutlinedButton.styleFrom(
                foregroundColor: teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: teal),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEventoInfoCard(IconData icon, String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252530) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: isDark ? Colors.white70 : Colors.grey.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _mostrarDetallePolo(BuildContext context, PoloMarker polo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    final contentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [guinda, Color(0xFF8B2346)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${polo.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    polo.nombre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${polo.estado} • ${polo.region}',
                    style: TextStyle(fontSize: 13, color: subtextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (polo.vocacion.isNotEmpty)
          _buildInfoCard(
            Icons.lightbulb_rounded,
            dorado,
            'Vocación',
            polo.vocacion,
            isDark,
            textColor,
            subtextColor,
            borderColor,
          ),
        if (polo.sectoresClave.isNotEmpty)
          _buildInfoCard(
            Icons.business_rounded,
            const Color(0xFF2563EB),
            'Sectores Clave',
            polo.sectoresClave.join(', '),
            isDark,
            textColor,
            subtextColor,
            borderColor,
          ),
        if (polo.infraestructura.isNotEmpty)
          _buildInfoCard(
            Icons.construction_rounded,
            Colors.orange,
            'Infraestructura',
            polo.infraestructura,
            isDark,
            textColor,
            subtextColor,
            borderColor,
          ),
        if (polo.empleoEstimado.isNotEmpty)
          _buildInfoCard(
            Icons.groups_rounded,
            verde,
            'Empleo Estimado',
            polo.empleoEstimado,
            isDark,
            textColor,
            subtextColor,
            borderColor,
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEncuestaDialog(polo);
            },
            icon: const Icon(Icons.rate_review_rounded, size: 20),
            label: const Text('Dar mi opinión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: guinda,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );

    if (_isWideScreen(context)) {
      // Desktop: Diálogo centrado
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Container(
            width: 650,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: subtextColor,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: contentWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mobile: Bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: contentWidget,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildInfoCard(
    IconData icon,
    Color iconColor,
    String title,
    String content,
    bool isDark,
    Color textColor,
    Color subtextColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEncuestaDialog(PoloMarker polo) {
    final poloData = PolosData.getPoloByStringId(polo.idString);
    int poloId =
        poloData?.id ??
        PolosDatabase.findPoloIdByName(polo.nombre, polo.estado) ??
        1;

    EncuestaPoloScreen.show(
      context,
      poloId: poloId,
      poloNombre: polo.nombre,
      poloEstado: polo.estado,
      poloDescripcion: poloData?.descripcion ?? polo.descripcion,
      onEncuestaEnviada: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  '¡Opinión registrada!',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// WIDGET PARA SELECTOR DE UBICACIÓN CON PASOS
// ════════════════════════════════════════════════════════════════════════════════
class _SelectorUbicacionDialog extends StatefulWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;
  final bool isWide;
  final Size screenSize;
  final String estadoActual;
  final String municipioActual;
  final Map<String, List<String>> municipiosPorEstado;
  final void Function(String estado, String municipio) onUbicacionSeleccionada;

  const _SelectorUbicacionDialog({
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
    required this.isWide,
    required this.screenSize,
    required this.estadoActual,
    required this.municipioActual,
    required this.municipiosPorEstado,
    required this.onUbicacionSeleccionada,
  });

  @override
  State<_SelectorUbicacionDialog> createState() =>
      _SelectorUbicacionDialogState();
}

class _SelectorUbicacionDialogState extends State<_SelectorUbicacionDialog> {
  int _paso = 1; // 1 = seleccionar estado, 2 = seleccionar municipio
  String? _estadoSeleccionado;
  String _busqueda = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _estados => widget.municipiosPorEstado.keys.toList()..sort();

  List<String> get _municipios {
    if (_estadoSeleccionado == null) return [];
    return widget.municipiosPorEstado[_estadoSeleccionado] ?? [];
  }

  List<String> get _itemsFiltrados {
    final items = _paso == 1 ? _estados : _municipios;
    if (_busqueda.isEmpty) return items;
    return items
        .where((item) => item.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: widget.isWide ? widget.screenSize.width * 0.2 : 24,
          vertical: widget.isWide ? 60 : 80,
        ),
        constraints: BoxConstraints(
          maxWidth: widget.isWide ? 500 : widget.screenSize.width - 48,
          maxHeight: widget.screenSize.height - (widget.isWide ? 120 : 160),
        ),
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(),
                // Indicador de pasos
                _buildPasoIndicator(),
                // Buscador
                _buildSearchBar(),
                // Lista de opciones
                Flexible(child: _buildLista()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            guinda.withAlpha(widget.isDark ? 60 : 25),
            guinda.withAlpha(widget.isDark ? 30 : 10),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: guinda.withAlpha(widget.isDark ? 80 : 40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: guinda,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _paso == 1
                      ? 'Selecciona tu estado'
                      : 'Selecciona tu municipio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _paso == 1 ? 'Paso 1 de 2' : 'Estado: $_estadoSeleccionado',
                  style: TextStyle(fontSize: 13, color: widget.subtextColor),
                ),
              ],
            ),
          ),
          if (_paso == 2)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _paso = 1;
                    _estadoSeleccionado = null;
                    _busqueda = '';
                    _searchController.clear();
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: widget.subtextColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.black.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: widget.subtextColor,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildPasoCircle(1, 'Estado', _paso >= 1),
          Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: _paso >= 2
                    ? guinda
                    : (widget.isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildPasoCircle(2, 'Municipio', _paso >= 2),
        ],
      ),
    );
  }

  Widget _buildPasoCircle(int numero, String label, bool activo) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: activo
                ? guinda
                : (widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: activo && _paso > numero
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    '$numero',
                    style: TextStyle(
                      color: activo ? Colors.white : widget.subtextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: activo ? guinda : widget.subtextColor,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _busqueda = value),
        decoration: InputDecoration(
          hintText: _paso == 1 ? 'Buscar estado...' : 'Buscar municipio...',
          hintStyle: TextStyle(color: widget.subtextColor.withAlpha(150)),
          prefixIcon: Icon(Icons.search_rounded, color: widget.subtextColor),
          suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _busqueda = '');
                  },
                  icon: Icon(Icons.clear_rounded, color: widget.subtextColor),
                )
              : null,
          filled: true,
          fillColor: widget.isDark
              ? Colors.white.withAlpha(10)
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: TextStyle(color: widget.textColor),
      ),
    );
  }

  Widget _buildLista() {
    final items = _itemsFiltrados;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: widget.subtextColor.withAlpha(100),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados',
                style: TextStyle(color: widget.subtextColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _paso == 1
            ? item == widget.estadoActual
            : item == widget.municipioActual &&
                  _estadoSeleccionado == widget.estadoActual;

        // Contar polos en el estado (solo para paso 1)
        int polosCount = 0;
        if (_paso == 1) {
          polosCount = PolosData.polos.where((p) => p.estado == item).length;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isSelected
                ? guinda.withAlpha(widget.isDark ? 40 : 20)
                : (widget.isDark
                      ? Colors.white.withAlpha(5)
                      : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                if (_paso == 1) {
                  setState(() {
                    _estadoSeleccionado = item;
                    _paso = 2;
                    _busqueda = '';
                    _searchController.clear();
                  });
                } else {
                  widget.onUbicacionSeleccionada(_estadoSeleccionado!, item);
                  Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? guinda.withAlpha(40)
                            : (widget.isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _paso == 1 ? Icons.map_rounded : Icons.place_rounded,
                        color: isSelected ? guinda : widget.subtextColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? guinda : widget.textColor,
                        ),
                      ),
                    ),
                    if (_paso == 1 && polosCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: verde.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$polosCount polos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: verde,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_paso == 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: widget.subtextColor,
                          size: 22,
                        ),
                      ),
                    if (isSelected && _paso == 2)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: guinda,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// WIDGET PARA DIÁLOGO DE MÓDULO CON TUTORIAL
// ════════════════════════════════════════════════════════════════════════════════
class _ModuleDialog extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final Widget Function(BuildContext, bool, Color, Color, Color, Color)
  contenidoBuilder;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;
  final bool isWide;
  final Size screenSize;
  final String moduleName;

  const _ModuleDialog({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.contenidoBuilder,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
    required this.isWide,
    required this.screenSize,
    required this.moduleName,
  });

  @override
  State<_ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<_ModuleDialog> {
  bool _showTutorial = false;
  int _tutorialStep = 1;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'seen_module_${widget.moduleName.toLowerCase()}_tutorial';
    bool seen = prefs.getBool(key) ?? false;

    if (!seen) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showTutorial = true;
          _tutorialStep = 1;
        });
      }
    }
  }

  void _nextTutorialStep() {
    if (_tutorialStep < 2) {
      setState(() => _tutorialStep++);
    } else {
      _closeTutorial();
    }
  }

  void _closeTutorial() async {
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    final key = 'seen_module_${widget.moduleName.toLowerCase()}_tutorial';
    await prefs.setBool(key, true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: widget.isWide ? widget.screenSize.width * 0.15 : 20,
          vertical: widget.isWide ? 40 : 60,
        ),
        constraints: BoxConstraints(
          maxWidth: widget.isWide ? 700 : widget.screenSize.width - 40,
          maxHeight: widget.screenSize.height - (widget.isWide ? 80 : 120),
        ),
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(40),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con gradiente
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color.withAlpha(widget.isDark ? 60 : 25),
                            widget.color.withAlpha(widget.isDark ? 30 : 10),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: widget.color.withAlpha(
                                widget.isDark ? 80 : 40,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.color.withAlpha(60),
                              ),
                            ),
                            child: Icon(
                              widget.icono,
                              color: widget.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.titulo,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: widget.textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Información actualizada',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: widget.subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? Colors.white.withAlpha(15)
                                      : Colors.black.withAlpha(8),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: widget.textColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contenido scrolleable
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: widget.contenidoBuilder(
                          context,
                          widget.isDark,
                          widget.cardColor,
                          widget.textColor,
                          widget.subtextColor,
                          widget.isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.grey.shade200,
                        ),
                      ),
                    ),
                  ],
                ),

                // Tutorial Overlay
                if (_showTutorial)
                  ModuleTutorialOverlay(
                    moduleName: widget.moduleName,
                    step: _tutorialStep,
                    onNext: _nextTutorialStep,
                    onSkip: _closeTutorial,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
