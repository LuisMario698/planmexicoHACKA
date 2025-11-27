import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../service/inversiones_service.dart';
import '../widgets/inversiones/inversiones_widgets.dart';
import '../widgets/inversiones/inversiones_tutorial_overlay.dart';

class InversionesScreen extends StatefulWidget {
  const InversionesScreen({super.key});

  @override
  State<InversionesScreen> createState() => _InversionesScreenState();
}

class _InversionesScreenState extends State<InversionesScreen> {
  final InversionesService _inversionesService = InversionesService();

  // --- VARIABLES TUTORIAL ---
  final GlobalKey _firstCardKey = GlobalKey();
  bool _showTutorial = false;
  Rect? _targetRect;
  // --------------------------

  bool _isLoading = true;
  String? _errorMessage;
  List<ProyectoInversion> _proyectos = [];

  // Paginación y Filtros
  int _currentCardsPage = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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

      // Intentar iniciar tutorial cuando carguen los datos
      _checkTutorialStatus();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar proyectos: $e';
        _isLoading = false;
      });
    }
  }

  // --- LÓGICA TUTORIAL ---
  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('tutorial_inversiones_seen') ?? false;

    if (!seen && _proyectos.isNotEmpty) {
      // Esperamos a que se dibuje el frame para obtener coordenadas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _findFirstCardPosition();
      });
    }
  }

  void _findFirstCardPosition() {
    // Buscamos la posición de la tarjeta en la pantalla
    final RenderBox? renderBox =
        _firstCardKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(
        Offset.zero,
      ); // Coordenadas globales
      final size = renderBox.size;

      // IMPORTANTE: Si la posición 'y' incluye la barra de estado o AppBar padre,
      // RenderBox localToGlobal ya lo toma en cuenta.
      setState(() {
        _targetRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );
        _showTutorial = true;
      });
    }
  }

  void _completeTutorial() async {
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_inversiones_seen', true);
  }
  // ----------------------

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
    // Breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isExtraSmall = screenWidth < 400;
    final isSmall = screenWidth >= 400 && screenWidth < 600;
    final isMedium = screenWidth >= 600 && screenWidth < 900;
    final isLarge = screenWidth >= 900 && screenWidth < 1200;
    final isDesktop = screenWidth >= 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Configuración Grid
    int gridColumns = isExtraSmall ? 1 : (isSmall ? 2 : (isMedium ? 3 : 4));
    double cardAspectRatio = isExtraSmall ? 0.95 : (isSmall ? 0.72 : 0.78);
    final double gridSpacing = isExtraSmall ? 8 : (isSmall ? 10 : 16);
    final double pagePadding = isExtraSmall ? 12 : (isSmall ? 16 : 20);

    // Filtrado (Lógica original)
    final sectores = [
      'Todos',
      ..._proyectos
          .map((p) => p.sector)
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList(),
    ];
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

    // ==========================================================
    // ESTRUCTURA PRINCIPAL: STACK COMO RAIZ PARA BLOQUEO TOTAL
    // ==========================================================
    return Stack(
      children: [
        // 1. CAPA INFERIOR: TU PANTALLA COMPLETA (SCAFFOLD)
        Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkBackground
              : const Color(0xFFF5F5F5),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  // Bloqueamos el scroll si el tutorial está activo
                  physics: _showTutorial
                      ? const NeverScrollableScrollPhysics()
                      : const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      const InversionesCarousel(),

                      InversionesSeparator(totalProyectos: _proyectos.length),

                      InversionesFilters(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        selectedSector: _selectedSector,
                        selectedMontoRange: _selectedMontoRange,
                        sortBy: _sortBy,
                        sectores: sectores,
                        onSearchChanged: (v) => setState(() {
                          _searchQuery = v;
                          _currentCardsPage = 0;
                        }),
                        onSectorChanged: (v) => setState(() {
                          _selectedSector = v;
                          _currentCardsPage = 0;
                        }),
                        onMontoRangeChanged: (v) => setState(() {
                          _selectedMontoRange = v;
                          _currentCardsPage = 0;
                        }),
                        onSortChanged: (v) => setState(() => _sortBy = v),
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridColumns,
                                    mainAxisSpacing: gridSpacing,
                                    crossAxisSpacing: gridSpacing,
                                    childAspectRatio: cardAspectRatio,
                                  ),
                              itemCount: proyectosPagina.length,
                              itemBuilder: (context, index) {
                                // Identificamos la PRIMERA tarjeta
                                final isFirstCard =
                                    (index == 0 && _currentCardsPage == 0);

                                return ProyectoCard(
                                  // Asignamos la Key solo a la primera tarjeta
                                  key: isFirstCard ? _firstCardKey : null,
                                  proyecto: proyectosPagina[index],
                                  onTap: () {
                                    if (_showTutorial) {
                                      if (isFirstCard) {
                                        // Acción correcta en Tutorial
                                        _completeTutorial();
                                        // TODO: Aquí abres tu detalle
                                        // Navigator.push(...) o showDialog(...)
                                      }
                                      // Si toca otra tarjeta durante el tutorial, el Overlay lo bloquea,
                                      // así que este 'else' es inaccesible visualmente, lo cual es correcto.
                                    } else {
                                      // Acción normal sin tutorial
                                      // Navigator.push(...)
                                    }
                                  },
                                );
                              },
                            ),
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
        ),

        // 2. CAPA SUPERIOR: TUTORIAL OVERLAY
        // Este widget se dibuja ENCIMA del Scaffold, bloqueando todo.
        if (_showTutorial && _targetRect != null)
          InversionesTutorialOverlay(
            targetRect: _targetRect!,
            onTargetTap: () {
              // El usuario tocó el hueco (la tarjeta correcta)
              _completeTutorial();

              // Opcional: Feedback visual
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("¡Perfecto! Has seleccionado un proyecto."),
                ),
              );
            },
            onSkip: _completeTutorial,
          ),
      ],
    );
  }

  // --- MÉTODOS FILTROS ORIGINALES ---
  List<ProyectoInversion> _filtrarProyectos() {
    // (Tu lógica de filtrado original va aquí sin cambios)
    // He copiado la lógica básica para referencia:
    List<ProyectoInversion> result = _proyectos.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.proyecto.toLowerCase().contains(q) &&
            !p.sector.toLowerCase().contains(q))
          return false;
      }
      if (_selectedSector != 'Todos' && p.sector != _selectedSector)
        return false;
      return true;
    }).toList();

    // Aquí iría tu switch de ordenamiento original...

    return result;
  }
}
