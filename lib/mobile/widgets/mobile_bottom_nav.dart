import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/responsive_scaffold.dart';

class MobileBottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MobileBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Separar el item de Inicio (index 0) de los demás
    final homeItem = items[0];
    final leftItems = items.sublist(1, 3);  // Asistente, Datos
    final rightItems = items.sublist(3);     // Polos, Encuestas

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Items izquierda (Asistente, Datos) - con Expanded para distribuir
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: leftItems.asMap().entries.map((entry) {
                    final actualIndex = entry.key + 1;
                    final item = entry.value;
                    final isSelected = actualIndex == selectedIndex;
                    return _buildNavItem(item, isSelected, () => onItemSelected(actualIndex));
                  }).toList(),
                ),
              ),
              
              // Botón central de Inicio (más grande y centrado)
              GestureDetector(
                onTap: () => onItemSelected(0),
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryDark.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: selectedIndex == 0
                              ? [Colors.white, Colors.white.withValues(alpha: 0.95)]
                              : [AppTheme.accentColor.withValues(alpha: 0.9), AppTheme.accentColor.withValues(alpha: 0.7)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedIndex == 0 
                              ? AppTheme.accentColor
                              : AppTheme.accentColor.withValues(alpha: 0.5),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: selectedIndex == 0
                                ? Colors.white.withValues(alpha: 0.3)
                                : AppTheme.accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        homeItem.icon,
                        color: selectedIndex == 0
                            ? AppTheme.primaryColor
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Items derecha (Polos, Encuestas) - con Expanded para distribuir
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rightItems.asMap().entries.map((entry) {
                    final actualIndex = entry.key + 3;
                    final item = entry.value;
                    final isSelected = actualIndex == selectedIndex;
                    return _buildNavItem(item, isSelected, () => onItemSelected(actualIndex));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
