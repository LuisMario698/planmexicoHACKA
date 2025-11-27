import 'package:flutter/material.dart';

class EncuestasScreen extends StatefulWidget {
  const EncuestasScreen({super.key});

  @override
  State<EncuestasScreen> createState() => _EncuestasScreenState();
}

class _EncuestasScreenState extends State<EncuestasScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D1117), const Color(0xFF1E2029)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDark, isDesktop),
                const SizedBox(height: 24),

                // Contenido principal
                isDesktop
                    ? _buildDesktopContent(isDark)
                    : _buildMobileContent(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF691C32), Color(0xFF4A1525)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF691C32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.poll_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Encuestas',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu opinión es importante para mejorar México',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encuestas activas
        _buildSectionTitle('Encuestas Activas', Icons.how_to_vote_rounded, isDark),
        const SizedBox(height: 12),
        _buildEncuestaCard(
          isDark,
          titulo: '¿Qué polo de desarrollo te interesa más?',
          descripcion: 'Ayúdanos a priorizar los proyectos que más importan a la ciudadanía.',
          participantes: 1234,
          diasRestantes: 5,
          isActive: true,
        ),
        const SizedBox(height: 12),
        _buildEncuestaCard(
          isDark,
          titulo: 'Evaluación de servicios públicos',
          descripcion: 'Califica los servicios gubernamentales en tu región.',
          participantes: 856,
          diasRestantes: 12,
          isActive: true,
        ),
        const SizedBox(height: 24),

        // Encuestas completadas
        _buildSectionTitle('Completadas', Icons.check_circle_rounded, isDark),
        const SizedBox(height: 12),
        _buildEncuestaCard(
          isDark,
          titulo: 'Prioridades de inversión 2025',
          descripcion: 'Gracias por participar en esta encuesta.',
          participantes: 5621,
          diasRestantes: 0,
          isActive: false,
          completada: true,
        ),
        const SizedBox(height: 24),

        // Próximamente
        _buildSectionTitle('Próximamente', Icons.schedule_rounded, isDark),
        const SizedBox(height: 12),
        _buildProximamenteCard(isDark),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDesktopContent(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda - Encuestas activas
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Encuestas Activas', Icons.how_to_vote_rounded, isDark),
              const SizedBox(height: 12),
              _buildEncuestaCard(
                isDark,
                titulo: '¿Qué polo de desarrollo te interesa más?',
                descripcion: 'Ayúdanos a priorizar los proyectos que más importan a la ciudadanía.',
                participantes: 1234,
                diasRestantes: 5,
                isActive: true,
              ),
              const SizedBox(height: 12),
              _buildEncuestaCard(
                isDark,
                titulo: 'Evaluación de servicios públicos',
                descripcion: 'Califica los servicios gubernamentales en tu región.',
                participantes: 856,
                diasRestantes: 12,
                isActive: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Columna derecha - Completadas y próximamente
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Completadas', Icons.check_circle_rounded, isDark),
              const SizedBox(height: 12),
              _buildEncuestaCard(
                isDark,
                titulo: 'Prioridades de inversión 2025',
                descripcion: 'Gracias por participar.',
                participantes: 5621,
                diasRestantes: 0,
                isActive: false,
                completada: true,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Próximamente', Icons.schedule_rounded, isDark),
              const SizedBox(height: 12),
              _buildProximamenteCard(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF691C32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF691C32),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildEncuestaCard(
    bool isDark, {
    required String titulo,
    required String descripcion,
    required int participantes,
    required int diasRestantes,
    required bool isActive,
    bool completada = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              if (completada)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      const Text(
                        'Completada',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$diasRestantes días',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Footer
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                size: 16,
                color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 4),
              Text(
                '$participantes participantes',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                ),
              ),
              const Spacer(),
              if (isActive && !completada)
                GestureDetector(
                  onTap: () => _showEncuestaDialog(titulo),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Participar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (completada)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262830) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ver resultados',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProximamenteCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1E2029).withOpacity(0.5) 
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 40,
            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            'Nuevas encuestas en camino',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Te notificaremos cuando estén disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  void _showEncuestaDialog(String titulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: $titulo'),
        backgroundColor: const Color(0xFF691C32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
