import 'package:flutter/material.dart';
import '../../service/tts_service.dart';

/// Tutorial interactivo para los módulos (Empleos, Cursos, etc.)
class ModuleTutorialOverlay extends StatefulWidget {
  final String moduleName;
  final int step;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const ModuleTutorialOverlay({
    super.key,
    required this.moduleName,
    required this.step,
    this.onNext,
    this.onSkip,
  });

  @override
  State<ModuleTutorialOverlay> createState() => _ModuleTutorialOverlayState();
}

class _ModuleTutorialOverlayState extends State<ModuleTutorialOverlay> {
  @override
  void initState() {
    super.initState();
    _speak();
  }

  @override
  void didUpdateWidget(covariant ModuleTutorialOverlay oldWidget) {
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
    if (widget.step == 1) {
      message =
          'Explora ${widget.moduleName}. ${_getModuleDescription(widget.moduleName)}';
    } else {
      message =
          'Interactúa. Toca cualquier elemento de la lista para ver más detalles o realizar acciones relacionadas.';
    }
    TtsService().speak(message);
  }

  @override
  Widget build(BuildContext context) {
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
                            widget.step < 2 ? 'Siguiente' : 'Entendido',
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

    // Personalizar mensajes según el módulo
    if (widget.step == 1) {
      title = 'Explora ${widget.moduleName}';
      message = _getModuleDescription(widget.moduleName);
    } else {
      title = 'Interactúa';
      message =
          'Toca cualquier elemento de la lista para ver más detalles o realizar acciones relacionadas.';
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
                  'Paso ${widget.step} de 2',
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

  String _getModuleDescription(String module) {
    switch (module.toLowerCase()) {
      case 'empleos':
      case 'oportunidades laborales':
        return 'Aquí encontrarás vacantes disponibles en tu región. Filtra por sector y postúlate a las que te interesen.';
      case 'cursos':
      case 'cursos y talleres':
        return 'Descubre oportunidades de capacitación para mejorar tus habilidades y acceder a mejores empleos.';
      case 'obras':
      case 'avances de obras':
        return 'Mantente informado sobre el progreso de los proyectos de infraestructura que están transformando tu comunidad.';
      case 'noticias':
      case 'noticias locales':
        return 'Las últimas novedades y anuncios oficiales relevantes para tu municipio y estado.';
      case 'polos':
      case 'polos de desarrollo':
        return 'Conoce los Polos de Desarrollo cercanos y cómo impactarán positivamente en la economía local.';
      case 'eventos':
      case 'eventos próximos':
        return 'Consulta la agenda de ferias, conferencias y actividades comunitarias programadas.';
      default:
        return 'Explora la información detallada disponible en esta sección.';
    }
  }
}
