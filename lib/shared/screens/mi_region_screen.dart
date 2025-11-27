import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/polos_data.dart';
import 'encuesta_polo_screen.dart';
import '../../service/encuesta_service.dart';
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
  // Datos del usuario (simulados - después vendrán de SharedPreferences)
  String _municipioUsuario = 'Puerto Peñasco';
  String _estadoUsuario = 'Sonora';
  String _descripcionMunicipio =
      'Destino turístico del noroeste mexicano, conocido por sus playas y desarrollo industrial sostenible.';

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
  // LAYOUT WEB/DESKTOP
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
    final screenWidth = MediaQuery.of(context).size.width;
    // Si es muy ancho, mostrar layout de 2 columnas, sino todo en una
    final showTwoColumns = screenWidth > 1100;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero full width pegado arriba
        SliverToBoxAdapter(child: _buildHeroSection(isDark, isWide: true)),
        // Contenido con ancho máximo centrado
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: showTwoColumns
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Columna izquierda: Módulos (más espacio)
                          Expanded(
                            flex: 5,
                            child: _buildModulosPanelWeb(
                              context,
                              isDark,
                              cardColor,
                              textColor,
                              subtextColor,
                            ),
                          ),
                          const SizedBox(width: 28),
                          // Columna derecha: Pregunta del día (flexible)
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                const SizedBox(height: 108),
                                _buildPreguntaDelDia(
                                  isDark,
                                  cardColor,
                                  textColor,
                                  subtextColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildModulosPanelWeb(
                            context,
                            isDark,
                            cardColor,
                            textColor,
                            subtextColor,
                          ),
                          const SizedBox(height: 28),
                          _buildPreguntaDelDia(
                            isDark,
                            cardColor,
                            textColor,
                            subtextColor,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
              // Botón cambiar ubicación
              Material(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _mostrarSelectorUbicacion(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: const Icon(
                      Icons.edit_location_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
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

  Widget _buildHeroContentWide() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono grande de ubicación
          Container(
            padding: const EdgeInsets.all(24),
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
              Icons.location_on_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(width: 32),
          // Info del municipio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _municipioUsuario,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: dorado.withAlpha(60),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: dorado.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            color: dorado,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _estadoUsuario,
                            style: const TextStyle(
                              fontSize: 15,
                              color: dorado,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _descripcionMunicipio,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(200),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Botón cambiar ubicación (más visible en web)
          Material(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => _mostrarSelectorUbicacion(context),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withAlpha(30)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_location_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Cambiar ubicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
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
        'emoji': '💼',
        'titulo': 'Empleos',
        'valor': '$_empleosNuevos nuevos',
        'color': verde,
        'descripcion': 'Oportunidades laborales cerca de ti',
        'onTap': () => _navegarAModulo(context, 'empleos'),
      },
      {
        'emoji': '📚',
        'titulo': 'Cursos',
        'valor': '$_cursosDisponibles disponibles',
        'color': const Color(0xFF2563EB),
        'descripcion': 'Capacitación y talleres',
        'onTap': () => _navegarAModulo(context, 'cursos'),
      },
      {
        'emoji': '🏗️',
        'titulo': 'Obras',
        'valor': '+${_avanceObras.toStringAsFixed(0)}% avance',
        'color': dorado,
        'descripcion': 'Proyectos en construcción',
        'onTap': () => _navegarAModulo(context, 'obras'),
      },
      {
        'emoji': '📰',
        'titulo': 'Noticias',
        'valor': '$_noticiasRecientes recientes',
        'color': Colors.purple,
        'descripcion': 'Últimas novedades locales',
        'onTap': () => _navegarAModulo(context, 'noticias'),
      },
      {
        'emoji': '🏭',
        'titulo': 'Polos',
        'valor': '${_polosCercanos.length} cercanos',
        'color': guinda,
        'descripcion': 'Polos de desarrollo',
        'onTap': () => _navegarAModulo(context, 'polos'),
      },
      {
        'emoji': '🎓',
        'titulo': 'Eventos',
        'valor': '$_eventosProximos próximos',
        'color': Colors.teal,
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
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Título de sección
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: guinda.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: guinda,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Mi Región Hoy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Accede a toda la información de tu comunidad',
            style: TextStyle(fontSize: 14, color: subtextColor),
          ),
          const SizedBox(height: 24),
          // Grid de módulos responsivo
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final spacing = screenWidth > 600 ? 16.0 : 12.0;

              // Calcular columnas según el ancho disponible
              int columns;
              if (screenWidth > 900) {
                columns = 4;
              } else if (screenWidth > 650) {
                columns = 3;
              } else if (screenWidth > 400) {
                columns = 3;
              } else {
                columns = 2;
              }

              final cardWidth =
                  (screenWidth - (spacing * (columns - 1))) / columns;
              // Altura más compacta para cards cuadradas
              final cardHeight = cardWidth < 130
                  ? cardWidth * 1.15
                  : cardWidth < 180
                  ? cardWidth * 1.0
                  : cardWidth * 0.9;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: modulos.map((modulo) {
                  return SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildModuloCardResponsive(
                      emoji: modulo['emoji'] as String,
                      titulo: modulo['titulo'] as String,
                      valor: modulo['valor'] as String,
                      descripcion: modulo['descripcion'] as String,
                      color: modulo['color'] as Color,
                      onTap: modulo['onTap'] as VoidCallback,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      cardWidth: cardWidth,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          // Pregunta del Día
          _buildPreguntaDelDia(isDark, cardColor, textColor, subtextColor),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildModuloCardResponsive({
    required String emoji,
    required String titulo,
    required String valor,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required double cardWidth,
  }) {
    // Tamaños responsivos según el ancho de la card
    final isCompact = cardWidth < 160;
    final isSmall = cardWidth < 200;

    final emojiSize = isCompact
        ? 22.0
        : isSmall
        ? 26.0
        : 28.0;
    final emojiPadding = isCompact ? 8.0 : 10.0;
    final titleSize = isCompact
        ? 14.0
        : isSmall
        ? 15.0
        : 17.0;
    final descSize = isCompact
        ? 10.0
        : isSmall
        ? 11.0
        : 12.0;
    final badgeSize = isCompact
        ? 9.0
        : isSmall
        ? 10.0
        : 11.0;
    final cardPadding = isCompact
        ? 12.0
        : isSmall
        ? 14.0
        : 16.0;
    final borderRadius = isCompact ? 16.0 : 20.0;
    final buttonPaddingH = isCompact ? 8.0 : 12.0;
    final buttonPaddingV = isCompact ? 6.0 : 8.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Emoji + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(emojiPadding),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 6 : 10,
                        vertical: isCompact ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(isDark ? 40 : 20),
                        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                      ),
                      child: Text(
                        valor,
                        style: TextStyle(
                          fontSize: badgeSize,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Título
              Text(
                titulo,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isCompact ? 2 : 4),
              // Descripción
              if (!isCompact)
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: descSize,
                    color: subtextColor,
                    height: 1.3,
                  ),
                  maxLines: isSmall ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: isCompact ? 6 : 10),
              // Botón Ver más
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPaddingH,
                  vertical: buttonPaddingV,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(isDark ? 40 : 15),
                  borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCompact ? 'Ver' : 'Ver más',
                      style: TextStyle(
                        fontSize: isCompact ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(width: isCompact ? 2 : 4),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [guinda.withAlpha(51), guinda.withAlpha(26)]
              : [guinda.withAlpha(20), guinda.withAlpha(8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: guinda.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: dorado.withAlpha(51),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: dorado,
                  size: 28,
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
          // Pregunta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(10) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: guinda.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💬', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _preguntaActual,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Campo de respuesta
          if (!_respuestaEnviada) ...[
            TextField(
              controller: _respuestaController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe tu respuesta aquí...',
                hintStyle: TextStyle(color: subtextColor.withAlpha(150)),
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(10) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: guinda.withAlpha(50)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: guinda.withAlpha(50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: guinda, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(color: textColor, fontSize: 15),
            ),
            const SizedBox(height: 16),
            // Botón de enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_respuestaController.text.trim().isNotEmpty) {
                    setState(() {
                      _respuestaEnviada = true;
                    });
                    // Solo de ejemplo, no envía nada
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
        // Título de sección
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: guinda.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: guinda,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Mi Región Hoy',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Accede a toda la información de tu comunidad',
          style: TextStyle(fontSize: 15, color: subtextColor),
        ),
        const SizedBox(height: 24),
        // Grid de módulos responsivo para web - usar GridView para mejor distribución
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final spacing = 16.0;

            // Más columnas en pantallas anchas
            int columns;
            if (screenWidth > 700) {
              columns = 3;
            } else if (screenWidth > 450) {
              columns = 2;
            } else {
              columns = 2;
            }

            final cardWidth =
                (screenWidth - (spacing * (columns - 1))) / columns;
            // Cards más cuadradas y compactas
            final cardHeight = cardWidth < 180
                ? cardWidth * 0.95
                : cardWidth * 0.85;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: modulos.map((modulo) {
                return SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildModuloCardResponsive(
                    emoji: modulo['emoji'] as String,
                    titulo: modulo['titulo'] as String,
                    valor: modulo['valor'] as String,
                    descripcion: modulo['descripcion'] as String,
                    color: modulo['color'] as Color,
                    onTap: modulo['onTap'] as VoidCallback,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    cardWidth: cardWidth,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
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

  // ════════════════════════════════════════════════════════════════════════════
  // DIÁLOGOS Y MODALES AUXILIARES
  // ════════════════════════════════════════════════════════════════════════════

  // Datos de municipios por estado
  static const Map<String, List<String>> _municipiosPorEstado = {
    'Aguascalientes': [
      'Aguascalientes',
      'Jesús María',
      'Calvillo',
      'Rincón de Romos',
      'Pabellon de Arteaga',
    ],
    'Baja California': [
      'Tijuana',
      'Mexicali',
      'Ensenada',
      'Tecate',
      'Rosarito',
    ],
    'Baja California Sur': [
      'La Paz',
      'Los Cabos',
      'Comondú',
      'Loreto',
      'Mulegé',
    ],
    'Campeche': ['Campeche', 'Carmen', 'Champotón', 'Calakmul', 'Hopelchén'],
    'Chiapas': [
      'Tuxtla Gutiérrez',
      'San Cristóbal de las Casas',
      'Tapachula',
      'Comitán',
      'Palenque',
    ],
    'Chihuahua': ['Chihuahua', 'Juárez', 'Cuauhtémoc', 'Delicias', 'Parral'],
    'Ciudad de México': [
      'Cuauhtémoc',
      'Miguel Hidalgo',
      'Benito Juárez',
      'Coyoacán',
      'Tlalpan',
      'Iztapalapa',
      'Gustavo A. Madero',
      'Azcapotzalco',
    ],
    'Coahuila': ['Saltillo', 'Torreón', 'Monclova', 'Piedras Negras', 'Acuna'],
    'Colima': [
      'Colima',
      'Manzanillo',
      'Tecomán',
      'Villa de Álvarez',
      'Armería',
    ],
    'Durango': [
      'Durango',
      'Gómez Palacio',
      'Lerdo',
      'Santiago Papasquiaro',
      'Canatlán',
    ],
    'Estado de México': [
      'Toluca',
      'Ecatepec',
      'Naucalpan',
      'Nezahualcóyotl',
      'Tlalnepantla',
      'Cuautitlán Izcalli',
      'Metepec',
    ],
    'Guanajuato': [
      'León',
      'Irapuato',
      'Celaya',
      'Salamanca',
      'Guanajuato',
      'Silao',
      'San Miguel de Allende',
    ],
    'Guerrero': ['Acapulco', 'Chilpancingo', 'Iguala', 'Zihuatanejo', 'Taxco'],
    'Hidalgo': ['Pachuca', 'Tulancingo', 'Tula', 'Tepeji', 'Tizayuca'],
    'Jalisco': [
      'Guadalajara',
      'Zapopan',
      'Tlaquepaque',
      'Tonalá',
      'Puerto Vallarta',
      'Tlajomulco',
    ],
    'Michoacán': [
      'Morelia',
      'Uruapan',
      'Lázaro Cárdenas',
      'Zamora',
      'Pátzcuaro',
    ],
    'Morelos': ['Cuernavaca', 'Jiutepec', 'Cuautla', 'Temixco', 'Yautepec'],
    'Nayarit': [
      'Tepic',
      'Bahía de Banderas',
      'Compostela',
      'San Blas',
      'Tuxpan',
    ],
    'Nuevo León': [
      'Monterrey',
      'San Pedro Garza García',
      'San Nicolás',
      'Guadalupe',
      'Apodaca',
      'Santa Catarina',
    ],
    'Oaxaca': [
      'Oaxaca de Juárez',
      'Salina Cruz',
      'Juchitán',
      'Tuxtepec',
      'Huatulco',
    ],
    'Puebla': [
      'Puebla',
      'Tehuacán',
      'San Martín Texmelucan',
      'Atlixco',
      'Cholula',
    ],
    'Querétaro': [
      'Querétaro',
      'San Juan del Río',
      'El Marqués',
      'Corregidora',
      'Tequisquiapan',
    ],
    'Quintana Roo': [
      'Cancún',
      'Playa del Carmen',
      'Chetumal',
      'Cozumel',
      'Tulum',
    ],
    'San Luis Potosí': [
      'San Luis Potosí',
      'Ciudad Valles',
      'Soledad de Graciano Sánchez',
      'Matehuala',
      'Ríoverde',
    ],
    'Sinaloa': ['Culiacán', 'Mazatlán', 'Los Mochis', 'Guasave', 'Guamúchil'],
    'Sonora': [
      'Hermosillo',
      'Ciudad Obregón',
      'Nogales',
      'San Luis Río Colorado',
      'Guaymas',
      'Puerto Peñasco',
      'Navojoa',
    ],
    'Tabasco': ['Villahermosa', 'Cárdenas', 'Comalcalco', 'Macuspana', 'Teapa'],
    'Tamaulipas': [
      'Reynosa',
      'Matamoros',
      'Nuevo Laredo',
      'Tampico',
      'Ciudad Victoria',
      'Altamira',
    ],
    'Tlaxcala': [
      'Tlaxcala',
      'Apizaco',
      'Huamantla',
      'Chiautempan',
      'Calpulalpan',
    ],
    'Veracruz': [
      'Veracruz',
      'Xalapa',
      'Coatzacoalcos',
      'Poza Rica',
      'Córdoba',
      'Boca del Río',
    ],
    'Yucatán': ['Mérida', 'Valladolid', 'Tizimín', 'Progreso', 'Kanasín'],
    'Zacatecas': ['Zacatecas', 'Fresnillo', 'Guadalupe', 'Jerez', 'Río Grande'],
  };

  void _mostrarSelectorUbicacion(BuildContext context) {
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
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SelectorUbicacionDialog(
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subtextColor: subtextColor,
          isWide: isWide,
          screenSize: screenSize,
          estadoActual: _estadoUsuario,
          municipioActual: _municipioUsuario,
          municipiosPorEstado: _municipiosPorEstado,
          onUbicacionSeleccionada: (estado, municipio) {
            setState(() {
              _estadoUsuario = estado;
              _municipioUsuario = municipio;
              // Actualizar descripción según el municipio
              _descripcionMunicipio = _getDescripcionMunicipio(
                municipio,
                estado,
              );
            });
          },
        );
      },
    );
  }

  String _getDescripcionMunicipio(String municipio, String estado) {
    // Descripciones personalizadas para algunos municipios importantes
    final descripciones = {
      'Puerto Peñasco':
          'Destino turístico del noroeste mexicano, conocido por sus playas y desarrollo industrial sostenible.',
      'Monterrey':
          'Centro industrial y financiero del norte de México, con gran actividad económica.',
      'Guadalajara':
          'Capital tecnológica de México, centro cultural e industrial del occidente.',
      'Cancún':
          'Principal destino turístico internacional de México en el Caribe.',
      'Tijuana':
          'Ciudad fronteriza con gran actividad maquiladora y comercial.',
      'Querétaro': 'Polo de desarrollo industrial y aeroespacial en el Bajío.',
      'León': 'Capital del calzado y la manufactura de cuero en México.',
      'Puebla': 'Centro industrial automotriz y ciudad histórica.',
      'Mérida': 'Ciudad blanca, centro cultural y económico del sureste.',
    };
    return descripciones[municipio] ??
        'Municipio de $estado con oportunidades de desarrollo en la región.';
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
