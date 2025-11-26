import 'package:flutter/material.dart';
import '../widgets/mexico_map_widget.dart';

class PolosScreen extends StatefulWidget {
  const PolosScreen({super.key});

  @override
  State<PolosScreen> createState() => _PolosScreenState();
}

class _PolosScreenState extends State<PolosScreen> {
  String? _selectedStateCode;
  String? _selectedStateName;
  String? _hoveredStateName;
  PoloInfo? _selectedPolo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(isDark, isDesktop),
              const SizedBox(height: 24),
              
              // Contenido principal
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(isDark)
                    : _buildMobileLayout(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF691C32).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Polos de Desarrollo',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona un estado para ver sus polos de desarrollo',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Mapa
        Expanded(
          flex: 3,
          child: _buildMapContainer(isDark),
        ),
        const SizedBox(width: 24),
        // Panel de información
        Expanded(
          flex: 2,
          child: _buildInfoPanel(isDark),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        // Mapa
        Expanded(
          flex: 2,
          child: _buildMapContainer(isDark),
        ),
        const SizedBox(height: 16),
        // Panel de información
        Expanded(
          flex: 1,
          child: _buildInfoPanel(isDark),
        ),
      ],
    );
  }

  Widget _buildMapContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            MexicoMapWidget(
              selectedStateCode: _selectedStateCode,
              onStateSelected: (code, name) {
                setState(() {
                  // Si code está vacío, es una deselección
                  _selectedStateCode = code.isEmpty ? null : code;
                  _selectedStateName = name.isEmpty ? null : name;
                  _selectedPolo = null; // Limpiar polo al cambiar estado
                });
              },
              onPoloSelected: (polo) {
                setState(() {
                  _selectedPolo = polo;
                });
              },
              onBackToMap: () {
                // Opcional: resetear selección al volver al mapa
              },
              onStateHover: (code, name) {
                setState(() {
                  _hoveredStateName = name.isEmpty ? null : name;
                });
              },
            ),
            // Indicador de instrucciones
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _selectedStateName == null ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mouse_rounded,
                          size: 16,
                          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hoveredStateName != null
                              ? _hoveredStateName!
                              : 'Pasa el cursor sobre un estado para elevarlo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: _selectedPolo != null
          ? _buildPoloInfo(isDark)
          : (_selectedStateName == null
              ? _buildEmptyState(isDark)
              : _buildStateInfo(isDark)),
    );
  }

  Widget _buildPoloInfo(bool isDark) {
    final polo = _selectedPolo!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón para volver
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPolo = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Información del Polo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Imagen principal
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildPoloImage(
                polo.imagenes.isNotEmpty ? polo.imagenes[0] : '',
                isDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Tipo de polo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nuevo Polo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Nombre del polo
          Text(
            polo.nombre,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          
          // Ubicación
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                polo.ubicacion,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Descripción
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            polo.descripcion,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          
          // Botón "Ir al lugar"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Abrir en Google Maps o navegador
                _openLocation(polo.latitud, polo.longitud);
              },
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Visitar virtualmente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
                    // Botón "Ir al lugar"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Abrir en Google Maps o navegador
                _openLocation(polo.latitud, polo.longitud);
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Dar mi punto de vista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLocation(double lat, double lng) {
    // Por ahora solo muestra un snackbar, pero aquí puedes implementar
    // la navegación a Google Maps usando url_launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abriendo ubicación: $lat, $lng'),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPoloImage(String imagePath, bool isDark) {
    if (imagePath.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
        child: Center(
          child: Icon(
            Icons.image_rounded,
            size: 48,
            color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
          ),
        ),
      );
    }
    
    // Si es una imagen local (assets)
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error cargando imagen: $error');
          return Container(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar imagen',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    
    // Si es una imagen de red
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          child: Center(
            child: Icon(
              Icons.image_rounded,
              size: 48,
              color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila 1: En marcha | A licitar o en proceso
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(isDark, 
                  color: const Color(0xFF006847), 
                  label: 'En marcha',
                  isSelected: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryButton(isDark, 
                  color: const Color(0xFFB8D4B8), 
                  label: 'A licitar o en proceso',
                  isSelected: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Fila 2: Nuevos polos | En proceso de evaluación
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(isDark, 
                  color: const Color(0xFF2563EB), 
                  label: 'Nuevos polos',
                  isSelected: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryButton(isDark, 
                  color: const Color(0xFFE89005), 
                  label: 'En proceso de evaluación',
                  isSelected: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Fila 3: Tercera etapa
          Row(
            children: [
              Expanded(
                child: _buildCategoryButton(isDark, 
                  color: const Color(0xFFD4B896), 
                  label: 'Tercera etapa: en evaluación',
                  isSelected: false,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // Espacio vacío
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Sectores estratégicos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                _buildSectorRow([
                  _buildSectorItem(Icons.agriculture_rounded, 'Agroindustria', isDark),
                  _buildSectorItem(Icons.recycling_rounded, 'Economía circular', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.flight_rounded, 'Aeroespacial', isDark),
                  _buildSectorItem(Icons.wb_sunny_rounded, 'Energías limpias', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.electric_car_rounded, 'Automotriz y electromovilidad', isDark),
                  _buildSectorItem(Icons.factory_rounded, 'Industrias metálicas básicas', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.shopping_bag_rounded, 'Bienes de consumo', isDark),
                  _buildSectorItem(Icons.description_rounded, 'Industria del papel', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.medical_services_rounded, 'Farmacéutica y dispositivos médicos', isDark),
                  _buildSectorItem(Icons.science_rounded, 'Industria del plástico', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.memory_rounded, 'Electrónica y semiconductores', isDark),
                  _buildSectorItem(Icons.local_shipping_rounded, 'Logística', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.bolt_rounded, 'Energía', isDark),
                  _buildSectorItem(Icons.precision_manufacturing_rounded, 'Metalmecánica', isDark),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.science_outlined, 'Química y petroquímica', isDark),
                  const Expanded(child: SizedBox()),
                ]),
                const SizedBox(height: 12),
                _buildSectorRow([
                  _buildSectorItem(Icons.checkroom_rounded, 'Textil y calzado', isDark),
                  const Expanded(child: SizedBox()),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(bool isDark, {
    required Color color,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected 
            ? color.withValues(alpha: 0.15)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? color 
              : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget _buildSectorItem(IconData icon, String label, bool isDark) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateInfo(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF691C32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Color(0xFF691C32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStateName ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Código: ${_selectedStateCode ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Estadísticas placeholder
          _buildStatCard(
            isDark,
            icon: Icons.business_rounded,
            title: 'Polos de desarrollo',
            value: '0',
            subtitle: 'En este estado',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.people_rounded,
            title: 'Población beneficiada',
            value: '--',
            subtitle: 'Habitantes',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            isDark,
            icon: Icons.trending_up_rounded,
            title: 'Inversión proyectada',
            value: '--',
            subtitle: 'MXN',
          ),
          
          const SizedBox(height: 24),
          
          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navegar a detalle del estado
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF691C32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ver detalles del estado',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF691C32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF691C32),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
