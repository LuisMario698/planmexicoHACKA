import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Sección "¿Qué es el Plan México?" - Estilo gobierno de México
class WhatIsPlanSection extends StatelessWidget {
  const WhatIsPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

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
                '¿Qué es el Plan México?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Contenido
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan ambicioso de desarrollo nacional y prosperidad compartida presentado por la Presidenta Claudia Sheinbaum el 13 de enero de 2025.',
                style: TextStyle(
                  fontSize: isDesktop ? 17 : 15,
                  color: isDark ? Colors.white.withValues(alpha: 0.87) : AppTheme.lightText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Es la estrategia insignia de desarrollo económico y regional a largo plazo, con metas establecidas hasta 2030.',
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 14,
                  color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                  height: 1.6,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats
              if (isDesktop)
                _buildDesktopStats(isDark)
              else
                _buildMobileStats(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStats(bool isDark) {
    return Row(
      children: [
        _buildStatItem('13', 'Metas clave', isDark),
        _buildDivider(isDark),
        _buildStatItem('18', 'Acciones', isDark),
        _buildDivider(isDark),
        _buildStatItem('2,000', 'Proyectos', isDark),
        _buildDivider(isDark),
        _buildStatItem('\$277B', 'USD Inversión', isDark),
      ],
    );
  }

  Widget _buildMobileStats(bool isDark) {
    return Wrap(
      spacing: 32,
      runSpacing: 20,
      children: [
        _buildStatItem('13', 'Metas', isDark),
        _buildStatItem('18', 'Acciones', isDark),
        _buildStatItem('2,000', 'Proyectos', isDark),
        _buildStatItem('\$277B', 'USD', isDark),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      color: isDark 
          ? Colors.white.withValues(alpha: 0.1) 
          : const Color(0xFFE0E0E0),
    );
  }

  Widget _buildStatItem(String number, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
