import 'package:flutter/material.dart';

// Tutorial de múltiples pasos para cuando seleccionas un polo
// step 1: Información general del polo
// step 2: Información y sectores clave
// step 3: Botón Explorar (ubicación)
// step 4: Botón Opinar (feedback)

class PoloTutorialOverlay extends StatelessWidget {
  final int step; // 1: Info general, 2: Sectores, 3: Explorar, 4: Opinar
  final Rect? targetRect; // Puede ser null si es tutorial general
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Si no hay targetRect, mostrar tutorial general (paso 1)
    if (targetRect == null || step == 1) {
      return _buildGeneralTutorial(context);
    }

    // Para otros pasos, mostrar el overlay con el target resaltado
    // Forzar mostrar arriba para el paso 2 (sectores) para evitar tapar el botón siguiente
    final bool showAbove = step == 2
        ? true
        : (screenHeight - targetRect!.bottom) < 250;

    return Stack(
      children: [
        // 1. Pintor que oscurece todo MENOS el rectángulo del target
        Positioned.fill(
          child: CustomPaint(painter: _HolePainter(targetRect: targetRect!)),
        ),

        // 2. Detector de toques "Bloqueante"
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Absorbe clics fuera del objetivo
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Área interactiva transparente sobre el target
                Positioned.fromRect(
                  rect: targetRect!,
                  child: GestureDetector(
                    onTap: onTargetTap ?? () {},
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. TecJolotito y Mensaje
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

              // TecJolotito
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

  // Tutorial general cuando no hay target (paso 1)
  Widget _buildGeneralTutorial(BuildContext context) {
    return Stack(
      children: [
        // Fondo oscuro
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Absorbe clics
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
        ),

        // Mensaje central
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TecJolotito
              Image.asset(
                'assets/images/ajolote.gif',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
              const SizedBox(height: 20),
              _buildMessageCard(context),
            ],
          ),
        ),

        // Botón Saltar
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

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 420),
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
            _getTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getDescription(),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 12),

          // Botón Siguiente
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF691C32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                step == 4 ? '¡Perfecto!' : 'Siguiente',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int stepNumber) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: step >= stepNumber
              ? const Color(0xFF691C32)
              : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (step) {
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
    switch (step) {
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

    // Hueco (Target)
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
