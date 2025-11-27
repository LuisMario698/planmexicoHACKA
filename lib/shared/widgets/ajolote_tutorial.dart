import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentIndex < widget.steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finish();
    }
  }

  void _finish() async {
    await _controller.reverse();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    final double cardWidth = isDesktop ? 450 : size.width * 0.85;
    // Aumenté un poco la altura base para acomodar el layout vertical
    final double cardHeight = isDesktop ? 450 : 480;

    return Stack(
      children: [
        // 1. Fondo Oscuro
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),

        // 2. Tarjeta del Tutorial
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3E7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
                      onPressed: _finish,
                      icon: const Icon(Icons.close, color: Colors.grey),
                      tooltip: "Omitir",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  // --- TecJolotito CENTRADO ---
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: 150, // Más grande para lucir el recorte
                    height: 150,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.smart_toy,
                      color: Colors.pink,
                      size: 100,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Título y Pasos (Debajo del GIF) ---
                  Text(
                    "Guía de TecJolotito",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Paso ${_currentIndex + 1} de ${widget.steps.length}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),
                  const Divider(),

                  // --- Texto del Paso ---
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.steps[_currentIndex],
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            height: 1.4,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                            width: _currentIndex == index ? 24 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? const Color(0xFFE91E63)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
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
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          _currentIndex == widget.steps.length - 1
                              ? "¡Vamos!"
                              : "Siguiente",
                          style: const TextStyle(
                            fontSize: 16,
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
