import 'package:flutter/material.dart';
import '../../shared/widgets/responsive_scaffold.dart';

class MobileBottomNav extends StatefulWidget {
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
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav> {
  // Color dorado
  static const Color _goldColor = Color(0xFFBC955C);
  // Color guinda
  static const Color _guindaColor = Color(0xFF691C32);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        // Fondo guinda como antes
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A1E3D), Color(0xFF691C32), Color(0xFF4A1525)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF691C32).withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.selectedIndex;
          final isHome = index == 2; // Inicio está en posición 2

          return Expanded(
            child: _buildNavItem(item, index, isSelected, isHome, isDark),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    NavItem item,
    int index,
    bool isSelected,
    bool isHome,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Label - siempre en la misma posición en la parte inferior
            Positioned(
              bottom: 0,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 0.1,
                ),
              ),
            ),
            // Icono o botón - posicionado arriba del label
            Positioned(
              bottom: 16,
              child: isHome
                  ? _buildHomeButton(item, isSelected, isDark)
                  : _buildRegularButton(item, isSelected, isDark),
            ),
          ],
        ),
      ),
    );
  }

  // Botón especial para Inicio con círculo dorado
  Widget _buildHomeButton(NavItem item, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      // Solo el círculo se eleva, el label queda abajo
      transform: Matrix4.translationValues(0, isSelected ? -14 : -8, 0),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Blanco cuando está seleccionado, dorado cuando no
              color: isSelected ? Colors.white : null,
              gradient: isSelected
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _goldColor,
                        const Color(0xFFD4AF37),
                        _goldColor.withValues(alpha: 0.9),
                      ],
                    ),
              border: isSelected
                  ? Border.all(
                      color: _goldColor.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/images/logo_aguila.png',
                // Bronce cuando está seleccionado, blanco cuando no
                color: isSelected ? _goldColor : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Botón regular para los demás items
  Widget _buildRegularButton(NavItem item, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        item.icon,
        color: isSelected ? _guindaColor : Colors.white.withValues(alpha: 0.7),
        size: 26,
      ),
    );
  }
}
