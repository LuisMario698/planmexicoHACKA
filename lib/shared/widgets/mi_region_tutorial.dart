import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

/// Tutorial interactivo para la pantalla de Mi Región
class MiRegionTutorialOverlay extends StatefulWidget {
  final int step;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const MiRegionTutorialOverlay({
    super.key,
    required this.step,
    this.onNext,
    this.onSkip,
  });

  @override
  State<MiRegionTutorialOverlay> createState() =>
      _MiRegionTutorialOverlayState();
}

class _MiRegionTutorialOverlayState extends State<MiRegionTutorialOverlay> {
  @override
  void initState() {
    super.initState();
    _speak();
  }

  @override
  void didUpdateWidget(covariant MiRegionTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _speak();
    }
  }

  @override
  void dispose() {
    TtsService().stop();
    super.dispose();
  }

  void _speak() {
    String message = '';
    switch (widget.step) {
      case 1:
        message =
            '¡Bienvenido a Mi Región! Aquí encontrarás información personalizada sobre tu localidad, diseñada para mantenerte conectado con el desarrollo de tu comunidad.';
        break;
      case 2:
        message =
            'Indicadores Clave. Consulta estadísticas importantes como nuevos empleos, cursos de capacitación disponibles y el avance de obras en tu zona.';
        break;
      case 3:
        message =
            'Tu Opinión Cuenta. Participa respondiendo la "Pregunta del día". Tu retroalimentación es vital para priorizar las necesidades de tu municipio.';
        break;
      default:
        message = 'Explora todas las funcionalidades disponibles.';
    }
    TtsService().speak(message);
  }

  @override
  Widget build(BuildContext context) {
    // Tutorial general centrado (sin resaltar elementos específicos)
    return Stack(
      children: [
        // Fondo oscuro
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),

        // Contenido centrado
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ajolote animado
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.smart_toy,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tarjeta de mensaje
                  _buildMessageCard(context),

                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: widget.onSkip,
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
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF691C32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.step < 3 ? 'Siguiente' : 'Entendido',
                            style: const TextStyle(
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
        ),

        // Botón cerrar superior
        Positioned(
          top: 40,
          right: 20,
          child: SafeArea(
            child: IconButton(
              onPressed: widget.onSkip,
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    String title = '';
    String message = '';

    switch (widget.step) {
      case 1:
        title = '¡Bienvenido a Mi Región!';
        message =
            'Aquí encontrarás información personalizada sobre tu localidad, diseñada para mantenerte conectado con el desarrollo de tu comunidad.';
        break;
      case 2:
        title = 'Indicadores Clave';
        message =
            'Consulta estadísticas importantes como nuevos empleos, cursos de capacitación disponibles y el avance de obras en tu zona.';
        break;
      case 3:
        title = 'Tu Opinión Cuenta';
        message =
            'Participa respondiendo la "Pregunta del día". Tu retroalimentación es vital para priorizar las necesidades de tu municipio.';
        break;
      default:
        title = 'Información';
        message = 'Explora todas las funcionalidades disponibles.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF691C32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBC955C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Paso ${widget.step} de 3',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C6E36),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
