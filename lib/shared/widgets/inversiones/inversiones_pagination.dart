import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget de paginación para inversiones
class InversionesPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  
  const InversionesPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Construir lista de páginas a mostrar
    final List<int?> pagesToShow = _buildPagesToShow();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          _buildPaginationButton(
            isDark: isDark,
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 0,
            onPressed: () => onPageChanged(currentPage - 1),
          ),
          
          const SizedBox(width: 8),
          
          // Indicadores de página
          ...pagesToShow.map((pageIndex) {
            if (pageIndex == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '•••',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            
            final isActive = pageIndex == currentPage;
            return _buildPageIndicator(
              isDark: isDark,
              pageNumber: pageIndex + 1,
              isActive: isActive,
              onTap: () => onPageChanged(pageIndex),
            );
          }),
          
          const SizedBox(width: 8),
          
          // Botón siguiente
          _buildPaginationButton(
            isDark: isDark,
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages - 1,
            onPressed: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<int?> _buildPagesToShow() {
    final List<int?> pagesToShow = [];
    
    // Siempre mostrar primera página
    pagesToShow.add(0);
    
    if (totalPages > 1) {
      // Agregar "..." si hay gap después de la primera
      if (currentPage > 2) {
        pagesToShow.add(null);
      }
      
      // Página anterior
      if (currentPage > 1) {
        pagesToShow.add(currentPage - 1);
      }
      
      // Página actual
      if (currentPage > 0 && currentPage < totalPages - 1) {
        pagesToShow.add(currentPage);
      }
      
      // Página siguiente
      if (currentPage < totalPages - 2) {
        pagesToShow.add(currentPage + 1);
      }
      
      // Agregar "..." si hay gap antes de la última
      if (currentPage < totalPages - 3) {
        pagesToShow.add(null);
      }
      
      // Siempre mostrar última página
      pagesToShow.add(totalPages - 1);
    }
    
    return pagesToShow;
  }

  Widget _buildPaginationButton({
    required bool isDark,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: enabled
                ? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? (isDark ? Colors.white70 : AppTheme.lightText)
                : (isDark ? Colors.white24 : Colors.grey[300]),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator({
    required bool isDark,
    required int pageNumber,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive 
              ? AppTheme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive 
                  ? Colors.white
                  : (isDark ? Colors.white60 : AppTheme.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
