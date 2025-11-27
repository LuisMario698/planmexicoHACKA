import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

class PolosTutorialOverlay extends StatefulWidget {
  final Rect targetRect;
  final VoidCallback onTargetTap;
  final VoidCallback onSkip;

  const PolosTutorialOverlay({
    super.key,
    required this.targetRect,
    required this.onTargetTap,
    required this.onSkip,
  });

  @override
  State<PolosTutorialOverlay> createState() => _PolosTutorialOverlayState();
}

class _PolosTutorialOverlayState extends State<PolosTutorialOverlay>
    with SingleTickerProviderStateMixin {
  final TtsService _tts = TtsService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
    _speak();
  }

  @override
  void dispose() {
    _tts.stopImmediately();
    _controller.dispose();
    super.dispose();
  }

  void _speak() {
    _tts.speak(
      "¡Explora los Polos de Desarrollo! Este mapa interactivo te muestra las zonas estratégicas. Toca Continuar para explorar.",
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
        // Fondo oscuro completo
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
        ),

        // Contenido centrado
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.all(isDesktop ? 40 : 20),
              constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 360),
              padding: EdgeInsets.all(isDesktop ? 32 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3E7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón cerrar
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _handleSkip,
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  // TecJolotito
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: isDesktop ? 140 : 120,
                    height: isDesktop ? 140 : 120,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),

                  SizedBox(height: isDesktop ? 20 : 16),

                  // Título
                  Text(
                    "¡Explora los Polos de Desarrollo!",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isDesktop ? 16 : 12),

                  // Descripción
                  Text(
                    "Este mapa interactivo te muestra las zonas estratégicas de México.\n\nSelecciona un estado para ver sus polos de desarrollo.",
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isDesktop ? 28 : 24),

                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF691C32),
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
                          fontSize: isDesktop ? 17 : 16,
                          fontWeight: FontWeight.bold,
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
