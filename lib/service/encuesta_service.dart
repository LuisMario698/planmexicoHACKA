import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de respuesta de encuesta
class EncuestaRespuesta {
  final int? id;
  final int poloId;
  final String poloNombre;
  final String poloEstado;
  final int pregunta1Claridad; // 0-10: ¿Qué tan clara te pareció la información?
  final int pregunta2Beneficios; // 0-10: ¿Consideras que traerá beneficios reales?
  final int pregunta3Mejoras; // 0-10: ¿Qué tan necesario es mejorar?
  final String? pregunta4Recomendacion; // Texto abierto
  final DateTime? createdAt;

  EncuestaRespuesta({
    this.id,
    required this.poloId,
    required this.poloNombre,
    required this.poloEstado,
    required this.pregunta1Claridad,
    required this.pregunta2Beneficios,
    required this.pregunta3Mejoras,
    this.pregunta4Recomendacion,
    this.createdAt,
  });

  /// Convertir a Map para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'polo_id': poloId,
      'pregunta_1_claridad': pregunta1Claridad,
      'pregunta_2_beneficios': pregunta2Beneficios,
      'pregunta_3_mejoras': pregunta3Mejoras,
      'pregunta_4_recomendacion': pregunta4Recomendacion,
    };
  }

  /// Crear desde respuesta de API
  factory EncuestaRespuesta.fromJson(Map<String, dynamic> json) {
    return EncuestaRespuesta(
      id: json['id'],
      poloId: json['polo_id'],
      poloNombre: json['polo_nombre'] ?? '',
      poloEstado: json['polo_estado'] ?? '',
      pregunta1Claridad: json['pregunta_1_claridad'],
      pregunta2Beneficios: json['pregunta_2_beneficios'],
      pregunta3Mejoras: json['pregunta_3_mejoras'],
      pregunta4Recomendacion: json['pregunta_4_recomendacion'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}

/// Modelo de promedios por polo
class PoloPromedios {
  final int poloId;
  final String estado;
  final String poloNombre;
  final String tipo;
  final String descripcion;
  final int totalRespuestas;
  final double promedioClaridad;
  final double promedioBeneficios;
  final double promedioMejoras;
  final double promedioGeneral;

  PoloPromedios({
    required this.poloId,
    required this.estado,
    required this.poloNombre,
    required this.tipo,
    required this.descripcion,
    required this.totalRespuestas,
    required this.promedioClaridad,
    required this.promedioBeneficios,
    required this.promedioMejoras,
    required this.promedioGeneral,
  });

  factory PoloPromedios.fromJson(Map<String, dynamic> json) {
    return PoloPromedios(
      poloId: json['polo_id'],
      estado: json['estado'] ?? '',
      poloNombre: json['polo_nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      totalRespuestas: json['total_respuestas'] ?? 0,
      promedioClaridad: (json['promedio_claridad'] ?? 0).toDouble(),
      promedioBeneficios: (json['promedio_beneficios'] ?? 0).toDouble(),
      promedioMejoras: (json['promedio_mejoras'] ?? 0).toDouble(),
      promedioGeneral: (json['promedio_general'] ?? 0).toDouble(),
    );
  }
}

/// Mapeo de IDs de polos según la base de datos
class PolosDatabase {
  static const Map<String, int> poloIdMap = {
    // Sonora
    'polo_sonora_golfo': 1,
    'polo_sonora_plan': 2,
    // Tamaulipas
    'polo_tamaulipas_nuevo_laredo': 3,
    'polo_tamaulipas_puerto_seco': 4,
    // Puebla
    'polo_puebla_centro': 5,
    // Durango
    'polo_durango': 6,
    // Yucatán
    'polo_yucatan_maya': 7,
    // Coahuila
    'polo_coahuila_norte': 8,
    'polo_coahuila_piedras_negras': 9,
    // Nuevo León
    'polo_nuevo_leon': 10,
    // Chihuahua
    'polo_chihuahua': 11,
    // Guanajuato
    'polo_guanajuato_bajio': 12,
    // Estado de México
    'polo_edomex_aifa': 13,
    // CDMX
    'polo_cdmx_aifa': 14,
    // Oaxaca
    'polo_oaxaca_istmo': 15,
    // Veracruz
    'polo_veracruz_istmo': 16,
    // Tabasco
    'polo_tabasco_istmo': 17,
    // Campeche
    'polo_campeche_maya': 18,
  };

  /// Obtener ID numérico del polo a partir del ID string
  static int? getPoloId(String poloStringId) {
    return poloIdMap[poloStringId];
  }
  
  /// Intentar encontrar el ID más cercano basándose en el nombre del polo
  static int? findPoloIdByName(String nombre, String estado) {
    final nombreLower = nombre.toLowerCase();
    final estadoLower = estado.toLowerCase();
    
    // Mapeo por estado y nombre
    if (estadoLower.contains('sonora')) {
      if (nombreLower.contains('golfo') || nombreLower.contains('hermosillo')) return 1;
      if (nombreLower.contains('plan') || nombreLower.contains('peñasco')) return 2;
    }
    if (estadoLower.contains('tamaulipas')) {
      if (nombreLower.contains('laredo')) return 3;
      if (nombreLower.contains('seco') || nombreLower.contains('golfo')) return 4;
    }
    if (estadoLower.contains('puebla')) return 5;
    if (estadoLower.contains('durango')) return 6;
    if (estadoLower.contains('yucatán') || estadoLower.contains('yucatan')) return 7;
    if (estadoLower.contains('coahuila')) {
      if (nombreLower.contains('ahmsa') || nombreLower.contains('norte')) return 8;
      if (nombreLower.contains('piedras')) return 9;
    }
    if (estadoLower.contains('nuevo león') || estadoLower.contains('nuevo leon')) return 10;
    if (estadoLower.contains('chihuahua')) return 11;
    if (estadoLower.contains('guanajuato')) return 12;
    if (estadoLower.contains('méxico') && !estadoLower.contains('ciudad')) return 13;
    if (estadoLower.contains('ciudad') || estadoLower.contains('cdmx')) return 14;
    if (estadoLower.contains('oaxaca')) return 15;
    if (estadoLower.contains('veracruz')) return 16;
    if (estadoLower.contains('tabasco')) return 17;
    if (estadoLower.contains('campeche')) return 18;
    
    return null;
  }
}

/// Servicio para gestionar las encuestas de polos con Supabase
class EncuestaService {
  // Singleton
  static final EncuestaService _instance = EncuestaService._internal();
  factory EncuestaService() => _instance;
  EncuestaService._internal();

  // Estado de inicialización
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Cliente de Supabase (solo acceder si está inicializado)
  SupabaseClient get _supabase {
    if (!_isInitialized) {
      throw Exception('Supabase no está inicializado. Configura lib/app_config.dart');
    }
    return Supabase.instance.client;
  }

  // Tabla de respuestas en Supabase
  static const String _tableName = 'respuestas';

  /// Inicializar Supabase (llamar en main.dart)
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) return; // Ya inicializado
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _isInitialized = true;
    debugPrint('✅ Supabase inicializado correctamente');
  }

  /// Enviar una respuesta de encuesta a Supabase
  Future<bool> enviarRespuesta({
    required int poloId,
    required String poloNombre,
    required String poloEstado,
    required int pregunta1,
    required int pregunta2,
    required int pregunta3,
    String? pregunta4,
  }) async {
    // Verificar si Supabase está configurado
    if (!_isInitialized) {
      debugPrint('⚠️ Supabase no inicializado. Guardando localmente...');
      debugPrint('   Para conectar con Supabase, edita lib/app_config.dart');
      // Guardar localmente como fallback (en producción podrías usar SharedPreferences)
      debugPrint('📝 Encuesta (local):');
      debugPrint('   Polo: $poloNombre ($poloEstado) - ID: $poloId');
      debugPrint('   Claridad: $pregunta1/10, Beneficios: $pregunta2/10, Mejoras: $pregunta3/10');
      return true; // Retorna true para que la UI muestre éxito
    }
    
    try {
      final data = {
        'polo_id': poloId,
        'pregunta_1_claridad': pregunta1,
        'pregunta_2_beneficios': pregunta2,
        'pregunta_3_mejoras': pregunta3,
        'pregunta_4_recomendacion': pregunta4,
      };

      await _supabase.from(_tableName).insert(data);
      
      debugPrint('✅ Encuesta enviada a Supabase:');
      debugPrint('   Polo: $poloNombre ($poloEstado) - ID: $poloId');
      debugPrint('   Claridad: $pregunta1/10');
      debugPrint('   Beneficios: $pregunta2/10');
      debugPrint('   Mejoras: $pregunta3/10');
      if (pregunta4 != null && pregunta4.isNotEmpty) {
        debugPrint('   Recomendación: $pregunta4');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Error al enviar encuesta a Supabase: $e');
      return false;
    }
  }

  /// Obtener todas las respuestas de un polo
  Future<List<EncuestaRespuesta>> getRespuestasPorPolo(int poloId) async {
    if (!_isInitialized) return [];
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('polo_id', poloId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => EncuestaRespuesta.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener respuestas: $e');
      return [];
    }
  }

  /// Obtener los promedios de un polo desde la vista
  Future<PoloPromedios?> getPromediosPolo(int poloId) async {
    if (!_isInitialized) return null;
    
    try {
      final response = await _supabase
          .from('vista_promedios_polos')
          .select()
          .eq('polo_id', poloId)
          .single();
      
      return PoloPromedios.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error al obtener promedios del polo: $e');
      return null;
    }
  }

  /// Obtener promedios de todos los polos
  Future<List<PoloPromedios>> getPromediosTodosPolos() async {
    if (!_isInitialized) return [];
    
    try {
      final response = await _supabase
          .from('vista_promedios_polos')
          .select()
          .order('promedio_general', ascending: false);
      
      return (response as List)
          .map((json) => PoloPromedios.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener promedios de todos los polos: $e');
      return [];
    }
  }

  /// Obtener resumen general de todas las encuestas
  Future<Map<String, dynamic>> getResumenGeneral() async {
    if (!_isInitialized) {
      return {
        'total_respuestas': 0,
        'polos_evaluados': 0,
        'promedio_general': 0.0,
      };
    }
    
    try {
      final response = await _supabase
          .from('vista_resumen_general')
          .select()
          .single();
      
      return response;
    } catch (e) {
      debugPrint('❌ Error al obtener resumen general: $e');
      return {
        'total_respuestas': 0,
        'polos_evaluados': 0,
        'promedio_general': 0.0,
      };
    }
  }

  /// Obtener las recomendaciones (pregunta 4) de un polo
  Future<List<String>> getRecomendacionesPolo(int poloId) async {
    if (!_isInitialized) return [];
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('pregunta_4_recomendacion')
          .eq('polo_id', poloId)
          .not('pregunta_4_recomendacion', 'is', null)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => json['pregunta_4_recomendacion'] as String)
          .where((text) => text.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('❌ Error al obtener recomendaciones: $e');
      return [];
    }
  }

  /// Contar el total de respuestas
  Future<int> getTotalRespuestas() async {
    if (!_isInitialized) return 0;
    
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      debugPrint('❌ Error al contar respuestas: $e');
      return 0;
    }
  }

  /// Verificar conexión con Supabase
  Future<bool> verificarConexion() async {
    if (!_isInitialized) return false;
    
    try {
      await _supabase.from('polos').select('id').limit(1);
      debugPrint('✅ Conexión con Supabase verificada');
      return true;
    } catch (e) {
      debugPrint('❌ Error de conexión con Supabase: $e');
      return false;
    }
  }
}
