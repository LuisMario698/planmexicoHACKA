import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

class StateTutorialOverlay extends StatefulWidget {
  final Rect targetRect; // Se mantiene por compatibilidad pero no se usa
  final VoidCallback onTargetTap; // Acción al continuar
  final VoidCallback onSkip; // Botón omitir

  const StateTutorialOverlay({
    super.key,
    required this.targetRect,
    required this.onTargetTap,
    required this.onSkip,
  });

  @override
  State<StateTutorialOverlay> createState() => _StateTutorialOverlayState();
}

class _StateTutorialOverlayState extends State<StateTutorialOverlay>
    with SingleTickerProviderStateMixin {
  final TtsService _tts = TtsService();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
    _speak();
  }

  @override
  void dispose() {
    _tts.stopImmediately();
    _animController.dispose();
    super.dispose();
  }

  void _speak() {
    _tts.speak(
      "¡Conoce más del Estado! Aquí encontrarás información detallada sobre los polos de desarrollo, sectores estratégicos y proyectos federales.",
    );
  }

  void _handleSkip() {
    _tts.stopImmediately();
    widget.onSkip();
  }

  void _handleContinue() {
    _tts.stopImmediately();
    widget.onTargetTap();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 768;

    return Stack(
      children: [
        // Fondo oscuro uniforme
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Bloquea toques
            child: Container(
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ),

        // Contenido centrado
        Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 24),
              constraints: BoxConstraints(maxWidth: isDesktop ? 500 : 380),
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3E7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón cerrar
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _handleSkip,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: isDesktop ? 22 : 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),

                  // Ajolote
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: isDesktop ? 140 : 110,
                    height: isDesktop ? 140 : 110,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                  SizedBox(height: isDesktop ? 20 : 16),

                  // Título
                  Text(
                    "¡Conoce más del Estado!",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF691C32), // guinda
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),

                  // Descripción
                  Text(
                    "Aquí encontrarás información detallada sobre los polos de desarrollo, sectores estratégicos y proyectos federales.",
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 28 : 20),

                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF691C32), // guinda
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Continuar",
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
