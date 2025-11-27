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
  final TtsService _tts = TtsService();

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
    _tts.stopImmediately();
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
        // Fondo oscuro
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.75))),

        // Contenido centrado
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 40 : 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 500 : 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ajolote animado
                  Image.asset(
                    'assets/images/ajolote.gif',
                    width: isDesktop ? 140 : 120,
                    height: isDesktop ? 140 : 120,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.smart_toy,
                        size: isDesktop ? 100 : 80,
                        color: Colors.white,
                      );
                    },
                  ),
                  SizedBox(height: isDesktop ? 24 : 20),

                  // Tarjeta de mensaje
                  _buildMessageCard(context, isDesktop),

                  SizedBox(height: isDesktop ? 24 : 20),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _handleSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 14 : 12,
                            ),
                          ),
                          child: Text(
                            'Omitir',
                            style: TextStyle(
                              fontSize: isDesktop ? 17 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF691C32),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 14 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            widget.step < 3 ? 'Siguiente' : 'Entendido',
                            style: TextStyle(
                              fontSize: isDesktop ? 17 : 16,
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
          right: isDesktop ? 40 : 20,
          child: SafeArea(
            child: IconButton(
              onPressed: _handleSkip,
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(BuildContext context, bool isDesktop) {
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
      padding: EdgeInsets.all(isDesktop ? 28 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF691C32),
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            message,
            style: TextStyle(
              fontSize: isDesktop ? 17 : 16,
              height: 1.5,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: widget.step == index + 1 ? 28 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.step == index + 1
                      ? const Color(0xFF691C32)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
