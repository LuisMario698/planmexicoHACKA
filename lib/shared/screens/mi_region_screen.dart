import 'package:flutter/material.dart';
import '../data/polos_data.dart';
import 'encuesta_polo_screen.dart';
import '../../service/encuesta_service.dart';

class MiRegionScreen extends StatefulWidget {
  const MiRegionScreen({super.key});

  @override
  State<MiRegionScreen> createState() => _MiRegionScreenState();
}

class _MiRegionScreenState extends State<MiRegionScreen> {
  static const Color guinda = Color(0xFF691C32);
  static const Color dorado = Color(0xFFBC955C);
  static const Color verde = Color(0xFF006847);

  static const List<String> _estadosMexico = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche',
    'Chiapas', 'Chihuahua', 'Ciudad de México', 'Coahuila', 'Colima',
    'Durango', 'Estado de México', 'Guanajuato', 'Guerrero', 'Hidalgo',
    'Jalisco', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca',
    'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa',
    'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán',
    'Zacatecas',
  ];

  static const Map<String, Map<String, String>> _estadosInfo = {
    'Aguascalientes': {
      'descripcion': 'Los polos generan miles de empleos bien pagados en manufactura y automotriz. Tendrás acceso a capacitación técnica especializada y oportunidades de crecimiento profesional sin salir de tu estado.',
      'ventajas': '✓ Empleos técnicos especializados\n✓ Capacitación gratuita\n✓ Mejores salarios regionales',
      'icono': 'engineering',
    },
    'Baja California': {
      'descripcion': 'La industria aeroespacial y tecnológica trae empleos de alta calificación. Tu familia tendrá acceso a mejores servicios, escuelas técnicas y oportunidades que antes solo existían en el extranjero.',
      'ventajas': '✓ Empleos en tecnología de punta\n✓ Inversión en infraestructura\n✓ Conexión con mercados internacionales',
      'icono': 'rocket',
    },
    'Baja California Sur': {
      'descripcion': 'El turismo sustentable genera empleos dignos todo el año. Habrá más inversión en servicios públicos, carreteras y hospitales que benefician a toda tu comunidad.',
      'ventajas': '✓ Empleos turísticos permanentes\n✓ Protección del medio ambiente\n✓ Mejora en servicios públicos',
      'icono': 'beach',
    },
    'Campeche': {
      'descripcion': 'La transición energética crea nuevos empleos técnicos bien remunerados. Tu estado recibirá inversión en educación, salud e infraestructura que beneficiará a tu familia.',
      'ventajas': '✓ Empleos en energías limpias\n✓ Inversión federal directa\n✓ Desarrollo de nuevas industrias',
      'icono': 'energy',
    },
    'Chiapas': {
      'descripcion': 'Los polos impulsan agroindustria y ecoturismo, generando empleos locales. Tu comunidad tendrá acceso a programas de desarrollo, créditos y capacitación para emprendedores.',
      'ventajas': '✓ Empleos agroindustriales\n✓ Apoyo a emprendedores locales\n✓ Preservación de cultura y tradiciones',
      'icono': 'nature',
    },
    'Chihuahua': {
      'descripcion': 'La manufactura avanzada ofrece empleos estables con prestaciones completas. Habrá más escuelas técnicas, hospitales y servicios que mejorarán la calidad de vida de tu familia.',
      'ventajas': '✓ Empleos manufactureros estables\n✓ Prestaciones superiores a la ley\n✓ Crecimiento de ciudades intermedias',
      'icono': 'factory',
    },
    'Ciudad de México': {
      'descripcion': 'Los polos de innovación generan empleos creativos y tecnológicos. Tendrás acceso a incubadoras, fondos de inversión y redes de contacto para impulsar tus proyectos.',
      'ventajas': '✓ Empleos en startups e innovación\n✓ Acceso a capital de inversión\n✓ Ecosistema emprendedor robusto',
      'icono': 'city',
    },
    'Coahuila': {
      'descripcion': 'La industria siderúrgica y automotriz ofrece los mejores salarios de la región. Tu familia tendrá seguridad laboral y acceso a vivienda, educación y salud de calidad.',
      'ventajas': '✓ Salarios competitivos a nivel nacional\n✓ Seguridad laboral\n✓ Programas de vivienda para trabajadores',
      'icono': 'construction',
    },
    'Colima': {
      'descripcion': 'El puerto y la logística generan empleos en comercio internacional. Tu estado será hub de exportaciones, atrayendo inversión y mejorando la economía local.',
      'ventajas': '✓ Empleos en logística y comercio\n✓ Mayor movimiento económico\n✓ Conexión con mercados del Pacífico',
      'icono': 'ship',
    },
    'Durango': {
      'descripcion': 'Los polos forestales y agroindustriales crean empleos sustentables. Tu comunidad recibirá apoyo para proyectos productivos que respetan el medio ambiente.',
      'ventajas': '✓ Empleos sustentables\n✓ Apoyo a productores locales\n✓ Desarrollo rural integral',
      'icono': 'forest',
    },
    'Estado de México': {
      'descripcion': 'La diversificación industrial genera miles de empleos cerca de tu hogar. Ya no tendrás que trasladarte horas para trabajar; las oportunidades llegarán a tu municipio.',
      'ventajas': '✓ Empleos cercanos a tu comunidad\n✓ Reducción de tiempos de traslado\n✓ Desarrollo de zonas metropolitanas',
      'icono': 'diversity',
    },
    'Guanajuato': {
      'descripcion': 'La industria automotriz ofrece empleos técnicos con salarios superiores al promedio. Habrá más universidades técnicas y programas de becas para jóvenes de tu estado.',
      'ventajas': '✓ Empleos automotrices de alta calidad\n✓ Becas y capacitación técnica\n✓ Inversión extranjera directa',
      'icono': 'auto',
    },
    'Guerrero': {
      'descripcion': 'El turismo sustentable genera empleos todo el año, no solo en temporada alta. Tu familia tendrá ingresos estables y acceso a programas de desarrollo comunitario.',
      'ventajas': '✓ Empleos turísticos permanentes\n✓ Desarrollo de comunidades costeras\n✓ Inversión en seguridad y servicios',
      'icono': 'sun',
    },
    'Hidalgo': {
      'descripcion': 'Los nuevos corredores industriales traen empleos y mejor infraestructura. Tu estado dejará de ser paso obligado para convertirse en destino de inversión.',
      'ventajas': '✓ Nuevos parques industriales\n✓ Mejora en carreteras y transporte\n✓ Empleos para jóvenes egresados',
      'icono': 'transform',
    },
    'Jalisco': {
      'descripcion': 'El polo tecnológico genera empleos creativos y digitales muy bien pagados. Tendrás acceso a incubadoras, aceleradoras y fondos para lanzar tu emprendimiento.',
      'ventajas': '✓ Empleos en tecnología e innovación\n✓ Apoyo a startups\n✓ Salarios competitivos internacionalmente',
      'icono': 'tech',
    },
    'Michoacán': {
      'descripcion': 'La agroindustria del aguacate y berries genera empleos bien pagados. Los productores locales tendrán acceso a mercados internacionales y mejores precios.',
      'ventajas': '✓ Empleos agroindustriales dignos\n✓ Acceso a mercados de exportación\n✓ Apoyo a pequeños productores',
      'icono': 'agriculture',
    },
    'Morelos': {
      'descripcion': 'Los centros de investigación generan empleos científicos de alto nivel. Tu estado será referente en biotecnología, farmacéutica e innovación.',
      'ventajas': '✓ Empleos de investigación científica\n✓ Desarrollo de patentes mexicanas\n✓ Vinculación universidad-industria',
      'icono': 'science',
    },
    'Nayarit': {
      'descripcion': 'El turismo y la agroindustria generan empleos estables. Tu comunidad recibirá inversión en infraestructura, caminos y servicios de salud.',
      'ventajas': '✓ Empleos turísticos y agrícolas\n✓ Desarrollo de la Riviera Nayarit\n✓ Inversión en comunidades rurales',
      'icono': 'palm',
    },
    'Nuevo León': {
      'descripcion': 'Los polos de innovación y manufactura avanzada ofrecen los mejores empleos del país. Tu talento será valorado con salarios competitivos y desarrollo profesional.',
      'ventajas': '✓ Los mejores salarios del país\n✓ Ecosistema de innovación maduro\n✓ Oportunidades de crecimiento profesional',
      'icono': 'business',
    },
    'Oaxaca': {
      'descripcion': 'Los polos de artesanías y turismo cultural generan ingresos dignos para comunidades. Tu cultura y tradiciones serán fuente de prosperidad, no solo de identidad.',
      'ventajas': '✓ Comercialización justa de artesanías\n✓ Turismo comunitario\n✓ Preservación cultural con beneficio económico',
      'icono': 'culture',
    },
    'Puebla': {
      'descripcion': 'La industria automotriz y textil ofrece empleos con prestaciones superiores. Habrá más opciones de educación técnica y universitaria para tus hijos.',
      'ventajas': '✓ Empleos industriales estables\n✓ Programas de educación técnica\n✓ Proveeduría para grandes empresas',
      'icono': 'car',
    },
    'Querétaro': {
      'descripcion': 'La industria aeroespacial genera los empleos mejor pagados del centro del país. Técnicos e ingenieros locales trabajan en proyectos de clase mundial.',
      'ventajas': '✓ Empleos aeroespaciales de élite\n✓ Formación técnica especializada\n✓ Proyectos de tecnología espacial',
      'icono': 'aerospace',
    },
    'Quintana Roo': {
      'descripcion': 'El turismo diversificado genera empleos todo el año, no solo en temporada alta. Tu familia tendrá estabilidad laboral y acceso a mejores servicios.',
      'ventajas': '✓ Empleos turísticos permanentes\n✓ Desarrollo de turismo alternativo\n✓ Inversión en infraestructura',
      'icono': 'tourism',
    },
    'San Luis Potosí': {
      'descripcion': 'Tu ubicación estratégica atrae empresas de logística y manufactura. Tendrás empleos cerca de casa con salarios competitivos y crecimiento profesional.',
      'ventajas': '✓ Hub logístico nacional\n✓ Empleos en manufactura avanzada\n✓ Conexión con todo el país',
      'icono': 'logistics',
    },
    'Sinaloa': {
      'descripcion': 'La agroindustria moderna genera empleos técnicos bien remunerados. Los productores locales accederán a tecnología, créditos y mercados internacionales.',
      'ventajas': '✓ Empleos agroindustriales tecnificados\n✓ Acceso a mercados de exportación\n✓ Créditos para productores',
      'icono': 'farming',
    },
    'Sonora': {
      'descripcion': 'La minería sustentable y manufactura ofrecen empleos con los mejores salarios del noroeste. Tu familia tendrá seguridad económica y oportunidades de crecimiento.',
      'ventajas': '✓ Salarios mineros competitivos\n✓ Manufactura de alta tecnología\n✓ Desarrollo de energía solar',
      'icono': 'mining',
    },
    'Tabasco': {
      'descripcion': 'La refinería y petroquímica generan miles de empleos directos e indirectos. Tu estado será centro de la transformación energética con inversión federal histórica.',
      'ventajas': '✓ Miles de empleos industriales\n✓ Inversión federal récord\n✓ Desarrollo de proveedores locales',
      'icono': 'oil',
    },
    'Tamaulipas': {
      'descripcion': 'La manufactura y comercio fronterizo generan empleos bien pagados. Tu familia tendrá acceso a oportunidades sin necesidad de emigrar.',
      'ventajas': '✓ Empleos fronterizos competitivos\n✓ Comercio internacional\n✓ Inversión en seguridad',
      'icono': 'bridge',
    },
    'Tlaxcala': {
      'descripcion': 'Los parques industriales generan empleos cerca de tu comunidad. Ya no tendrás que viajar a Puebla o CDMX; las oportunidades llegarán a tu estado.',
      'ventajas': '✓ Empleos locales bien pagados\n✓ Desarrollo de parques industriales\n✓ Reducción de migración laboral',
      'icono': 'textile',
    },
    'Veracruz': {
      'descripcion': 'El puerto y la agroindustria generan miles de empleos. Tu estado será puerta de entrada al comercio internacional con inversión en logística y servicios.',
      'ventajas': '✓ Empleos portuarios y logísticos\n✓ Agroindustria de exportación\n✓ Desarrollo de ciudades costeras',
      'icono': 'port',
    },
    'Yucatán': {
      'descripcion': 'El polo de tecnología y turismo genera empleos de calidad para jóvenes. Tu estado combina tradición maya con innovación, creando oportunidades únicas.',
      'ventajas': '✓ Empleos tecnológicos y creativos\n✓ Turismo cultural sustentable\n✓ Calidad de vida excepcional',
      'icono': 'pyramid',
    },
    'Zacatecas': {
      'descripcion': 'La minería moderna y agroindustria generan empleos con buenos salarios. Tu estado recibirá inversión para diversificar la economía y crear más oportunidades.',
      'ventajas': '✓ Empleos mineros bien pagados\n✓ Desarrollo agroindustrial\n✓ Inversión en turismo cultural',
      'icono': 'gem',
    },
  };

  String? _estadoSeleccionado;
  List<PoloMarker> _polosEnMiRegion = [];

  void _buscarPolosEnEstado(String estado) {
    final polosEstado = PolosData.polos.where((p) => p.estado == estado).toList();
    setState(() {
      _estadoSeleccionado = estado;
      _polosEnMiRegion = polosEstado;
    });
  }

  IconData _getIconForEstado(String estado) {
    final info = _estadosInfo[estado];
    switch (info?['icono']) {
      case 'engineering': return Icons.engineering;
      case 'rocket': return Icons.rocket_launch;
      case 'beach': return Icons.beach_access;
      case 'energy': return Icons.bolt;
      case 'nature': return Icons.park;
      case 'factory': return Icons.factory;
      case 'city': return Icons.location_city;
      case 'construction': return Icons.construction;
      case 'ship': return Icons.directions_boat;
      case 'forest': return Icons.forest;
      case 'diversity': return Icons.diversity_3;
      case 'auto': return Icons.directions_car;
      case 'sun': return Icons.wb_sunny;
      case 'transform': return Icons.transform;
      case 'tech': return Icons.computer;
      case 'agriculture': return Icons.agriculture;
      case 'science': return Icons.science;
      case 'palm': return Icons.spa;
      case 'business': return Icons.business;
      case 'culture': return Icons.museum;
      case 'car': return Icons.precision_manufacturing;
      case 'aerospace': return Icons.flight;
      case 'tourism': return Icons.luggage;
      case 'logistics': return Icons.local_shipping;
      case 'farming': return Icons.grass;
      case 'mining': return Icons.diamond;
      case 'oil': return Icons.oil_barrel;
      case 'bridge': return Icons.swap_horiz;
      case 'textile': return Icons.checkroom;
      case 'port': return Icons.anchor;
      case 'pyramid': return Icons.architecture;
      case 'gem': return Icons.auto_awesome;
      default: return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header guinda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [guinda, Color(0xFF4A1525)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mi Región', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Polos de desarrollo en tu estado', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Dropdown selector
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selecciona tu estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _estadoSeleccionado,
                              hint: Text('Elige un estado...', style: TextStyle(color: subtextColor)),
                              isExpanded: true,
                              dropdownColor: cardColor,
                              icon: const Icon(Icons.keyboard_arrow_down, color: guinda),
                              style: TextStyle(color: textColor, fontSize: 16),
                              items: _estadosMexico.map((estado) {
                                final cantidadPolos = PolosData.polos.where((p) => p.estado == estado).length;
                                return DropdownMenuItem(
                                  value: estado,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(estado, style: TextStyle(color: textColor)),
                                      if (cantidadPolos > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: verde.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                          child: Text('$cantidadPolos polo${cantidadPolos > 1 ? 's' : ''}', style: TextStyle(fontSize: 11, color: verde, fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) _buscarPolosEnEstado(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card de descripción del estado
                  if (_estadoSeleccionado != null) _buildEstadoDescripcion(isDark, cardColor, textColor, subtextColor),

                  // Contenido según selección
                  if (_estadoSeleccionado == null)
                    _buildInitialView(isDark, textColor, subtextColor)
                  else if (_polosEnMiRegion.isEmpty)
                    _buildNoPolosView(isDark, textColor, subtextColor)
                  else
                    _buildPolosList(isDark, cardColor, textColor, subtextColor, borderColor),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoDescripcion(bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    final info = _estadosInfo[_estadoSeleccionado];
    if (info == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [verde.withOpacity(0.15), dorado.withOpacity(0.08)]
              : [verde.withOpacity(0.1), dorado.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: verde.withOpacity(isDark ? 0.3 : 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: guinda.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForEstado(_estadoSeleccionado!), color: isDark ? Colors.white : guinda, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _estadoSeleccionado!,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : guinda),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _polosEnMiRegion.isEmpty 
                          ? 'Próximamente polos de desarrollo'
                          : '${_polosEnMiRegion.length} polo${_polosEnMiRegion.length != 1 ? 's' : ''} de desarrollo',
                        style: TextStyle(fontSize: 13, color: _polosEnMiRegion.isEmpty ? dorado : subtextColor, fontWeight: _polosEnMiRegion.isEmpty ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Descripción principal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: dorado, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info['descripcion']!,
                      style: TextStyle(fontSize: 15, color: textColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            // Ventajas específicas
            if (info['ventajas'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: verde.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: verde.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: verde, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ventajas para ti y tu familia',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: verde),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...info['ventajas']!.split('\n').map((ventaja) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(ventaja, style: TextStyle(fontSize: 14, color: textColor, height: 1.4)),
                    )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: guinda.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: isDark ? Colors.red.shade300 : guinda, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Tú eres prioridad! El Plan México trabaja para que las oportunidades lleguen a tu comunidad.',
                      style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
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

  Widget _buildInitialView(bool isDark, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: guinda.withOpacity(isDark ? 0.2 : 0.1), shape: BoxShape.circle),
            child: Icon(Icons.map_outlined, size: 50, color: isDark ? Colors.white70 : guinda.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('Descubre los polos de desarrollo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('Selecciona tu estado para ver los polos disponibles en tu región y descubrir cómo el Plan México impulsa tu comunidad.', style: TextStyle(fontSize: 15, color: subtextColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNoPolosView(bool isDark, Color textColor, Color subtextColor) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: guinda.withOpacity(isDark ? 0.2 : 0.1), shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/ajolotito.png', fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.smart_toy, size: 50, color: isDark ? Colors.white70 : guinda.withOpacity(0.6)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dorado.withOpacity(isDark ? 0.15 : 0.1), 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: dorado.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: dorado, size: 28),
                const SizedBox(height: 12),
                Text('Aún no hay polos de desarrollo establecidos en tu estado.', style: TextStyle(fontSize: 15, color: textColor), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('El Plan México continúa expandiéndose. Tu estado es importante y pronto habrá oportunidades cerca de ti.', style: TextStyle(fontSize: 14, color: subtextColor), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolosList(bool isDark, Color cardColor, Color textColor, Color subtextColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(color: guinda, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              Text('Polos disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_polosEnMiRegion.length, (index) {
            final polo = _polosEnMiRegion[index];
            return GestureDetector(
              onTap: () => _mostrarDetallePolo(context, polo),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [guinda, Color(0xFF8B2346)]), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text('${polo.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(polo.nombre, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text(polo.region, style: TextStyle(fontSize: 13, color: subtextColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (polo.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(polo.descripcion, style: TextStyle(fontSize: 13, color: subtextColor, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: verde.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, size: 14, color: verde),
                              const SizedBox(width: 4),
                              Text(polo.estado, style: TextStyle(fontSize: 12, color: verde, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: guinda.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Ver más', style: TextStyle(fontSize: 12, color: guinda, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 12, color: guinda),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _mostrarDetallePolo(BuildContext context, PoloMarker polo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Indicador de arrastre
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header con nombre y botón cerrar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [guinda, Color(0xFF8B2346)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${polo.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            polo.nombre,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${polo.estado} • ${polo.region}',
                            style: TextStyle(fontSize: 13, color: subtextColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: subtextColor),
                    ),
                  ],
                ),
              ),
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildModalTag(
                            polo.tipoDisplay == 'nuevo' ? 'Nuevo Polo' : polo.tipoDisplay == 'en_marcha' ? 'En Marcha' : 'Estratégico',
                            polo.tipoDisplay == 'nuevo' ? guinda : polo.tipoDisplay == 'en_marcha' ? verde : dorado,
                            isDark,
                          ),
                          if (polo.areaHa.isNotEmpty)
                            _buildModalTag(polo.areaHa, verde, isDark),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Vocación
                      if (polo.vocacion.isNotEmpty)
                        _buildModalInfoCard(
                          icon: Icons.lightbulb,
                          iconColor: dorado,
                          title: 'Vocación',
                          content: polo.vocacion,
                          cardColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      // Sectores Clave
                      if (polo.sectoresClave.isNotEmpty)
                        _buildModalInfoCard(
                          icon: Icons.business,
                          iconColor: const Color(0xFF2563EB),
                          title: 'Sectores Clave',
                          content: polo.sectoresClave.join(', '),
                          cardColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      // Infraestructura
                      if (polo.infraestructura.isNotEmpty)
                        _buildModalInfoCard(
                          icon: Icons.construction,
                          iconColor: Colors.orange,
                          title: 'Infraestructura',
                          content: polo.infraestructura,
                          cardColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      // Empleo Estimado
                      if (polo.empleoEstimado.isNotEmpty)
                        _buildModalInfoCard(
                          icon: Icons.groups,
                          iconColor: verde,
                          title: 'Empleo Estimado',
                          content: polo.empleoEstimado,
                          cardColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      // Beneficios a Largo Plazo
                      if (polo.beneficiosLargoPlazo.isNotEmpty)
                        _buildModalInfoCard(
                          icon: Icons.trending_up,
                          iconColor: Colors.purple,
                          title: 'Beneficios',
                          content: polo.beneficiosLargoPlazo,
                          cardColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Botones de acción FIJOS en la parte inferior
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(top: BorderSide(color: borderColor)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModalActionButton(
                        icon: Icons.explore,
                        label: 'Explorar',
                        color: guinda,
                        onTap: () {
                          Navigator.pop(context);
                          _openPoloLocation(polo);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModalActionButton(
                        icon: Icons.rate_review,
                        label: 'Opinar',
                        color: dorado,
                        onTap: () {
                          Navigator.pop(context);
                          _showEncuestaDialog(polo);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildModalInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: subtextColor)),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPoloLocation(PoloMarker polo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.explore, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Explorando: ${polo.nombre}')),
          ],
        ),
        backgroundColor: guinda,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEncuestaDialog(PoloMarker polo) {
    final poloData = PolosData.getPoloByStringId(polo.idString);
    int poloId = poloData?.id ?? PolosDatabase.findPoloIdByName(polo.nombre, polo.estado) ?? 1;

    EncuestaPoloScreen.show(
      context,
      poloId: poloId,
      poloNombre: polo.nombre,
      poloEstado: polo.estado,
      poloDescripcion: poloData?.descripcion ?? polo.descripcion,
      onEncuestaEnviada: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('¡Opinión registrada con éxito!'),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }
}


