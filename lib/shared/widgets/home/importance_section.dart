import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Sección "¿Por qué es importante?" - Estilo gobierno de México
class ImportanceSection extends StatelessWidget {
  const ImportanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    final razones = [
      {
        'icon': Icons.map_rounded,
        'title': 'Hoja de Ruta Nacional',
        'desc': 'Proporciona una visión a largo plazo y es la "carta de navegación" para la nueva era económica de México.',
      },
      {
        'icon': Icons.bolt_rounded,
        'title': 'Infraestructura Eléctrica Crítica',
        'desc': 'Inversiones por \$40.2 mil millones de dólares en el sector eléctrico para absorber el crecimiento de demanda proyectado.',
      },
      {
        'icon': Icons.warning_amber_rounded,
        'title': 'Prevención de Déficit Energético',
        'desc': 'Sin estas inversiones, México enfrentaría un déficit de más de 48,000 GWh hacia 2030.',
      },
      {
        'icon': Icons.handshake_rounded,
        'title': 'Inversión Privada',
        'desc': 'El éxito del plan depende de atraer inversión privada, lo que requiere certidumbre jurídica y reglas claras.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header estilo gobierno
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 26,
              ),
              const SizedBox(width: 8),
              const Text(
                '¿Por qué es importante?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Grid de razones
        if (isDesktop)
          _buildDesktopGrid(razones, isDark)
        else
          _buildMobileList(razones, isDark),
      ],
    );
  }

  Widget _buildDesktopGrid(List<Map<String, dynamic>> razones, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: razones.map((razon) => Expanded(
          child: _buildRazonCard(razon, isDark),
        )).toList(),
      ),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> razones, bool isDark) {
    return Column(
      children: razones.map((razon) => _buildRazonCard(razon, isDark)).toList(),
    );
  }

  Widget _buildRazonCard(Map<String, dynamic> razon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border.all(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.06) 
              : const Color(0xFFE0E0E0),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            razon['icon'] as IconData,
            color: AppTheme.primaryColor.withValues(alpha: 0.65),
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            razon['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.lightText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            razon['desc'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
