import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Separador con título de sección de inversiones
class InversionesSeparator extends StatelessWidget {
  final int totalProyectos;
  
  const InversionesSeparator({
    super.key,
    required this.totalProyectos,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08) 
                : const Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_center_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propuestas de Inversión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Oportunidades estratégicas del Plan México',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalProyectos proyectos',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
