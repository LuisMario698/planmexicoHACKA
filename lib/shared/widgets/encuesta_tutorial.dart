import 'package:flutter/material.dart';

/// Tutorial interactivo para la encuesta de opinión del polo
class EncuestaTutorialOverlay extends StatelessWidget {
  final int step;
  final Rect? targetRect;
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (step == 1) {
      return _buildGeneralTutorial(context);
    }

    final bool showAbove = (step == 2 || step == 3)
        ? true
        : (screenHeight - targetRect!.bottom) < 250;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _HolePainter(targetRect: targetRect!)),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned.fromRect(
                  rect: targetRect!,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: showAbove ? null : (targetRect!.bottom + 20),
          bottom: showAbove ? (screenHeight - targetRect!.top + 20) : null,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAbove) ...[
                _buildMessageCard(context),
                const SizedBox(height: 10),
              ],
              Image.asset(
                'assets/images/ajolote.gif',
                width: 105,
                height: 105,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
              if (!showAbove) ...[
                const SizedBox(height: 10),
                _buildMessageCard(context),
              ],
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Omitir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralTutorial(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ajolote.gif',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 20),
                _buildMessageCard(context),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Omitir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF691C32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Omitir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getTitleByStep(step),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF691C32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDescriptionByStep(step),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(step),
          const SizedBox(height: 12),
          if (step > 1)
            Row(
              children: [
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text('Omitir'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF691C32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    step == 4 ? '¡Perfecto!' : 'Siguiente',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int stepNumber) {
    return Row(
      children: List.generate(4, (index) {
        final step = index + 1;
        final isMarked = step <= stepNumber;
        final color = isMarked ? const Color(0xFF691C32) : Colors.grey.shade300;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.symmetric(horizontal: index < 3 ? 4 : 0),
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
        return 'Usa los sliders para calificar cada aspecto del 0 al 10. Esto nos ayuda a entender qué aspectos son más importantes.';
      case 3:
        return 'Si lo deseas, puedes dejar una sugerencia o comentario adicional. No es obligatorio, pero tu opinión detallada nos ayuda mucho.';
      case 4:
        return 'Una vez completado, presiona "Enviar encuesta" para compartir tu opinión. ¡Gracias por tu participación!';
      default:
        return '';
    }
  }
}

/// CustomPainter para crear el efecto de agujero
class _HolePainter extends CustomPainter {
  final Rect targetRect;

  _HolePainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(8),
          const Radius.circular(12),
        ),
      );

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(
      finalPath,
      Paint()
        ..color = Colors.black.withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect.inflate(8), const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFF691C32).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_HolePainter oldDelegate) =>
      targetRect != oldDelegate.targetRect;
}
