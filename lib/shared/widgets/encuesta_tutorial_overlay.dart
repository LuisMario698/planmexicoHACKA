import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

/// Tutorial interactivo para la encuesta de opinión del polo
/// Guía al usuario a través de los elementos de la encuesta
class EncuestaTutorialOverlay extends StatefulWidget {
  final int step; // 1: Intro, 2: Preguntas, 3: Pregunta abierta, 4: Enviar
  final Rect? targetRect; // Se mantiene por compatibilidad pero no se usa
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const EncuestaTutorialOverlay({
    super.key,
    required this.step,
    this.targetRect,
    this.onNext,
    this.onSkip,
  });

  @override
  State<EncuestaTutorialOverlay> createState() =>
      _EncuestaTutorialOverlayState();
}

class _EncuestaTutorialOverlayState extends State<EncuestaTutorialOverlay>
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
  void didUpdateWidget(covariant EncuestaTutorialOverlay oldWidget) {
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
    String message =
        '${_getTitleByStep(widget.step)}. ${_getDescriptionByStep(widget.step)}';
    _tts.speak(message);
  }

  void _handleSkip() {
    _tts.stopImmediately();
    widget.onSkip?.call();
  }

  void _handleNext() {
    _tts.stop();
    widget.onNext?.call();
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
                    _getTitleByStep(widget.step),
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
                    _getDescriptionByStep(widget.step),
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isDesktop ? 24 : 18),

                  // Barra de progreso del tutorial
                  _buildProgressBar(widget.step),
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

  /// Barra de progreso (4 pasos)
  Widget _buildProgressBar(int stepNumber) {
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        final isMarked = step <= stepNumber;
        final color = isMarked ? const Color(0xFF691C32) : const Color(0xFFE5E7EB);
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  String _getTitleByStep(int step) {
    switch (step) {
      case 1:
        return '¡Tu opinión importa!';
      case 2:
        return '📊 Calificaciones';
      case 3:
        return '💭 Tu comentario';
      case 4:
        return '✅ Listo para enviar';
      default:
        return '';
    }
  }

  String _getDescriptionByStep(int step) {
    switch (step) {
      case 1:
        return 'Esta encuesta te ayuda a compartir tu opinión sobre los polos de desarrollo. Tu retroalimentación es valiosa para mejorar los proyectos.';
      case 2:
        return 'Usa los sliders para calificar cada aspecto del 0 (no está claro/bajo beneficio/no necesita mejoras) al 10 (muy claro/alto beneficio/necesita muchas mejoras).';
      case 3:
        return 'Si lo deseas, puedes dejar una sugerencia o comentario adicional en la pregunta abierta. No es obligatorio, pero tu opinión detallada nos ayuda mucho.';
      case 4:
        return 'Una vez completado, presiona el botón "Enviar encuesta" para compartir tu opinión. ¡Gracias por tu participación!';
      default:
        return '';
    }
  }
}
