import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../service/inversiones_service.dart';
import '../widgets/inversiones/inversiones_widgets.dart';

/// Pantalla de Inversiones modular con carrusel hero sticky y cards de propuestas
class InversionesScreen extends StatefulWidget {
  const InversionesScreen({super.key});

  @override
  State<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  final InversionesService _inversionesService = InversionesService();

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

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  void _clearFilters() {
    setState(() {
      _selectedSector = 'Todos';
      _selectedMontoRange = 'Todos';
      _sortBy = 'nombre';
      _searchController.clear();
      _searchQuery = '';
      _currentCardsPage = 0;
    });
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
      gridColumns = 4;
    }

    // Aspect ratio adaptativo
    double cardAspectRatio;
    if (isExtraSmall) {
      cardAspectRatio = 0.95;
    } else if (isSmall) {
      cardAspectRatio = 0.72;
    } else if (isMedium) {
      cardAspectRatio = 0.75;
    } else {
      cardAspectRatio = 0.78;
    }

    // Si está cargando
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : const Color(0xFFF5F5F5),
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

    // Si hay error
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : const Color(0xFFF5F5F5),
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
    final sectores = [
      'Todos',
      ..._proyectos
          .map((p) => p.sector)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList(),
    ];

    // Filtrar proyectos
    List<ProyectoInversion> proyectosFiltrados = _filtrarProyectos();

    // Paginación
    final int rowsPerPage = 5;
    final int cardsPerPage = gridColumns * rowsPerPage;
    final int totalPages = (proyectosFiltrados.length / cardsPerPage).ceil();
    final int startIndex = _currentCardsPage * cardsPerPage;
    final int endIndex = (startIndex + cardsPerPage).clamp(
      0,
      proyectosFiltrados.length,
    );
    final proyectosPagina = proyectosFiltrados.sublist(startIndex, endIndex);

    // Espaciado responsivo
    final double gridSpacing = isExtraSmall
        ? 8
        : (isSmall ? 10 : (isMedium ? 12 : 16));
    final double pagePadding = isExtraSmall
        ? 12
        : (isSmall ? 16 : (isDesktop ? 32 : 20));

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrusel Hero
            const InversionesCarousel(),

            // Separador
            InversionesSeparator(totalProyectos: _proyectos.length),

            // Panel de Filtros
            InversionesFilters(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedSector: _selectedSector,
              selectedMontoRange: _selectedMontoRange,
              sortBy: _sortBy,
              sectores: sectores,
              onSearchChanged: (value) => setState(() {
                _searchQuery = value;
                _currentCardsPage = 0;
              }),
              onSectorChanged: (value) => setState(() {
                _selectedSector = value;
                _currentCardsPage = 0;
              }),
              onMontoRangeChanged: (value) => setState(() {
                _selectedMontoRange = value;
                _currentCardsPage = 0;
              }),
              onSortChanged: (value) => setState(() => _sortBy = value),
              onClearFilters: _clearFilters,
            ),

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
                    itemBuilder: (context, index) => ProyectoCard(
                      proyecto: proyectosPagina[index],
                      onTap: () {
                        // TODO: Navegar a detalle o abrir URL
                      },
                    ),
                  ),

                  // Paginación
                  if (totalPages > 1) ...[
                    const SizedBox(height: 24),
                    InversionesPagination(
                      currentPage: _currentCardsPage,
                      totalPages: totalPages,
                      onPageChanged: (page) =>
                          setState(() => _currentCardsPage = page),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<ProyectoInversion> _filtrarProyectos() {
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
      if (_selectedSector != 'Todos' && p.sector != _selectedSector)
        return false;
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

    return proyectosFiltrados;
  }
}
