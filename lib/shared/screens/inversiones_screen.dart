import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../service/inversiones_service.dart';

/// Pantalla de Inversiones con carrusel hero sticky y cards de propuestas
class InversionesScreen extends StatefulWidget {
  const InversionesScreen({super.key});

  @override
  State<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  final PageController _pageController = PageController();
  final InversionesService _inversionesService = InversionesService();
  
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Estado de carga
  bool _isLoading = true;
  String? _errorMessage;
  List<ProyectoInversion> _proyectos = [];

  // Paginación de cards
  int _currentCardsPage = 0;
  
  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Filtros
  String _selectedSector = 'Todos';
  String _selectedMontoRange = 'Todos';
  String _sortBy = 'nombre';

  // Altura del carrusel
  static const double _carouselHeight = 300;

  // Imágenes del carrusel (placeholder por ahora)
  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'Infraestructura Energética',
      'subtitle': '\$40.2 mil millones USD en inversión',
      'color': '0xFF1565C0',
    },
    {
      'title': 'Manufactura Especializada',
      'subtitle': '1.5 millones de empleos nuevos',
      'color': '0xFF2E7D32',
    },
    {
      'title': 'Nearshoring',
      'subtitle': 'Relocalización de cadenas productivas',
      'color': '0xFF7B1FA2',
    },
    {
      'title': 'Contenido Nacional',
      'subtitle': 'Fortalecimiento de proveedores locales',
      'color': '0xFFE65100',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _cargarProyectos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarProyectos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final proyectos = await _inversionesService.getProyectos();
      if (!mounted) return;
      setState(() {
        _proyectos = proyectos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar proyectos: $e';
        _isLoading = false;
      });
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _carouselItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Obtiene el ícono según el sector
  IconData _getIconForSector(String sector) {
    switch (sector.toLowerCase()) {
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'electricidad':
        return Icons.bolt_rounded;
      case 'agua y medio ambiente':
        return Icons.water_drop_rounded;
      case 'inmobiliario y turismo':
        return Icons.beach_access_rounded;
      case 'telecomunicaciones':
        return Icons.cell_tower_rounded;
      case 'hidrocarburos':
        return Icons.oil_barrel_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoints responsivos
    final isExtraSmall = screenWidth < 400;
    final isSmall = screenWidth >= 400 && screenWidth < 600;
    final isMedium = screenWidth >= 600 && screenWidth < 900;
    final isLarge = screenWidth >= 900 && screenWidth < 1200;
    final isDesktop = screenWidth >= 768;

    // Calcular columnas del grid según el ancho
    int gridColumns;
    if (isExtraSmall) {
      gridColumns = 1;
    } else if (isSmall) {
      gridColumns = 2;
    } else if (isMedium) {
      gridColumns = 3;
    } else if (isLarge) {
      gridColumns = 4;
    } else {
      gridColumns = 4; // isExtraLarge
    }

    // Aspect ratio adaptativo - valores más bajos = cards más altos
    double cardAspectRatio;
    if (isExtraSmall) {
      cardAspectRatio = 0.95; // 1 columna, cards más anchos que altos
    } else if (isSmall) {
      cardAspectRatio = 0.72; // 2 columnas
    } else if (isMedium) {
      cardAspectRatio = 0.75; // 3 columnas
    } else {
      cardAspectRatio = 0.78; // 4 columnas
    }

    // Si está cargando, mostrar indicador
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando proyectos...'),
            ],
          ),
        ),
      );
    }

    // Si hay error, mostrar mensaje
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cargarProyectos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Obtener sectores únicos para el filtro
    final sectores = ['Todos', ..._proyectos.map((p) => p.sector).where((s) => s.isNotEmpty).toSet().toList()];
    
    // Filtrar proyectos
    List<ProyectoInversion> proyectosFiltrados = _proyectos.where((p) {
      // Filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!p.proyecto.toLowerCase().contains(query) && 
            !p.sector.toLowerCase().contains(query) &&
            !p.descripcion.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedSector != 'Todos' && p.sector != _selectedSector) return false;
      if (_selectedMontoRange != 'Todos') {
        final monto = p.inversionMXN ?? 0;
        switch (_selectedMontoRange) {
          case '< 2B':
            if (monto >= 2000) return false;
            break;
          case '2B - 4B':
            if (monto < 2000 || monto > 4000) return false;
            break;
          case '> 4B':
            if (monto <= 4000) return false;
            break;
        }
      }
      return true;
    }).toList();

    // Ordenar
    switch (_sortBy) {
      case 'nombre':
        proyectosFiltrados.sort((a, b) => a.proyecto.compareTo(b.proyecto));
        break;
      case 'monto_asc':
        proyectosFiltrados.sort((a, b) {
          final montoA = a.inversionMXN ?? 0;
          final montoB = b.inversionMXN ?? 0;
          return montoA.compareTo(montoB);
        });
        break;
      case 'monto_desc':
        proyectosFiltrados.sort((a, b) {
          final montoA = a.inversionMXN ?? 0;
          final montoB = b.inversionMXN ?? 0;
          return montoB.compareTo(montoA);
        });
        break;
    }

    // Paginación responsiva según columnas
    // Cambiar rowsPerPage para ajustar la cantidad de cards por página
    // Fórmula: cardsPerPage = gridColumns * rowsPerPage
    // Ejemplo: 4 columnas * 6 filas = 24 cards (para mostrar ~21)
    final int rowsPerPage = 5;
    final int cardsPerPage = gridColumns * rowsPerPage;
    final int totalPages = (proyectosFiltrados.length / cardsPerPage).ceil();
    final int startIndex = _currentCardsPage * cardsPerPage;
    final int endIndex = (startIndex + cardsPerPage).clamp(0, proyectosFiltrados.length);
    final proyectosPagina = proyectosFiltrados.sublist(startIndex, endIndex);

    // Espaciado responsivo
    final double gridSpacing = isExtraSmall ? 8 : (isSmall ? 10 : (isMedium ? 12 : 16));
    final double pagePadding = isExtraSmall ? 12 : (isSmall ? 16 : (isDesktop ? 32 : 20));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrusel Hero
            _buildCarousel(isDark, isDesktop),

            // Separador
            _buildSeparator(isDark),

            // Panel de Filtros
            _buildFiltersPanel(isDark, isDesktop, sectores, screenWidth),

            // Grid de propuestas
            Padding(
              padding: EdgeInsets.all(pagePadding),
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridColumns,
                      mainAxisSpacing: gridSpacing,
                      crossAxisSpacing: gridSpacing,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemCount: proyectosPagina.length,
                    itemBuilder: (context, index) => _buildProyectoCard(proyectosPagina[index], isDark, isDesktop, screenWidth),
                  ),
                  
                  // Paginación
                  if (totalPages > 1) ...[
                    const SizedBox(height: 24),
                    _buildPagination(isDark, isDesktop, totalPages),
                  ],
                ],
              ),
            ),

            // Espacio mínimo al final para que el FAB no tape contenido importante
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(bool isDark, bool isDesktop, List<String> sectores, double screenWidth) {
    // Determinar si mostrar versión compacta de filtros
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
          ? _buildMobileFilters(isDark, sectores)
          : _buildDesktopFilters(isDark, sectores, screenWidth),
    );
  }

  Widget _buildDesktopFilters(bool isDark, List<String> sectores, double screenWidth) {
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
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {
              _searchQuery = value;
              _currentCardsPage = 0;
            }),
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                      ),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _currentCardsPage = 0;
                      }),
                    )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          ),
        ),
        
        // Separador vertical (solo en pantallas grandes)
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
              label: 'Sector',
              value: _selectedSector,
              items: sectores,
              onChanged: (value) => setState(() {
                _selectedSector = value!;
                _currentCardsPage = 0;
              }),
              compact: isCompact,
            ),
            const SizedBox(width: 8),
            // _buildFilterDropdown(
            //   isDark: isDark,
            //   label: 'Inversión',
            //   value: _selectedMontoRange,
            //   items: const ['Todos', '< 2B', '2B - 4B', '> 4B'],
            //   onChanged: (value) => setState(() {
            //     _selectedMontoRange = value!;
            //     _currentCardsPage = 0;
            //   }),
            //   compact: isCompact,
            // ),
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
        if (_selectedSector != 'Todos' || _selectedMontoRange != 'Todos' || _searchQuery.isNotEmpty)
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedSector = 'Todos';
              _selectedMontoRange = 'Todos';
              _sortBy = 'nombre';
              _searchController.clear();
              _searchQuery = '';
              _currentCardsPage = 0;
            }),
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

  Widget _buildMobileFilters(bool isDark, List<String> sectores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de búsqueda móvil
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {
            _searchQuery = value;
            _currentCardsPage = 0;
          }),
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
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                    ),
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _currentCardsPage = 0;
                    }),
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ),
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
            if (_selectedSector != 'Todos' || _selectedMontoRange != 'Todos' || _searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() {
                  _selectedSector = 'Todos';
                  _selectedMontoRange = 'Todos';
                  _sortBy = 'nombre';
                  _searchController.clear();
                  _searchQuery = '';
                  _currentCardsPage = 0;
                }),
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
                isDark: isDark,
                label: _selectedSector == 'Todos' ? 'Sector' : _selectedSector,
                isActive: _selectedSector != 'Todos',
                onTap: () => _showFilterBottomSheet(
                  context: context,
                  isDark: isDark,
                  title: 'Seleccionar Sector',
                  options: sectores,
                  selectedValue: _selectedSector,
                  onSelected: (value) => setState(() {
                    _selectedSector = value;
                    _currentCardsPage = 0;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                isDark: isDark,
                label: _selectedMontoRange == 'Todos' ? 'Inversión' : _selectedMontoRange,
                isActive: _selectedMontoRange != 'Todos',
                onTap: () => _showFilterBottomSheet(
                  context: context,
                  isDark: isDark,
                  title: 'Rango de Inversión',
                  options: const ['Todos', '< 2B', '2B - 4B', '> 4B'],
                  selectedValue: _selectedMontoRange,
                  onSelected: (value) => setState(() {
                    _selectedMontoRange = value;
                    _currentCardsPage = 0;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                isDark: isDark,
                label: _getSortLabel(_sortBy),
                isActive: _sortBy != 'nombre',
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
                  selectedValue: _sortBy,
                  onSelected: (value) => setState(() => _sortBy = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required bool isDark,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
          onChanged: onChanged,
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
          value: _sortBy,
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
          onChanged: (value) => setState(() => _sortBy = value!),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
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

  Widget _buildPagination(bool isDark, bool isDesktop, int totalPages) {
    // Construir lista de páginas a mostrar: primera, anterior, actual, siguiente, última
    final List<int?> pagesToShow = [];
    
    // Siempre mostrar primera página
    pagesToShow.add(0);
    
    if (totalPages > 1) {
      // Agregar "..." si hay gap después de la primera
      if (_currentCardsPage > 2) {
        pagesToShow.add(null); // null representa "..."
      }
      
      // Página anterior (si existe y no es la primera)
      if (_currentCardsPage > 1) {
        pagesToShow.add(_currentCardsPage - 1);
      }
      
      // Página actual (si no es la primera ni la última)
      if (_currentCardsPage > 0 && _currentCardsPage < totalPages - 1) {
        pagesToShow.add(_currentCardsPage);
      }
      
      // Página siguiente (si existe y no es la última)
      if (_currentCardsPage < totalPages - 2) {
        pagesToShow.add(_currentCardsPage + 1);
      }
      
      // Agregar "..." si hay gap antes de la última
      if (_currentCardsPage < totalPages - 3) {
        pagesToShow.add(null); // null representa "..."
      }
      
      // Siempre mostrar última página
      pagesToShow.add(totalPages - 1);
    }
    
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
            enabled: _currentCardsPage > 0,
            onPressed: () => setState(() => _currentCardsPage--),
          ),
          
          const SizedBox(width: 8),
          
          // Indicadores de página
          ...pagesToShow.map((pageIndex) {
            if (pageIndex == null) {
              // Mostrar "..."
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
            
            final isActive = pageIndex == _currentCardsPage;
            return _buildPageIndicator(
              isDark: isDark,
              pageNumber: pageIndex + 1,
              isActive: isActive,
              onTap: () => setState(() => _currentCardsPage = pageIndex),
            );
          }),
          
          const SizedBox(width: 8),
          
          // Botón siguiente
          _buildPaginationButton(
            isDark: isDark,
            icon: Icons.chevron_right_rounded,
            enabled: _currentCardsPage < totalPages - 1,
            onPressed: () => setState(() => _currentCardsPage++),
          ),
        ],
      ),
    );
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

  Widget _buildCarousel(bool isDark, bool isDesktop) {
    return SizedBox(
      height: _carouselHeight,
      child: Stack(
        children: [
          // PageView del carrusel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentPage = index);
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              final color = Color(int.parse(item['color']!));
              
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.8),
                      AppTheme.primaryColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Patrón decorativo
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    // Contenido
                    Padding(
                      padding: EdgeInsets.all(isDesktop ? 40 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'INVERSIÓN ESTRATÉGICA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontSize: isDesktop ? 32 : 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle']!,
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Indicadores de página
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_carouselItems.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(bool isDark) {
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
              '${_proyectos.length} proyectos',
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

  Widget _buildProyectoCard(ProyectoInversion proyecto, bool isDark, bool isDesktop, double screenWidth) {
    // Tamaños responsivos basados en ancho de pantalla
    final bool isExtraSmall = screenWidth < 400;
    final bool isSmall = screenWidth >= 400 && screenWidth < 600;
    
    // Calcular tamaños dinámicamente
    final double iconSize = isExtraSmall ? 16 : (isSmall ? 18 : (isDesktop ? 22 : 20));
    final double iconPadding = isExtraSmall ? 6 : (isSmall ? 8 : 10);
    final double cardPadding = isExtraSmall ? 8 : (isSmall ? 10 : (isDesktop ? 16 : 12));
    final double titleSize = isExtraSmall ? 11 : (isSmall ? 12 : (isDesktop ? 14 : 13));
    final double montoSize = isExtraSmall ? 12 : (isSmall ? 14 : (isDesktop ? 18 : 15));
    final double sectorFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    final double descFontSize = isExtraSmall ? 8 : (isSmall ? 9 : 10);
    final double tipoFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar si hay suficiente espacio para todos los elementos
        final bool isCompact = constraints.maxHeight < 180;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(isExtraSmall ? 10 : 14),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.08) 
                  : const Color(0xFFE8E8E8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Navegar a detalle de proyecto o abrir URL
                if (proyecto.url.isNotEmpty) {
                  // Abrir URL del proyecto
                }
              },
              borderRadius: BorderRadius.circular(isExtraSmall ? 10 : 14),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono y sector - altura fija
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(isExtraSmall ? 6 : 10),
                          ),
                          child: Icon(
                            _getIconForSector(proyecto.sector),
                            color: AppTheme.primaryColor,
                            size: iconSize,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isExtraSmall ? 4 : 6, 
                              vertical: isExtraSmall ? 2 : 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              proyecto.sector,
                              style: TextStyle(
                                fontSize: sectorFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isCompact ? 4 : 8),

                    // Título (nombre del proyecto) - máximo 2 líneas
                    Text(
                      proyecto.proyecto,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.lightText,
                        height: 1.2,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Descripción - solo si hay espacio
                    if (!isCompact && proyecto.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        proyecto.descripcion,
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Espacio flexible
                    const Expanded(child: SizedBox(height: 4)),

                    // Monto en MXN
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        proyecto.montoFormateado,
                        style: TextStyle(
                          fontSize: montoSize,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 2 : 6),

                    // Tipo de proyecto
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: isExtraSmall ? 10 : 12,
                          color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            proyecto.tipoProyecto.isNotEmpty 
                                ? proyecto.tipoProyecto 
                                : 'Sin clasificar',
                            style: TextStyle(
                              fontSize: tipoFontSize,
                              color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
