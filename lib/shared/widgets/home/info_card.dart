import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Card de información reutilizable (Misión, Visión, etc.)
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección que muestra las cards de Misión y Visión
class InfoCardsSection extends StatelessWidget {
  const InfoCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    if (isDesktop) {
      return const Row(
        children: [
          Expanded(
            child: InfoCard(
              icon: Icons.rocket_launch_rounded,
              title: 'Misión',
              description:
                  'Impulsar el desarrollo económico sostenible de México mediante la creación de Polos de Bienestar.',
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: InfoCard(
              icon: Icons.visibility_rounded,
              title: 'Visión',
              description:
                  'Un México próspero, equitativo y sustentable para todas y todos los mexicanos.',
              color: AppTheme.accentColor,
            ),
          ),
        ],
      );
    }

    return const Column(
      children: [
        InfoCard(
          icon: Icons.rocket_launch_rounded,
          title: 'Misión',
          description:
              'Impulsar el desarrollo económico sostenible de México mediante la creación de Polos de Bienestar.',
          color: AppTheme.primaryColor,
        ),
        SizedBox(height: 12),
        InfoCard(
          icon: Icons.visibility_rounded,
          title: 'Visión',
          description:
              'Un México próspero, equitativo y sustentable para todas y todos los mexicanos.',
          color: AppTheme.accentColor,
        ),
      ],
    );
  }
}
