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
  final TtsService _tts = TtsService();

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
    _tts.stopImmediately();
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
                            widget.step < 2 ? 'Siguiente' : 'Entendido',
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
