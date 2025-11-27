import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

// Tutorial de múltiples pasos para cuando seleccionas un polo
// step 1: Información general del polo
// step 2: Información y sectores clave
// step 3: Botón Explorar (ubicación)
// step 4: Botón Opinar (feedback)

class PoloTutorialOverlay extends StatefulWidget {
  final int step; // 1: Info general, 2: Sectores, 3: Explorar, 4: Opinar
  final Rect? targetRect; // Se mantiene por compatibilidad pero no se usa
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onTargetTap;

  const PoloTutorialOverlay({
    super.key,
    required this.step,
    this.targetRect,
    required this.onNext,
    required this.onSkip,
    this.onTargetTap,
  });

  @override
  State<PoloTutorialOverlay> createState() => _PoloTutorialOverlayState();
}

class _PoloTutorialOverlayState extends State<PoloTutorialOverlay>
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
  void didUpdateWidget(covariant PoloTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _animController.forward(from: 0);
      _speak();
    }
  }

  @override
  void dispose() {
    _tts.stopImmediately();
    _animController.dispose();
    super.dispose();
  }

  void _speak() {
    String message = '${_getTitle()}. ${_getDescription()}';
    _tts.speak(message);
  }

  void _handleSkip() {
    _tts.stopImmediately();
    widget.onSkip();
  }

  void _handleNext() {
    _tts.stop();
    widget.onNext();
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
              constraints: BoxConstraints(maxWidth: isDesktop ? 520 : 400),
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
                    width: isDesktop ? 130 : 100,
                    height: isDesktop ? 130 : 100,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                  SizedBox(height: isDesktop ? 20 : 16),

                  // Título
                  Text(
                    _getTitle(),
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
                    _getDescription(),
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 24 : 18),

                  // Barra de progreso del tutorial
                  Row(
                    children: [
                      _buildProgressBar(1),
                      const SizedBox(width: 4),
                      _buildProgressBar(2),
                      const SizedBox(width: 4),
                      _buildProgressBar(3),
                      const SizedBox(width: 4),
                      _buildProgressBar(4),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 20 : 16),

                  // Botón Siguiente
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
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
                        widget.step == 4 ? '¡Perfecto!' : 'Siguiente',
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

  Widget _buildProgressBar(int stepNumber) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: widget.step >= stepNumber
              ? const Color(0xFF691C32)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.step) {
      case 1:
        return '¡Información del Polo!';
      case 2:
        return '🏭 Sectores Clave';
      case 3:
        return '📍 Botón Explorar';
      case 4:
        return '💬 Botón Opinar';
      default:
        return 'Tutorial';
    }
  }

  String _getDescription() {
    switch (widget.step) {
      case 1:
        return 'Has seleccionado un polo de desarrollo. Aquí verás toda su información: nombre, estado, tipo de proyecto y descripción. ¡Desplázate para explorar más!';
      case 2:
        return 'Los sectores clave son las industrias principales de este polo. Estos sectores impulsarán el crecimiento económico y la generación de empleos en la región.';
      case 3:
        return 'Toca "Explorar" para ver la ubicación exacta del polo en el mapa. Así podrás identificar su localización geográfica precisa.';
      case 4:
        return 'Usa "Opinar" para compartir tu feedback, sugerencias o experiencias sobre este polo. ¡Tu opinión nos ayuda a mejorar!';
      default:
        return '';
    }
  }
}
