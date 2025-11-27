import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

class AjoloteTutorial extends StatefulWidget {
  final List<String> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const AjoloteTutorial({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<AjoloteTutorial> createState() => _AjoloteTutorialState();
}

class _AjoloteTutorialState extends State<AjoloteTutorial>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TtsService _tts = TtsService();

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
    _speakCurrentStep();
  }

  @override
  void dispose() {
    _tts.stopImmediately(); // Usar el nuevo método para detener inmediatamente
    _controller.dispose();
    super.dispose();
  }

  void _speakCurrentStep() {
    if (_currentIndex < widget.steps.length) {
      _tts.speak(widget.steps[_currentIndex]);
    }
  }

  void _nextStep() async {
    await _tts.stopImmediately(); // Detener audio inmediatamente
    if (_currentIndex < widget.steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakCurrentStep();
    } else {
      _finishTutorial();
    }
  }

  void _finishTutorial() async {
    await _tts.stopImmediately(); // Detener audio al cerrar
    await _controller.reverse();
    widget.onComplete();
  }

  void _skipTutorial() async {
    await _tts.stopImmediately(); // Detener audio al omitir
    await _controller.reverse();
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    // Tamaños adaptados para web
    final double cardWidth = isDesktop ? 500 : size.width * 0.85;
    final double cardHeight = isDesktop ? 480 : 460;
    final double gifSize = isDesktop ? 160 : 130;

    return Stack(
      children: [
        // 1. Fondo Oscuro
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
        ),

        // 2. Tarjeta del Tutorial
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: cardWidth,
              constraints: BoxConstraints(maxHeight: cardHeight),
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 32 : 24,
                16,
                isDesktop ? 32 : 24,
                isDesktop ? 28 : 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3E7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Botón Cerrar (Top Right) ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _skipTutorial,
                      icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                      tooltip: "Omitir tutorial",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  // --- TecJolotito CENTRADO ---
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: gifSize,
                    height: gifSize,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.smart_toy,
                      color: Colors.pink,
                      size: isDesktop ? 100 : 80,
                    ),
                  ),

                  SizedBox(height: isDesktop ? 20 : 16),

                  // --- Título y Pasos ---
                  Text(
                    "Guía de TecJolotito",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Paso ${_currentIndex + 1} de ${widget.steps.length}",
                    style: TextStyle(
                      fontSize: isDesktop ? 15 : 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // --- Texto del Paso ---
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 16 : 8,
                        ),
                        child: Text(
                          widget.steps[_currentIndex],
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            height: 1.5,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isDesktop ? 24 : 20),

                  // --- Botones y Puntos ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(widget.steps.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 28 : 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? const Color(0xFFE91E63)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),

                      // Botón Siguiente
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 36 : 32,
                            vertical: isDesktop ? 16 : 14,
                          ),
                        ),
                        child: Text(
                          _currentIndex == widget.steps.length - 1
                              ? "¡Vamos!"
                              : "Siguiente",
                          style: TextStyle(
                            fontSize: isDesktop ? 17 : 16,
                            fontWeight: FontWeight.bold,
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
      ],
    );
  }
}
