import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

/// Pantalla de bienvenida minimalista y elegante
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onStart;

  const WelcomeScreen({super.key, required this.onStart});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const Color guinda = Color(0xFF691C32);
  static const Color guindaOscuro = Color(0xFF3D0F1D);
  static const Color dorado = Color(0xFFBC955C);
  static const Color doradoClaro = Color(0xFFE8D5B5);

  late AnimationController _breatheController;
  late AnimationController _glowController;
  late AnimationController _entryController;
  late AnimationController _particleController;

  late Animation<double> _breatheAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _logoEntry;
  late Animation<double> _contentEntry;
  late Animation<double> _buttonEntry;
  late Animation<double> _screenFadeIn;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Respiración suave del logo
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Brillo pulsante
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Partículas
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Entrada secuencial
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Fade-in de toda la pantalla (desvanecido inverso)
    _screenFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoEntry = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _contentEntry = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonEntry = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _glowController.dispose();
    _entryController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: guindaOscuro,
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Opacity(
            opacity: _screenFadeIn.value.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // Fondo con gradiente
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF8B1538), // Guinda más claro arriba
                        guinda,
                        guindaOscuro,
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Ondas decorativas animadas
                _buildWaves(size),

                // Contenido principal centrado
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 48 : 24,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo centrado
                            _buildLogo(isWide),

                            SizedBox(height: isWide ? 48 : 36),

                            // Sección inferior con descripción y botón
                            _buildBottomSection(isWide),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaves(Size size) {
    // Tonos oscuros de guinda/vino para las ondas
    const Color ondaOscura1 = Color(0xFF4A1525); // Guinda muy oscuro
    const Color ondaOscura2 = Color(0xFF5C1A2D); // Guinda oscuro
    const Color ondaOscura3 = Color(0xFF3D1120); // Vino profundo
    const Color ondaOscura4 = Color(0xFF2E0D18); // Casi negro vino

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Onda superior sutil
            Positioned(
              top: size.height * 0.05,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 120),
                painter: _WavePainter(
                  color: ondaOscura1.withOpacity(0.4),
                  amplitude: 20,
                  frequency: 1.5,
                  phase: _particleController.value * 2 * math.pi,
                ),
              ),
            ),
            // Onda media superior
            Positioned(
              top: size.height * 0.12,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 100),
                painter: _WavePainter(
                  color: ondaOscura2.withOpacity(0.5),
                  amplitude: 25,
                  frequency: 1.2,
                  phase: _particleController.value * 2 * math.pi + 1,
                ),
              ),
            ),
            // Ondas inferiores (más visibles)
            Positioned(
              bottom: size.height * 0.18,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 150),
                painter: _WavePainter(
                  color: ondaOscura3.withOpacity(0.5),
                  amplitude: 30,
                  frequency: 1.0,
                  phase: -_particleController.value * 2 * math.pi,
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.10,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 120),
                painter: _WavePainter(
                  color: ondaOscura2.withOpacity(0.6),
                  amplitude: 35,
                  frequency: 0.8,
                  phase: -_particleController.value * 2 * math.pi + 0.5,
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.02,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(size.width, 100),
                painter: _WavePainter(
                  color: ondaOscura4.withOpacity(0.7),
                  amplitude: 25,
                  frequency: 1.3,
                  phase: -_particleController.value * 2 * math.pi + 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogo(bool isWide) {
    final logoSize = isWide ? 260.0 : 200.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _breatheController, _glowController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoEntry.value * _breatheAnimation.value,
          child: Opacity(
            opacity: _logoEntry.value.clamp(0.0, 1.0),
            child: Container(
              width: logoSize + 60,
              height: logoSize + 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Brillo dorado exterior
                  BoxShadow(
                    color: dorado.withOpacity(0.25 * _glowAnimation.value),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                  // Sombra profunda
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                      doradoClaro.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: dorado.withOpacity(0.4),
                    width: 3,
                  ),
                ),
                padding: const EdgeInsets.all(25),
                child: SvgPicture.asset(
                  'assets/images/logo_planMX_solo.svg',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => const CircularProgressIndicator(
                    color: guinda,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(bool isWide) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentEntry.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _contentEntry.value)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 32),
              child: Column(
                children: [
                  // Línea decorativa
                  Container(
                    width: 60,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          dorado.withOpacity(0),
                          dorado,
                          dorado.withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  Text(
                    'Descubre oportunidades de empleo,\ncursos y proyectos en tu región',
                    style: TextStyle(
                      fontSize: isWide ? 18 : 15,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isWide ? 40 : 32),

                  // Botón
                  _buildButton(isWide),

                  const SizedBox(height: 20),

                  // Versión
                  Text(
                    'v1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      letterSpacing: 2,
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

  Widget _buildButton(bool isWide) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonEntry.value,
          child: Opacity(
            opacity: _buttonEntry.value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: widget.onStart,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 60 : 48,
                        vertical: isWide ? 18 : 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            dorado,
                            Color(0xFFD4AA60),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: dorado.withOpacity(0.4 * _glowAnimation.value),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Comenzar',
                            style: TextStyle(
                              fontSize: isWide ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter para dibujar ondas suaves como en la imagen de referencia
class _WavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;

  _WavePainter({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          amplitude * math.sin((x / size.width * frequency * 2 * math.pi) + phase) +
          amplitude * 0.5 * math.sin((x / size.width * frequency * 4 * math.pi) + phase * 1.5);
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Segunda línea paralela más gruesa
    final paint2 = Paint()
      ..color = color.withOpacity(color.opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path2 = Path();
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + 20 +
          amplitude * 0.8 * math.sin((x / size.width * frequency * 2 * math.pi) + phase + 0.3);
      
      if (x == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    canvas.drawPath(path2, paint2);

    // Tercera línea para aún más profundidad
    final paint3 = Paint()
      ..color = color.withOpacity(color.opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path3 = Path();
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + 40 +
          amplitude * 0.6 * math.sin((x / size.width * frequency * 2 * math.pi) + phase + 0.6);
      
      if (x == 0) {
        path3.moveTo(x, y);
      } else {
        path3.lineTo(x, y);
      }
    }

    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
