import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../service/encuesta_service.dart';

/// Pantalla de encuesta para un polo de desarrollo
/// Diseño formal estilo Gobierno de México
class EncuestaPoloScreen extends StatefulWidget {
  final int poloId;
  final String poloNombre;
  final String poloEstado;
  final String? poloDescripcion;
  final VoidCallback? onEncuestaEnviada;
  final bool isDialog; // Para saber si se muestra como diálogo

  const EncuestaPoloScreen({
    super.key,
    required this.poloId,
    required this.poloNombre,
    required this.poloEstado,
    this.poloDescripcion,
    this.onEncuestaEnviada,
    this.isDialog = false,
  });

  /// Muestra la encuesta de forma adaptativa:
  /// - En web: diálogo flotante
  /// - En móvil: pantalla completa
  static void show(
    BuildContext context, {
    required int poloId,
    required String poloNombre,
    required String poloEstado,
    String? poloDescripcion,
    VoidCallback? onEncuestaEnviada,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // En web con pantalla grande: diálogo flotante
    if (kIsWeb && !isMobile) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
            child: EncuestaPoloScreen(
              poloId: poloId,
              poloNombre: poloNombre,
              poloEstado: poloEstado,
              poloDescripcion: poloDescripcion,
              onEncuestaEnviada: onEncuestaEnviada,
              isDialog: true,
            ),
          ),
        ),
      );
    } else {
      // En móvil: pantalla completa
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EncuestaPoloScreen(
            poloId: poloId,
            poloNombre: poloNombre,
            poloEstado: poloEstado,
            poloDescripcion: poloDescripcion,
            onEncuestaEnviada: onEncuestaEnviada,
            isDialog: false,
          ),
        ),
      );
    }
  }

  @override
  State<EncuestaPoloScreen> createState() => _EncuestaPoloScreenState();
}

class _EncuestaPoloScreenState extends State<EncuestaPoloScreen> {
  // Colores oficiales del proyecto
  static const Color guinda = Color(0xFF691C32);
  static const Color dorado = Color(0xFFBC955C);
  static const Color verde = Color(0xFF006847);
  
  // Servicio
  final EncuestaService _encuestaService = EncuestaService();
  
  // Valores (0-10)
  int _pregunta1 = 5;
  int _pregunta2 = 5;
  int _pregunta3 = 5;
  final TextEditingController _pregunta4Controller = TextEditingController();
  
  // Estado
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _pregunta4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si es diálogo, usar un Container con ClipRRect
    if (widget.isDialog) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.grey.shade50,
          child: _submitted ? _buildSuccessViewDialog() : _buildSurveyViewDialog(),
        ),
      );
    }
    
    // Pantalla completa normal
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: guinda,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Encuesta de Opinión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _submitted ? _buildSuccessView() : _buildSurveyView(),
    );
  }

  // ============ VISTAS PARA DIÁLOGO ============
  
  Widget _buildSurveyViewDialog() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header del diálogo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: guinda,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tu opinión importa',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.poloNombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.poloEstado,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Contenido scrolleable
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: guinda.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: guinda, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Evalúa cada aspecto del 0 al 10',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Preguntas compactas
                _buildQuestionCompact(
                  number: 1,
                  question: '¿Qué tan clara es la información?',
                  value: _pregunta1,
                  onChanged: (v) => setState(() => _pregunta1 = v),
                ),
                
                const SizedBox(height: 16),
                
                _buildQuestionCompact(
                  number: 2,
                  question: '¿Qué tanto beneficio traerá a tu región?',
                  value: _pregunta2,
                  onChanged: (v) => setState(() => _pregunta2 = v),
                ),
                
                const SizedBox(height: 16),
                
                _buildQuestionCompact(
                  number: 3,
                  question: '¿Qué tanto necesita mejoras el proyecto?',
                  value: _pregunta3,
                  onChanged: (v) => setState(() => _pregunta3 = v),
                ),
                
                const SizedBox(height: 16),
                
                // Pregunta abierta compacta
                _buildOpenQuestionCompact(),
                
                const SizedBox(height: 24),
                
                // Botón de envío
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guinda,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Enviar encuesta',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCompact({
    required int number,
    required String question,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: guinda,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: guinda.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$value',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: guinda),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: guinda,
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: guinda,
            overlayColor: guinda.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v.round());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpenQuestionCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: guinda,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text('4', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '¿Alguna sugerencia?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              '(Opcional)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pregunta4Controller,
          maxLines: 2,
          maxLength: 300,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Escribe tu comentario...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: guinda, width: 1.5),
            ),
            counterStyle: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessViewDialog() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: verde.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: verde, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Gracias por tu opinión!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu respuesta ha sido registrada.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Resumen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreSummary('Claridad', _pregunta1),
                _buildScoreSummary('Beneficio', _pregunta2),
                _buildScoreSummary('Mejoras', _pregunta3),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                widget.onEncuestaEnviada?.call();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: guinda,
                side: BorderSide(color: guinda),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cerrar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ============ VISTAS PARA PANTALLA COMPLETA ============

  Widget _buildSurveyView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con información del polo
          Container(
            width: double.infinity,
            color: guinda,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.poloNombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.poloEstado,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Contenido del formulario
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: guinda,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Evalúa cada aspecto del 0 al 10, donde 0 es muy bajo y 10 es muy alto.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Pregunta 1
                _buildQuestion(
                  number: 1,
                  question: '¿Qué tan clara es la información del proyecto?',
                  value: _pregunta1,
                  onChanged: (v) => setState(() => _pregunta1 = v),
                ),
                
                const SizedBox(height: 20),
                
                // Pregunta 2
                _buildQuestion(
                  number: 2,
                  question: '¿Qué tanto beneficio traerá a tu región?',
                  value: _pregunta2,
                  onChanged: (v) => setState(() => _pregunta2 = v),
                ),
                
                const SizedBox(height: 20),
                
                // Pregunta 3
                _buildQuestion(
                  number: 3,
                  question: '¿Qué tanto necesita mejoras el proyecto?',
                  value: _pregunta3,
                  onChanged: (v) => setState(() => _pregunta3 = v),
                ),
                
                const SizedBox(height: 20),
                
                // Pregunta 4 - Abierta
                _buildOpenQuestion(),
                
                const SizedBox(height: 32),
                
                // Botón de envío
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSurvey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: guinda,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Enviar encuesta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Nota de privacidad
                Text(
                  'Tu opinión es anónima y será utilizada para mejorar los proyectos de desarrollo.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion({
    required int number,
    required String question,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: guinda,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Valor seleccionado
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: guinda.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: guinda,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: guinda,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: guinda,
              overlayColor: guinda.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v.round());
              },
            ),
          ),
          
          // Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 - Muy bajo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '10 - Muy alto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: guinda,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Tienes alguna sugerencia o comentario?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Opcional',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Campo de texto
          TextField(
            controller: _pregunta4Controller,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tu comentario aquí...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: guinda, width: 1.5),
              ),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de éxito
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: verde.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: verde,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              '¡Gracias por tu opinión!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Tu respuesta ha sido registrada y será de gran utilidad para mejorar el proyecto.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Resumen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Resumen de tu evaluación',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreSummary('Claridad', _pregunta1),
                      _buildScoreSummary('Beneficio', _pregunta2),
                      _buildScoreSummary('Mejoras', _pregunta3),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón volver
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  widget.onEncuestaEnviada?.call();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: guinda,
                  side: BorderSide(color: guinda),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Volver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary(String label, int score) {
    return Column(
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: guinda,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _submitSurvey() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);
    
    final success = await _encuestaService.enviarRespuesta(
      poloId: widget.poloId,
      poloNombre: widget.poloNombre,
      poloEstado: widget.poloEstado,
      pregunta1: _pregunta1,
      pregunta2: _pregunta2,
      pregunta3: _pregunta3,
      pregunta4: _pregunta4Controller.text.isNotEmpty 
          ? _pregunta4Controller.text 
          : null,
    );
    
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submitted = success;
      });
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al enviar. Inténtalo de nuevo.'),
            backgroundColor: guinda,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
