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
  // CONTENIDO DE CADA MÓDULO
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
      },
      {
        'titulo': 'Operador de Maquinaria',
        'empresa': 'Minera Sonora',
        'sector': 'Minería',
        'salario': '\$22,000/mes',
        'distancia': '25 km',
      },
      {
        'titulo': 'Ingeniero de Procesos',
        'empresa': 'Planta Solar',
        'sector': 'Energía',
        'salario': '\$35,000/mes',
        'distancia': '8 km',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${empleos.length} empleos disponibles en $_estadoUsuario',
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 16),
        ...empleos.map(
          (empleo) => _buildEmpleoCard(
            empleo,
            isDark,
            cardColor,
            textColor,
            subtextColor,
            borderColor,
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
    final cursos = [
      {
        'nombre': 'Soldadura Industrial',
        'duracion': '40 horas',
        'modalidad': 'Presencial',
      },
      {
        'nombre': 'Excel Avanzado',
        'duracion': '20 horas',
        'modalidad': 'En línea',
      },
      {
        'nombre': 'Electricidad Básica',
        'duracion': '60 horas',
        'modalidad': 'Presencial',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cursos disponibles para tu región',
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 16),
        ...cursos.map(
          (curso) => Container(
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
                    color: const Color(0xFF2563EB).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curso['nombre']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${curso['duracion']} • ${curso['modalidad']}',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        'nombre': 'Centro Logístico Peñasco',
        'avance': 0.67,
        'actualizado': 'Hace 3 días',
      },
      {
        'nombre': 'Parque Industrial Norte',
        'avance': 0.45,
        'actualizado': 'Hace 1 semana',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proyectos en desarrollo en tu región',
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 16),
        ...obras.map(
          (obra) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: dorado.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.engineering_rounded,
                        color: dorado,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        obra['nombre'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      '${((obra['avance'] as double) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: verde,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: obra['avance'] as double,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(verde),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  obra['actualizado'] as String,
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
          ),
        ),
      ],
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
    final noticias = [
      {
        'titulo': 'Inauguran nueva planta solar en Sonora',
        'tiempo': 'Hace 2 horas',
        'categoria': 'Energía',
      },
      {
        'titulo': '500 empleos nuevos gracias al polo industrial',
        'tiempo': 'Ayer',
        'categoria': 'Economía',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimas noticias de $_estadoUsuario',
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 16),
        ...noticias.map(
          (noticia) => Container(
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
                    color: Colors.purple.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.article_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        noticia['titulo']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            noticia['tiempo']!,
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: dorado.withAlpha(26),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              noticia['categoria']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: dorado,
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
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_polosCercanos.length} polos disponibles en $_estadoUsuario',
          style: TextStyle(fontSize: 14, color: subtextColor),
        ),
        const SizedBox(height: 16),
        if (_polosCercanos.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline_rounded, color: dorado, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Próximamente habrá polos de desarrollo en tu región',
                  style: TextStyle(fontSize: 14, color: textColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._polosCercanos.map(
            (polo) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _mostrarDetallePolo(context, polo);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: guinda.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: guinda.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_city_rounded,
                        color: guinda,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            polo.nombre,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            polo.region,
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: subtextColor),
                  ],
                ),
              ),
            ),
          ),
      ],
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
    // Módulo aún no implementado - mostrar mensaje
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_rounded,
              color: Colors.teal,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Próximamente',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estamos trabajando para traerte información sobre ferias de empleo, conferencias y talleres en tu región.',
            style: TextStyle(fontSize: 14, color: subtextColor, height: 1.5),
            textAlign: TextAlign.center,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                child: Row(
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: subtextColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
