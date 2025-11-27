import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/polos_data.dart';

/// Pantalla "Mi Región" - Muestra los polos de desarrollo
/// cercanos a la ubicación del usuario
class MiRegionScreen extends StatefulWidget {
  const MiRegionScreen({super.key});

  @override
  State<MiRegionScreen> createState() => _MiRegionScreenState();
}

class _MiRegionScreenState extends State<MiRegionScreen> {
  // Colores oficiales
  static const Color guinda = Color(0xFF691C32);
  static const Color dorado = Color(0xFFBC955C);
  static const Color verde = Color(0xFF006847);

  // Estados que tienen polos de desarrollo
  static const Set<String> estadosConPolos = {
    'Sonora', 'Chihuahua', 'Tamaulipas', 'Coahuila', 'Nuevo León',
    'Guanajuato', 'Puebla', 'Durango', 'Estado de México', 
    'Ciudad de México', 'Oaxaca', 'Veracruz', 'Tabasco', 
    'Yucatán', 'Campeche'
  };

  bool _isLoading = true;
  String? _errorMessage;
  String _estadoDetectado = '';
  String _regionDetectada = '';
  List<PoloMarker> _polosEnMiRegion = [];
  Position? _currentPosition;
  bool _noPolosEnEstado = false;

  @override
  void initState() {
    super.initState();
    _detectarUbicacion();
  }

  Future<void> _detectarUbicacion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _noPolosEnEstado = false;
    });

    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'El servicio de ubicación está desactivado. Por favor, actívalo para continuar.';
          _isLoading = false;
        });
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Se requiere acceso a tu ubicación para mostrarte los polos de desarrollo cercanos.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = kIsWeb 
              ? 'Los permisos de ubicación fueron denegados. Permite el acceso a ubicación en tu navegador.'
              : 'Los permisos de ubicación están deshabilitados permanentemente. Por favor, actívalos en Configuración > Privacidad > Servicios de Localización.';
          _isLoading = false;
        });
        return;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15),
      );

      _currentPosition = position;

      // Encontrar el estado más cercano basado en las coordenadas
      _encontrarEstadoCercano(position.latitude, position.longitude);

    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      setState(() {
        _errorMessage = 'No pudimos obtener tu ubicación. Verifica que tengas conexión a internet y el GPS activo.';
        _isLoading = false;
      });
    }
  }

  void _encontrarEstadoCercano(double lat, double lng) {
    // Determinar el estado del usuario basándose en coordenadas aproximadas
    String estadoUsuario = _determinarEstadoPorCoordenadas(lat, lng);
    
    // Buscar polos en el estado del usuario
    final polosEstado = PolosData.polos
        .where((p) => p.estado == estadoUsuario)
        .toList();

    if (polosEstado.isEmpty) {
      // No hay polos en el estado, mostrar mensaje del asistente
      setState(() {
        _estadoDetectado = estadoUsuario;
        _noPolosEnEstado = true;
        _polosEnMiRegion = [];
        _isLoading = false;
      });
      return;
    }

    // Ordenar por distancia
    polosEstado.sort((a, b) {
      final distA = Geolocator.distanceBetween(lat, lng, a.lat, a.lng);
      final distB = Geolocator.distanceBetween(lat, lng, b.lat, b.lng);
      return distA.compareTo(distB);
    });

    setState(() {
      _estadoDetectado = estadoUsuario;
      _regionDetectada = polosEstado.first.region;
      _polosEnMiRegion = polosEstado;
      _isLoading = false;
    });
  }

  /// Determina el estado de México basándose en coordenadas aproximadas
  String _determinarEstadoPorCoordenadas(double lat, double lng) {
    final estadosCoordenadas = {
      'Aguascalientes': {'lat': 21.88, 'lng': -102.29},
      'Baja California': {'lat': 30.84, 'lng': -115.28},
      'Baja California Sur': {'lat': 26.01, 'lng': -111.35},
      'Campeche': {'lat': 19.83, 'lng': -90.53},
      'Chiapas': {'lat': 16.75, 'lng': -93.12},
      'Chihuahua': {'lat': 28.63, 'lng': -106.07},
      'Ciudad de México': {'lat': 19.43, 'lng': -99.13},
      'Coahuila': {'lat': 27.06, 'lng': -101.71},
      'Colima': {'lat': 19.24, 'lng': -103.72},
      'Durango': {'lat': 24.02, 'lng': -104.67},
      'Estado de México': {'lat': 19.49, 'lng': -99.69},
      'Guanajuato': {'lat': 21.02, 'lng': -101.26},
      'Guerrero': {'lat': 17.44, 'lng': -99.55},
      'Hidalgo': {'lat': 20.09, 'lng': -98.76},
      'Jalisco': {'lat': 20.66, 'lng': -103.35},
      'Michoacán': {'lat': 19.57, 'lng': -101.90},
      'Morelos': {'lat': 18.68, 'lng': -99.10},
      'Nayarit': {'lat': 21.75, 'lng': -104.85},
      'Nuevo León': {'lat': 25.67, 'lng': -100.31},
      'Oaxaca': {'lat': 17.07, 'lng': -96.72},
      'Puebla': {'lat': 19.04, 'lng': -98.20},
      'Querétaro': {'lat': 20.59, 'lng': -100.39},
      'Quintana Roo': {'lat': 19.18, 'lng': -88.08},
      'San Luis Potosí': {'lat': 22.15, 'lng': -100.98},
      'Sinaloa': {'lat': 24.81, 'lng': -107.39},
      'Sonora': {'lat': 29.07, 'lng': -110.96},
      'Tabasco': {'lat': 17.99, 'lng': -92.93},
      'Tamaulipas': {'lat': 24.27, 'lng': -98.84},
      'Tlaxcala': {'lat': 19.32, 'lng': -98.24},
      'Veracruz': {'lat': 19.17, 'lng': -96.14},
      'Yucatán': {'lat': 20.97, 'lng': -89.62},
      'Zacatecas': {'lat': 22.77, 'lng': -102.58},
    };

    String estadoCercano = 'Desconocido';
    double distanciaMinima = double.infinity;

    estadosCoordenadas.forEach((estado, coords) {
      final distancia = Geolocator.distanceBetween(
        lat, lng,
        coords['lat']!, coords['lng']!,
      );
      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        estadoCercano = estado;
      }
    });

    return estadoCercano;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Contenido
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: guinda),
                    SizedBox(height: 16),
                    Text(
                      'Detectando tu ubicación...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: _buildErrorView(),
            )
          else if (_noPolosEnEstado)
            SliverFillRemaining(
              child: _buildNoPolosView(),
            )
          else ...[
            // Mensaje de bienvenida
            SliverToBoxAdapter(
              child: _buildWelcomeMessage(),
            ),
            
            // Lista de polos
            SliverToBoxAdapter(
              child: _buildPolosSection(),
            ),
            
            // Espacio final
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: guinda,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi Región',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Oportunidades cerca de ti',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _detectarUbicacion,
                      tooltip: 'Actualizar ubicación',
                    ),
                ],
              ),
              if (_estadoDetectado.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: dorado,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _regionDetectada.isNotEmpty 
                            ? '$_estadoDetectado • $_regionDetectada'
                            : _estadoDetectado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: guinda.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off,
                size: 48,
                color: guinda,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _detectarUbicacion,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: guinda,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista cuando no hay polos en el estado del usuario
  Widget _buildNoPolosView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asistente con globo de pensamiento
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Imagen del asistente (ajolote)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: guinda.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ajolotito.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.smart_toy,
                          size: 60,
                          color: guinda,
                        );
                      },
                    ),
                  ),
                ),
                
                // Globo de pensamiento
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: const Text(
                      'Lo sentimos, no hay polos establecidos en tu estado. Esperamos actualizaciones oficiales.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Burbujas de pensamiento
                Positioned(
                  top: -15,
                  right: 5,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -30,
                  right: 15,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 100),
            
            // Estado detectado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: guinda, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tu ubicación: $_estadoDetectado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Información adicional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: verde.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: verde.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: verde, size: 28),
                  const SizedBox(height: 12),
                  const Text(
                    'El Plan México continúa expandiéndose',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pronto habrá más polos de desarrollo en todo el país. Mantente informado sobre las actualizaciones.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              verde.withOpacity(0.1),
              dorado.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: verde.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: verde, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'El desarrollo de México comienza en tu comunidad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Encontramos ${_polosEnMiRegion.length} polo${_polosEnMiRegion.length == 1 ? '' : 's'} de desarrollo en $_estadoDetectado que pueden generar oportunidades para ti y tu familia.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: dorado, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estos proyectos representan inversiones que impulsarán el empleo y la economía de tu estado.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: guinda,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Polos de desarrollo en tu estado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _polosEnMiRegion.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildPoloCard(_polosEnMiRegion[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPoloCard(PoloMarker polo) {
    // Calcular distancia si tenemos ubicación
    String distanciaTexto = '';
    if (_currentPosition != null) {
      final distanciaMetros = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        polo.lat,
        polo.lng,
      );
      if (distanciaMetros < 1000) {
        distanciaTexto = '${distanciaMetros.round()} m';
      } else {
        distanciaTexto = '${(distanciaMetros / 1000).toStringAsFixed(0)} km';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del polo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: polo.color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: polo.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForTipo(polo.tipo),
                    color: polo.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        polo.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            polo.estado,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (distanciaTexto.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: dorado.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                distanciaTexto,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: dorado.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vocación
                Text(
                  polo.vocacion,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: guinda,
                  ),
                ),
                const SizedBox(height: 12),

                // Beneficios para el usuario
                _buildBenefitItem(
                  Icons.work_outline,
                  'Empleo estimado',
                  polo.empleoEstimado.isNotEmpty 
                      ? polo.empleoEstimado 
                      : 'Generación de empleos en la región',
                ),
                const SizedBox(height: 8),
                _buildBenefitItem(
                  Icons.trending_up,
                  'Beneficio a largo plazo',
                  polo.beneficiosLargoPlazo.isNotEmpty 
                      ? polo.beneficiosLargoPlazo 
                      : 'Desarrollo económico regional',
                ),

                // Sectores clave
                if (polo.sectoresClave.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: polo.sectoresClave.take(3).map((sector) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sector,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: verde),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'energy':
        return Icons.bolt;
      case 'logistics':
        return Icons.local_shipping;
      case 'tourism':
        return Icons.beach_access;
      case 'industry':
      default:
        return Icons.factory;
    }
  }
}
