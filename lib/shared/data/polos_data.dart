import 'package:flutter/material.dart';

/// Modelo de datos para un polo de desarrollo
class PoloMarker {
  final int id; // ID numérico del JSON
  final String idString; // ID string para compatibilidad
  final String nombre;
  final String estado;
  final String estadoCodigo;
  final double relativeX; // Posición relativa en mapa (0.0-1.0)
  final double relativeY; // Posición relativa en mapa (0.0-1.0)
  final double lat; // Latitud real
  final double lng; // Longitud real
  final String areaHa; // Área en hectáreas
  final Color color;
  final String tipo; // 'energy', 'logistics', 'industry', 'tourism'
  final String tipoDisplay; // Para mostrar: 'nuevo', 'en_marcha', 'estrategico'
  final String region; // Región geográfica
  final String vocacion; // Descripción corta / vocación principal
  final List<String> sectoresClave;
  final String infraestructura;
  final String descripcion;
  final String empleoEstimado;
  final String beneficiosLargoPlazo;

  const PoloMarker({
    required this.id,
    required this.idString,
    required this.nombre,
    required this.estado,
    required this.estadoCodigo,
    required this.relativeX,
    required this.relativeY,
    required this.lat,
    required this.lng,
    this.areaHa = '',
    this.color = const Color(0xFF2563EB),
    this.tipo = 'industry',
    this.tipoDisplay = 'nuevo',
    this.region = '',
    this.vocacion = '',
    this.sectoresClave = const [],
    this.infraestructura = '',
    this.descripcion = '',
    this.empleoEstimado = '',
    this.beneficiosLargoPlazo = '',
  });
}

/// Colores para los diferentes tipos de polos según categoría
class PoloColors {
  // Por tipo de industria
  static const Color energy = Color(0xFFF59E0B);     // Amarillo/Naranja - Energía
  static const Color logistics = Color(0xFF2563EB); // Azul - Logística
  static const Color industry = Color(0xFF16A34A);  // Verde - Industria
  static const Color tourism = Color(0xFF8B5CF6);   // Púrpura - Turismo
  
  // Por estado del proyecto
  static const Color nuevo = Color(0xFF2563EB);        // Azul
  static const Color enMarcha = Color(0xFF16A34A);     // Verde
  static const Color estrategico = Color(0xFFF59E0B); // Amarillo/Naranja
}

/// Lista de todos los polos de desarrollo del Plan México
/// Datos basados en el JSON oficial de nodos
class PolosData {
  static const List<PoloMarker> polos = [
    // ═══════════════════════════════════════════════════════════════
    // 🌵 REGIÓN NOROESTE
    // ═══════════════════════════════════════════════════════════════

    // ID 1: Sonora - Hermosillo
    PoloMarker(
      id: 1,
      idString: 'sonora_hermosillo',
      nombre: 'Golfo de California / Hermosillo',
      estado: 'Sonora',
      estadoCodigo: 'SO',
      relativeX: 0.65,
      relativeY: 0.45,
      lat: 29.072967,
      lng: -110.955919,
      areaHa: '555 ha',
      color: PoloColors.energy,
      tipo: 'energy',
      tipoDisplay: 'nuevo',
      region: 'Noroeste',
      vocacion: 'Hub de Electromovilidad y Semiconductores',
      sectoresClave: [
        'Automotriz (Ford)',
        'Minería (Litio)',
        'Semiconductores',
      ],
      infraestructura: 'Modernización Carretera Guaymas-Chihuahua y Aeropuerto',
      descripcion: '555 ha - Hub de electromovilidad aprovechando cercanía con Arizona Chip Hub',
      empleoEstimado: 'Est. 15,000+ empleos especializados (Ingeniería/Técnicos)',
      beneficiosLargoPlazo: 'Integración al "Arizona Chip Corridor" y nearshoring tecnológico',
    ),

    // ID 2: Sonora - Plan Sonora (Puerto Peñasco)
    PoloMarker(
      id: 2,
      idString: 'sonora_penasco',
      nombre: 'Plan Sonora (Puerto Peñasco)',
      estado: 'Sonora',
      estadoCodigo: 'SO',
      relativeX: 0.22,
      relativeY: 0.82,
      lat: 31.3268,
      lng: -113.5312,
      areaHa: 'Estratégico',
      color: PoloColors.energy,
      tipo: 'energy',
      tipoDisplay: 'estrategico',
      region: 'Noroeste',
      vocacion: 'Corazón Energético del Plan Nacional',
      sectoresClave: [
        'Energía Renovable',
        'Gas Natural Licuado (GNL)',
      ],
      infraestructura: 'Planta Solar (1GW), Línea de Transmisión a Baja California',
      descripcion: 'Corazón energético del Plan México - Gateway energético principal',
      empleoEstimado: 'Est. 2,500 directos en operación + Construcción masiva',
      beneficiosLargoPlazo: 'Soberanía energética y exportación de energía limpia a EE.UU.',
    ),

    // ID 11: Chihuahua - Norte Multinodal
    PoloMarker(
      id: 11,
      idString: 'chihuahua_norte',
      nombre: 'Norte (Región Multinodal)',
      estado: 'Chihuahua',
      estadoCodigo: 'CH',
      relativeX: 0.47,
      relativeY: 0.85,
      lat: 31.6904,
      lng: -106.4245,
      areaHa: 'Cadena',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'nuevo',
      region: 'Noroeste',
      vocacion: 'Manufactura de Exportación',
      sectoresClave: [
        'Aeroespacial',
        'Dispositivos Médicos',
        'Electrónica',
      ],
      infraestructura: 'Modernización cruces fronterizos y libramientos',
      descripcion: 'Manufactura avanzada para exportación',
      empleoEstimado: 'Est. 40,000 empleos en maquila avanzada',
      beneficiosLargoPlazo: 'Consolidación de la cadena de suministro "Just-in-Time"',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 🤠 REGIÓN NORESTE
    // ═══════════════════════════════════════════════════════════════

    // ID 3: Tamaulipas - Nuevo Laredo
    PoloMarker(
      id: 3,
      idString: 'tamaulipas_nuevo_laredo',
      nombre: 'Nuevo Laredo',
      estado: 'Tamaulipas',
      estadoCodigo: 'TM',
      relativeX: 0.15,
      relativeY: 0.97,
      lat: 27.4806,
      lng: -99.5083,
      areaHa: '300 ha',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'nuevo',
      region: 'Noreste',
      vocacion: 'Aduana Terrestre #1 de América',
      sectoresClave: [
        'Logística 4.0',
        'Comercio Exterior',
        'Almacenamiento',
      ],
      infraestructura: 'Expansión Puente Comercio Mundial, Recinto Fiscalizado',
      descripcion: '300 ha - Puerto terrestre más importante de América',
      empleoEstimado: 'Est. 12,000 directos en logística y aduanas',
      beneficiosLargoPlazo: 'Agilización de cruces fronterizos y reducción de costos logísticos',
    ),

    // ID 4: Tamaulipas - Puerto Seco / Golfo (Altamira)
    PoloMarker(
      id: 4,
      idString: 'tamaulipas_altamira',
      nombre: 'Puerto Seco / Golfo',
      estado: 'Tamaulipas',
      estadoCodigo: 'TM',
      relativeX: 0.80,
      relativeY: 0.02,
      lat: 22.2618,
      lng: -97.8636,
      areaHa: '935 ha',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'nuevo',
      region: 'Noreste',
      vocacion: 'Conectividad marítima Europa/Costa Este',
      sectoresClave: [
        'Petroquímica',
        'Plásticos',
        'Componentes Eólicos',
      ],
      infraestructura: 'Dragado Puerto Altamira, nuevas terminales de fluidos',
      descripcion: '935 ha - Puerta al Golfo de México',
      empleoEstimado: 'Est. 8,000 empleos en sector petroquímico y portuario',
      beneficiosLargoPlazo: 'Consolidación del corredor petroquímico más importante del país',
    ),

    // ID 8: Coahuila - AHMSA
    PoloMarker(
      id: 8,
      idString: 'coahuila_ahmsa',
      nombre: 'Norte – AHMSA',
      estado: 'Coahuila',
      estadoCodigo: 'CO',
      relativeX: 0.58,
      relativeY: 0.43,
      lat: 26.8997,
      lng: -101.4181,
      areaHa: '740 ha',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'nuevo',
      region: 'Noreste',
      vocacion: 'Acero para la Industria Nacional',
      sectoresClave: [
        'Siderurgia',
        'Metalmecánica',
        'Vagones de tren',
      ],
      infraestructura: 'Modernización de hornos y logística ferroviaria',
      descripcion: '740 ha - Centro de producción de acero especializado',
      empleoEstimado: 'Recuperación de 15,000 empleos siderúrgicos',
      beneficiosLargoPlazo: 'Insumos base para la industria de la construcción y automotriz',
    ),

    // ID 9: Coahuila - Piedras Negras
    PoloMarker(
      id: 9,
      idString: 'coahuila_piedras_negras',
      nombre: 'Piedras Negras',
      estado: 'Coahuila',
      estadoCodigo: 'CO',
      relativeX: 0.80,
      relativeY: 0.80,
      lat: 28.7001,
      lng: -100.5235,
      areaHa: '300 ha',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'nuevo',
      region: 'Noreste',
      vocacion: 'Cruce Ferroviario Estratégico',
      sectoresClave: [
        'Autopartes (Seguridad)',
        'Logística Ferroviaria',
      ],
      infraestructura: 'Patio ferroviario binacional expandido',
      descripcion: '300 ha - Nodo de manufactura automotriz y logística ferroviaria',
      empleoEstimado: 'Est. 7,000 empleos en manufactura de autopartes',
      beneficiosLargoPlazo: 'Alternativa eficiente al cruce de Laredo para carga pesada',
    ),

    // ID 10: Nuevo León - Colombia / Frontera
    PoloMarker(
      id: 10,
      idString: 'nuevo_leon_colombia',
      nombre: 'Colombia / Frontera',
      estado: 'Nuevo León',
      estadoCodigo: 'NL',
      relativeX: 0.38,
      relativeY: 0.80,
      lat: 25.6866,
      lng: -100.3161,
      areaHa: 'Multinodal',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'estrategico',
      region: 'Noreste',
      vocacion: 'Hub de Nearshoring Tecnológico',
      sectoresClave: [
        'Electromovilidad (Tesla ecosystem)',
        'Inteligencia Artificial',
        'Baterías',
      ],
      infraestructura: 'Carretera La Gloria-Colombia, Aduana Colombia',
      descripcion: 'Hub tecnológico y de electromovilidad - Gateway al nearshoring',
      empleoEstimado: 'Est. 50,000+ empleos alta tecnología (Largo Plazo)',
      beneficiosLargoPlazo: 'Creación del hub de manufactura avanzada más grande de LatAm',
    ),

    // ═══════════════════════════════════════════════════════════════
    // ⚙️ REGIÓN CENTRO Y BAJÍO
    // ═══════════════════════════════════════════════════════════════

    // ID 12: Guanajuato - Bajío (Celaya)
    PoloMarker(
      id: 12,
      idString: 'guanajuato_bajio',
      nombre: 'Bajío (Celaya)',
      estado: 'Guanajuato',
      estadoCodigo: 'GJ',
      relativeX: 0.55,
      relativeY: 0.35,
      lat: 20.5298,
      lng: -100.8167,
      areaHa: '52 ha',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'nuevo',
      region: 'Centro-Bajío',
      vocacion: 'Puerto Seco del Bajío',
      sectoresClave: [
        'Automotriz',
        'Logística Intermodal',
        'Granos',
      ],
      infraestructura: 'Ferroférico de Celaya (Conexión KCSM/Ferromex)',
      descripcion: '52 ha - Nodo logístico ferroviario estratégico',
      empleoEstimado: 'Est. 6,000 empleos logísticos y ensamble',
      beneficiosLargoPlazo: 'Optimización del flujo de mercancías del centro al norte',
    ),

    // ID 5: Puebla - Centro
    PoloMarker(
      id: 5,
      idString: 'puebla_centro',
      nombre: 'Centro',
      estado: 'Puebla',
      estadoCodigo: 'PU',
      relativeX: 0.34,
      relativeY: 0.37,
      lat: 19.0414,
      lng: -98.2063,
      areaHa: '462 ha',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'nuevo',
      region: 'Centro-Bajío',
      vocacion: 'Transición a Electromovilidad (VW/Audi)',
      sectoresClave: [
        'Automotriz Eléctrica',
        'Textil Técnico',
        'Agroindustria',
      ],
      infraestructura: 'Conexión ferroviaria y Ciudad Modelo',
      descripcion: '462 ha - Capital de la Tecnología y la Sostenibilidad',
      empleoEstimado: 'Est. 20,000 empleos en reconversión industrial',
      beneficiosLargoPlazo: 'Modernización de la fuerza laboral automotriz del centro',
    ),

    // ID 6: Durango - Capital
    PoloMarker(
      id: 6,
      idString: 'durango_capital',
      nombre: 'Durango Capital',
      estado: 'Durango',
      estadoCodigo: 'DG',
      relativeX: 0.45,
      relativeY: 0.55,
      lat: 24.0277,
      lng: -104.6532,
      areaHa: '470 ha',
      color: PoloColors.industry,
      tipo: 'industry',
      tipoDisplay: 'nuevo',
      region: 'Centro-Bajío',
      vocacion: 'Minería y Valor Agregado',
      sectoresClave: [
        'Metalmecánica',
        'Minería',
        'Mueblera',
      ],
      infraestructura: 'Ferrocarril Durango-Mazatlán (Proyecto)',
      descripcion: '470 ha - Centro de minería y manufactura pesada',
      empleoEstimado: 'Est. 5,000 directos en manufactura pesada',
      beneficiosLargoPlazo: 'Desarrollo de proveedores locales para industria pesada',
    ),

    // ID 13: Edomex - AIFA
    PoloMarker(
      id: 13,
      idString: 'edomex_aifa',
      nombre: 'AIFA (Corredor)',
      estado: 'Estado de México',
      estadoCodigo: 'MX',
      relativeX: 0.82,
      relativeY: 0.72,
      lat: 19.7447,
      lng: -99.0172,
      areaHa: '300 ha',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'en_marcha',
      region: 'Centro-Bajío',
      vocacion: 'Hub de Carga Aérea Central',
      sectoresClave: [
        'Logística Farmacéutica',
        'E-commerce',
        'Aeroespacial',
      ],
      infraestructura: 'Terminal de Carga AIFA, Tren Suburbano',
      descripcion: '300 ha - Hub logístico aéreo principal',
      empleoEstimado: 'Est. 100,000 empleos (Directos/Indirectos zona AIFA)',
      beneficiosLargoPlazo: 'Descongestión del AICM y polo logístico metropolitano',
    ),

    // ID 14: CDMX - Polígono AIFA
    PoloMarker(
      id: 14,
      idString: 'cdmx_poligono',
      nombre: 'Polígono AIFA (Zona Metro)',
      estado: 'Ciudad de México',
      estadoCodigo: 'DF',
      relativeX: 0.50,
      relativeY: 0.70,
      lat: 19.4326,
      lng: -99.1332,
      areaHa: 'Indirecto',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'nuevo',
      region: 'Centro-Bajío',
      vocacion: 'Servicios Corporativos',
      sectoresClave: [
        'Fintech',
        'Servicios HQ',
        'Centros de Datos',
      ],
      infraestructura: 'Conectividad digital y oficinas corporativas',
      descripcion: 'Centro de servicios corporativos y tecnológicos',
      empleoEstimado: 'Generación de empleos administrativos y financieros',
      beneficiosLargoPlazo: 'Centralización de la toma de decisiones empresariales',
    ),

    // ═══════════════════════════════════════════════════════════════
    // 🚢 REGIÓN SUR-SURESTE (Corredores Interoceánicos y Tren Maya)
    // ═══════════════════════════════════════════════════════════════

    // ID 15: Oaxaca - Istmo (Salina Cruz)
    PoloMarker(
      id: 15,
      idString: 'oaxaca_salina_cruz',
      nombre: 'Istmo (Salina Cruz)',
      estado: 'Oaxaca',
      estadoCodigo: 'OA',
      relativeX: 0.73,
      relativeY: 0.21,
      lat: 16.1843,
      lng: -95.1956,
      areaHa: 'CIIT',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'en_marcha',
      region: 'Sur-Sureste',
      vocacion: 'Puerta al Pacífico (Corredor Interoceánico)',
      sectoresClave: [
        'Agroindustria',
        'Componentes Eólicos',
        'Textil',
      ],
      infraestructura: 'Rompeolas Oeste, Modernización Ferroviaria',
      descripcion: 'CIIT - Gateway principal al Océano Pacífico',
      empleoEstimado: 'Proyección Regional: 150,000 empleos al 2030',
      beneficiosLargoPlazo: 'Alternativa real al Canal de Panamá y desarrollo del Sur',
    ),

    // ID 16: Veracruz - Istmo (Coatzacoalcos)
    PoloMarker(
      id: 16,
      idString: 'veracruz_coatzacoalcos',
      nombre: 'Istmo (Coatzacoalcos)',
      estado: 'Veracruz',
      estadoCodigo: 'VZ',
      relativeX: 0.95,
      relativeY: 0.10,
      lat: 18.1501,
      lng: -94.4208,
      areaHa: 'CIIT',
      color: PoloColors.logistics,
      tipo: 'logistics',
      tipoDisplay: 'en_marcha',
      region: 'Sur-Sureste',
      vocacion: 'Puerta al Atlántico (Corredor Interoceánico)',
      sectoresClave: [
        'Petroquímica',
        'Fertilizantes',
        'Gas',
      ],
      infraestructura: 'Terminales de Contenedores y Químicos',
      descripcion: 'CIIT - Gateway al Océano Atlántico',
      empleoEstimado: 'Parte de la proyección regional CIIT',
      beneficiosLargoPlazo: 'Conexión energética y de materias primas con EE.UU.',
    ),

    // ID 17: Tabasco - Istmo (Polo Sur / Dos Bocas)
    PoloMarker(
      id: 17,
      idString: 'tabasco_dos_bocas',
      nombre: 'Istmo (Polo Sur)',
      estado: 'Tabasco',
      estadoCodigo: 'TB',
      relativeX: 0.40,
      relativeY: 0.53,
      lat: 17.9895,
      lng: -92.9281,
      areaHa: 'Indirecto',
      color: PoloColors.energy,
      tipo: 'energy',
      tipoDisplay: 'en_marcha',
      region: 'Sur-Sureste',
      vocacion: 'Soberanía Energética',
      sectoresClave: [
        'Refinación',
        'Servicios Petroleros',
      ],
      infraestructura: 'Refinería Olmeca, Gasoductos',
      descripcion: 'Centro de refinación y servicios petroleros',
      empleoEstimado: 'Mantenimiento de 2,000+ empleos operativos',
      beneficiosLargoPlazo: 'Autosuficiencia en combustibles',
    ),

    // ID 7: Yucatán - Maya
    PoloMarker(
      id: 7,
      idString: 'yucatan_maya',
      nombre: 'Maya (Mérida y Progreso)',
      estado: 'Yucatán',
      estadoCodigo: 'YU',
      relativeX: 0.28,
      relativeY: 0.66,
      lat: 20.9674,
      lng: -89.5926,
      areaHa: '223 ha',
      color: PoloColors.tourism,
      tipo: 'tourism',
      tipoDisplay: 'nuevo',
      region: 'Sur-Sureste',
      vocacion: 'Renacimiento Maya: Tech & Logistics',
      sectoresClave: [
        'TICs',
        'Ciberseguridad',
        'Turismo',
        'Agroindustria',
      ],
      infraestructura: 'Ampliación Puerto Progreso, Tren Maya Carga',
      descripcion: '223 ha - Hub tecnológico y logístico del sureste',
      empleoEstimado: 'Est. 30,000 empleos (Tech y Turismo)',
      beneficiosLargoPlazo: 'Diversificación económica del sureste más allá del turismo',
    ),

    // ID 18: Campeche - Maya / Regiones SE
    PoloMarker(
      id: 18,
      idString: 'campeche_maya',
      nombre: 'Maya / Regiones SE',
      estado: 'Campeche',
      estadoCodigo: 'CM',
      relativeX: 0.55,
      relativeY: 0.65,
      lat: 19.8301,
      lng: -90.5349,
      areaHa: 'Conexión',
      color: PoloColors.tourism,
      tipo: 'tourism',
      tipoDisplay: 'nuevo',
      region: 'Sur-Sureste',
      vocacion: 'Turismo y Economía Verde',
      sectoresClave: [
        'Turismo Sostenible',
        'Agroforestería',
      ],
      infraestructura: 'Tren Maya, Acueductos',
      descripcion: 'Polo de economía verde y turismo sostenible',
      empleoEstimado: 'Est. 10,000 empleos en turismo y campo',
      beneficiosLargoPlazo: 'Conservación ambiental y desarrollo rural',
    ),
  ];

  /// Obtiene los polos de un estado específico por nombre o código
  static List<PoloMarker> getPolosByEstado(String estadoNombreOCodigo) {
    return polos.where((polo) =>
      polo.estado == estadoNombreOCodigo ||
      polo.estadoCodigo == estadoNombreOCodigo
    ).toList();
  }

  /// Obtiene polos por región
  static List<PoloMarker> getPolosByRegion(String region) {
    return polos.where((polo) => polo.region == region).toList();
  }

  /// Obtiene polos por tipo (energy, logistics, industry, tourism)
  static List<PoloMarker> getPolosByTipo(String tipo) {
    return polos.where((polo) => polo.tipo == tipo).toList();
  }

  /// Obtiene todos los códigos de estado que tienen polos
  static Set<String> get estadosConPolos {
    return polos.map((p) => p.estadoCodigo).toSet();
  }

  /// Obtiene todos los nombres de estado que tienen polos
  static Set<String> get nombresEstadosConPolos {
    return polos.map((p) => p.estado).toSet();
  }

  /// Cuenta los polos por estado
  static int contarPolosPorEstado(String estadoNombreOCodigo) {
    return getPolosByEstado(estadoNombreOCodigo).length;
  }

  /// Obtiene las regiones únicas
  static List<String> get regiones {
    return polos.map((p) => p.region).where((r) => r.isNotEmpty).toSet().toList();
  }

  /// Obtiene un polo por su ID numérico
  static PoloMarker? getPoloById(int id) {
    try {
      return polos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene un polo por su ID string (para compatibilidad)
  static PoloMarker? getPoloByStringId(String idString) {
    try {
      return polos.firstWhere((p) => p.idString == idString);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el color según el tipo de polo
  static Color getColorByTipo(String tipo) {
    switch (tipo) {
      case 'energy':
        return PoloColors.energy;
      case 'logistics':
        return PoloColors.logistics;
      case 'industry':
        return PoloColors.industry;
      case 'tourism':
        return PoloColors.tourism;
      default:
        return PoloColors.nuevo;
    }
  }

  /// Obtiene el nombre legible del tipo
  static String getTipoNombre(String tipo) {
    switch (tipo) {
      case 'energy':
        return 'Energía';
      case 'logistics':
        return 'Logística';
      case 'industry':
        return 'Industria';
      case 'tourism':
        return 'Turismo';
      default:
        return 'Desarrollo';
    }
  }

  /// Resumen estadístico
  static Map<String, int> get resumenPorTipo {
    return {
      'energy': getPolosByTipo('energy').length,
      'logistics': getPolosByTipo('logistics').length,
      'industry': getPolosByTipo('industry').length,
      'tourism': getPolosByTipo('tourism').length,
    };
  }

  /// Total de empleos estimados (aproximado)
  static String get empleoTotalEstimado => '+500,000 empleos proyectados';
}
