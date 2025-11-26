import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Panel de filtros para inversiones
class InversionesFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedSector;
  final String selectedMontoRange;
  final String sortBy;
  final List<String> sectores;
  final Function(String) onSearchChanged;
  final Function(String) onSectorChanged;
  final Function(String) onMontoRangeChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;
  
  const InversionesFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedSector,
    required this.selectedMontoRange,
    required this.sortBy,
    required this.sectores,
    required this.onSearchChanged,
    required this.onSectorChanged,
    required this.onMontoRangeChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      selectedSector != 'Todos' || 
      selectedMontoRange != 'Todos' || 
      searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool useMobileFilters = screenWidth < 600;
    final double horizontalPadding = screenWidth < 400 ? 12 : (screenWidth < 600 ? 16 : 32);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: useMobileFilters ? 12 : 16,
      ),
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
      child: useMobileFilters
          ? _buildMobileFilters(context, isDark)
          : _buildDesktopFilters(context, isDark, screenWidth),
    );
  }

  Widget _buildDesktopFilters(BuildContext context, bool isDark, double screenWidth) {
    final bool isCompact = screenWidth < 1100;
    final double searchWidth = screenWidth < 900 ? 160 : 220;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Barra de búsqueda
        SizedBox(
          width: searchWidth,
          height: 40,
          child: _buildSearchField(isDark),
        ),
        
        // Separador vertical
        if (screenWidth >= 900)
          Container(
            height: 24,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0),
          ),
        
        // Grupo de filtros
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            if (!isCompact)
              Text(
                'Filtros:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              isDark: isDark,
              value: selectedSector,
              items: sectores,
              onChanged: onSectorChanged,
              compact: isCompact,
            ),
          ],
        ),
        
        // Grupo de ordenamiento
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCompact)
              Text(
                'Ordenar:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
            if (!isCompact) const SizedBox(width: 8),
            _buildSortDropdown(isDark, compact: isCompact),
          ],
        ),
        
        // Botón limpiar filtros
        if (hasActiveFilters)
          TextButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.clear_rounded, size: 14),
            label: Text(isCompact ? '' : 'Limpiar'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileFilters(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de búsqueda móvil
        _buildSearchField(isDark, isMobile: true),
        const SizedBox(height: 12),
        
        // Título de filtros
        Row(
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.lightText,
              ),
            ),
            const Spacer(),
            if (hasActiveFilters)
              GestureDetector(
                onTap: onClearFilters,
                child: Text(
                  'Limpiar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Fila de filtros
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context: context,
                isDark: isDark,
                label: selectedSector == 'Todos' ? 'Sector' : selectedSector,
                isActive: selectedSector != 'Todos',
                onTap: () => _showFilterBottomSheet(
                  context: context,
                  isDark: isDark,
                  title: 'Seleccionar Sector',
                  options: sectores,
                  selectedValue: selectedSector,
                  onSelected: onSectorChanged,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                isDark: isDark,
                label: selectedMontoRange == 'Todos' ? 'Inversión' : selectedMontoRange,
                isActive: selectedMontoRange != 'Todos',
                onTap: () => _showFilterBottomSheet(
                  context: context,
                  isDark: isDark,
                  title: 'Rango de Inversión',
                  options: const ['Todos', '< 2B', '2B - 4B', '> 4B'],
                  selectedValue: selectedMontoRange,
                  onSelected: onMontoRangeChanged,
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                isDark: isDark,
                label: _getSortLabel(sortBy),
                isActive: sortBy != 'nombre',
                onTap: () => _showFilterBottomSheet(
                  context: context,
                  isDark: isDark,
                  title: 'Ordenar por',
                  options: const ['nombre', 'monto_asc', 'monto_desc'],
                  optionLabels: const {
                    'nombre': 'Nombre A-Z',
                    'monto_asc': 'Inversión (menor)',
                    'monto_desc': 'Inversión (mayor)',
                  },
                  selectedValue: sortBy,
                  onSelected: onSortChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark, {bool isMobile = false}) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : AppTheme.lightText,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar proyecto...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white38 : AppTheme.lightTextSecondary,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
        ),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                ),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: isMobile ? 12 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required bool isDark,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
            size: compact ? 16 : 20,
          ),
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              compact && item.length > 12 ? '${item.substring(0, 10)}...' : item,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(bool isDark, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: sortBy,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
            size: compact ? 16 : 20,
          ),
          style: TextStyle(
            fontSize: compact ? 11 : 13,
            color: isDark ? Colors.white : AppTheme.lightText,
          ),
          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
          items: [
            DropdownMenuItem(value: 'nombre', child: Text(compact ? 'A-Z' : 'Nombre A-Z')),
            DropdownMenuItem(value: 'monto_asc', child: Text(compact ? '↑ Inv' : 'Inversión (menor)')),
            DropdownMenuItem(value: 'monto_desc', child: Text(compact ? '↓ Inv' : 'Inversión (mayor)')),
          ],
          onChanged: (v) => onSortChanged(v!),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required bool isDark,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive 
                ? AppTheme.primaryColor
                : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE0E0E0)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive 
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white70 : AppTheme.lightTextSecondary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive 
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.white54 : AppTheme.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'monto_asc':
        return 'Inversión ↑';
      case 'monto_desc':
        return 'Inversión ↓';
      default:
        return 'Ordenar';
    }
  }

  void _showFilterBottomSheet({
    required BuildContext context,
    required bool isDark,
    required String title,
    required List<String> options,
    Map<String, String>? optionLabels,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => ListTile(
              title: Text(
                optionLabels?[option] ?? option,
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.lightText,
                  fontWeight: option == selectedValue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: option == selectedValue 
                  ? Icon(Icons.check_rounded, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
