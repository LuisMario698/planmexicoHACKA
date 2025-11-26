import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Modelo de datos para un Polo de Bienestar
class PoloData {
  final String name;
  final IconData icon;
  final String states;

  const PoloData({
    required this.name,
    required this.icon,
    required this.states,
  });
}

/// Card individual de un Polo de Bienestar
class PoloCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String states;
  final int index;
  final VoidCallback? onTap;

  const PoloCard({
    super.key,
    required this.name,
    required this.icon,
    required this.states,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      const Color(0xFF2E7D32),
      const Color(0xFF1565C0),
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  states,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sección completa de Polos de Bienestar con scroll horizontal
class PolosSection extends StatelessWidget {
  final Function(PoloData polo)? onPoloTap;

  const PolosSection({super.key, this.onPoloTap});

  static const List<PoloData> polos = [
    PoloData(
      name: 'Polo Norte',
      icon: Icons.ac_unit_rounded,
      states: 'Sonora, Chihuahua, Coahuila',
    ),
    PoloData(
      name: 'Polo Centro',
      icon: Icons.location_city_rounded,
      states: 'CDMX, Estado de México',
    ),
    PoloData(
      name: 'Polo Sur',
      icon: Icons.wb_sunny_rounded,
      states: 'Oaxaca, Chiapas, Yucatán',
    ),
    PoloData(
      name: 'Polo Pacífico',
      icon: Icons.waves_rounded,
      states: 'Jalisco, Nayarit, Sinaloa',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        _buildSectionHeader(isDark),
        const SizedBox(height: 16),

        // Lista horizontal de polos
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: polos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final polo = polos[index];
              return PoloCard(
                name: polo.name,
                icon: polo.icon,
                states: polo.states,
                index: index,
                onTap: onPoloTap != null ? () => onPoloTap!(polo) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Polos de Bienestar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
        ),
      ],
    );
  }
}
