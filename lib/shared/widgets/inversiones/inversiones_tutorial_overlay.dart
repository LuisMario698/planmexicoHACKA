import 'package:flutter/material.dart';
import '../../../service/tts_service.dart';

class InversionesTutorialOverlay extends StatefulWidget {
  final Rect targetRect; // Coordenadas de la tarjeta a resaltar
  final VoidCallback onTargetTap; // Qué pasa cuando tocan la tarjeta
  final VoidCallback onSkip; // Botón saltar

  const InversionesTutorialOverlay({
    super.key,
    required this.targetRect,
    required this.onTargetTap,
    required this.onSkip,
  });

  @override
  State<InversionesTutorialOverlay> createState() =>
      _InversionesTutorialOverlayState();
}

class _InversionesTutorialOverlayState
    extends State<InversionesTutorialOverlay> {
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
      "¡Mira estas Oportunidades! Toca esta tarjeta para ver los detalles del proyecto. ¡Es el primer paso para invertir!",
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos si hay espacio arriba o abajo para poner a TecJolotito
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - widget.targetRect.bottom;
    final showBelow =
        spaceBelow > 300; // Preferimos mostrar abajo si hay espacio

    return Stack(
      children: [
        // 1. El Pintor que oscurece todo MENOS el rectángulo objetivo
        Positioned.fill(
          child: CustomPaint(
            painter: _HolePainter(targetRect: widget.targetRect),
          ),
        ),

        // 2. Detector de toques "Falso" (Bloquea todo excepto el hueco)
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Absorbe clics fuera del objetivo
            behavior: HitTestBehavior.opaque,
            // Importante: Dejamos pasar los toques SOLO en el área del hueco
            child: Stack(
              children: [
                // Área interactiva transparente sobre la tarjeta
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

        // 3. TecJolotito y Texto
        Positioned(
          top: showBelow ? widget.targetRect.bottom + 20 : null,
          bottom: showBelow
              ? null
              : (screenHeight - widget.targetRect.top) + 20,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showBelow) ...[
                _buildMessageCard(),
                const SizedBox(height: 10),
              ],

              // TecJolotito
              Image.asset(
                'assets/images/ajolote.gif',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),

              if (showBelow) ...[
                const SizedBox(height: 10),
                _buildMessageCard(),
              ],
            ],
          ),
        ),

        // 4. Botón Saltar (Esquina superior derecha)
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
            "¡Mira estas Oportunidades!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Toca esta tarjeta para ver los detalles del proyecto. ¡Es el primer paso para invertir!",
            style: TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Pintor para hacer el efecto "Recorte" (Hole Punch)
class _HolePainter extends CustomPainter {
  final Rect targetRect;

  _HolePainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8);

    // Crea un path que cubre toda la pantalla
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Crea un path para el hueco (con bordes redondeados)
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(4), // Un poquito más grande que la tarjeta
          const Radius.circular(12),
        ),
      );

    // Combina los paths: Fondo MENOS Hueco
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
