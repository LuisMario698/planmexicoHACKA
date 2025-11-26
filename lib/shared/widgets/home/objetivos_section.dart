import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Sección de Objetivos Centrales - Estilo gobierno de México
class ObjetivosSection extends StatelessWidget {
  const ObjetivosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    final objetivos = [
      {
        'icon': Icons.emoji_events_rounded,
        'title': 'Ubicar a México entre las 10 principales economías del mundo.',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Reducir la pobreza y la desigualdad.',
      },
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Elevar la inversión total a más del 25% del PIB en 2026 y 28% hacia 2030.',
      },
      {
        'icon': Icons.engineering_rounded,
        'title': 'Generar 1.5 millones de empleos adicionales en manufactura especializada.',
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'title': 'Promover nearshoring y sustitución de importaciones.',
      },
      {
        'icon': Icons.flag_rounded,
        'title': 'Elevar el contenido nacional y regional de las cadenas de valor.',
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
                'Objetivos Centrales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Grid de objetivos
        if (isDesktop)
          _buildDesktopGrid(objetivos, isDark)
        else
          _buildMobileList(objetivos, isDark),
      ],
    );
  }

  Widget _buildDesktopGrid(List<Map<String, dynamic>> objetivos, bool isDark) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildObjetivoCard(objetivos[0], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[1], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[2], isDark)),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildObjetivoCard(objetivos[3], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[4], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[5], isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> objetivos, bool isDark) {
    return Column(
      children: [
        // Fila 1 (2 items)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildObjetivoCard(objetivos[0], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[1], isDark)),
            ],
          ),
        ),
        // Fila 2 (2 items)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildObjetivoCard(objetivos[2], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[3], isDark)),
            ],
          ),
        ),
        // Fila 3 (2 items)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildObjetivoCard(objetivos[4], isDark)),
              Expanded(child: _buildObjetivoCard(objetivos[5], isDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObjetivoCard(Map<String, dynamic> objetivo, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            objetivo['icon'] as IconData,
            color: AppTheme.primaryColor.withValues(alpha: 0.65),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            objetivo['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withValues(alpha: 0.87) : AppTheme.lightText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
