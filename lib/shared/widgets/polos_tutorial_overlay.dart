import 'package:flutter/material.dart';

class PolosTutorialOverlay extends StatelessWidget {
  final Rect targetRect; // Coordenadas del Mapa
  final VoidCallback onTargetTap; // Acción al tocar el mapa (desbloquear)
  final VoidCallback onSkip; // Botón omitir

  const PolosTutorialOverlay({
    super.key,
    required this.targetRect,
    required this.onTargetTap,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos espacio para poner a TecJolotito (preferiblemente abajo del mapa o en una esquina)
    final screenHeight = MediaQuery.of(context).size.height;
    // Si el mapa está muy abajo, ponemos el texto arriba, si no, abajo.
    final bool showBelow = (screenHeight - targetRect.bottom) > 200;

    return Stack(
      children: [
        // 1. Pintor que oscurece todo MENOS el rectángulo del mapa
        Positioned.fill(
          child: CustomPaint(painter: _HolePainter(targetRect: targetRect)),
        ),

        // 2. Detector de toques "Bloqueante"
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Absorbe clics fuera del objetivo
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Área interactiva transparente sobre el mapa
                Positioned.fromRect(
                  rect: targetRect,
                  child: GestureDetector(
                    onTap: onTargetTap,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. TecJolotito y Mensaje
        Positioned(
          top: showBelow ? targetRect.bottom + 10 : null,
          bottom: showBelow ? null : (screenHeight - targetRect.top) + 10,
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

        // 4. Botón Saltar
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: TextButton(
              onPressed: onSkip,
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
            "¡Explora los Polos de Desarrollo!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Este mapa interactivo te muestra las zonas estratégicas.\n\nToca el mapa para desbloquearlo y selecciona un estado.",
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

    // Hueco (Mapa)
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(4), // Un poquito más grande que el widget
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
