import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

class StateTutorialOverlay extends StatefulWidget {
  final Rect targetRect; // Coordenadas del panel de información del estado
  final VoidCallback onTargetTap; // Acción al tocar el panel
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

class _StateTutorialOverlayState extends State<StateTutorialOverlay> {
  @override
  void initState() {
    super.initState();
    _speak();
  }

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  void _speak() {
    TtsService().speak(
      "¡Conoce más del Estado! Aquí encontrarás información detallada sobre los polos de desarrollo, sectores estratégicos y proyectos federales. Toca para explorar.",
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos espacio para poner a TecJolotito
    final screenHeight = MediaQuery.of(context).size.height;

    // Si el panel está en la parte inferior, ponemos el mensaje arriba
    final bool showAbove = (screenHeight - widget.targetRect.bottom) < 200;

    return Stack(
      children: [
        // 1. Pintor que oscurece todo MENOS el rectángulo del panel
        Positioned.fill(
          child: CustomPaint(
            painter: _HolePainter(targetRect: widget.targetRect),
          ),
        ),

        // 2. Detector de toques "Bloqueante"
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Absorbe clics fuera del objetivo
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Área interactiva transparente sobre el panel
                Positioned.fromRect(
                  rect: widget.targetRect,
                  child: GestureDetector(
                    onTap: widget.onTargetTap,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. TecJolotito y Mensaje
        Positioned(
          top: showAbove ? null : (widget.targetRect.bottom + 20),
          bottom: showAbove
              ? (screenHeight - widget.targetRect.top + 20)
              : null,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAbove) ...[
                _buildMessageCard(),
                const SizedBox(height: 10),
              ],

              // TecJolotito
              Image.asset(
                'assets/images/ajolote.gif',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),

              if (!showAbove) ...[
                const SizedBox(height: 10),
                _buildMessageCard(),
              ],
            ],
          ),
        ),

        // 4. Botón Saltar
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: widget.onSkip,
              child: const Text(
                "Omitir",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "¡Conoce más del Estado!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Aquí encontrarás información detallada sobre los polos de desarrollo, sectores estratégicos y proyectos federales.\n\nToca para explorar.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Pintor para el efecto "Recorte"
class _HolePainter extends CustomPainter {
  final Rect targetRect;

  _HolePainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8);

    // Fondo completo
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Hueco (Panel)
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(4),
          const Radius.circular(12),
        ),
      );

    // Resta: Fondo - Hueco
    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
