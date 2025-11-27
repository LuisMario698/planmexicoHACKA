import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Datos de estados de México y sus municipios
/// Carga desde: assets/images/estados.json
class MexicoLocationData {
  static List<Map<String, dynamic>> _estadosData = [];
  static bool _isLoaded = false;

  /// Carga los datos del JSON
  static Future<void> loadData() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/images/estados.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      _estadosData = jsonData.cast<Map<String, dynamic>>();
      _isLoaded = true;
      debugPrint('✅ Estados cargados: ${_estadosData.length}');
    } catch (e) {
      debugPrint('❌ Error cargando estados.json: $e');
      _estadosData = [];
    }
  }

  /// Lista de todos los estados de México
  static List<String> get estados {
    if (!_isLoaded) {
      debugPrint('⚠️ Datos no cargados todavía');
      return [];
    }
    return _estadosData.map((e) => e['estado'] as String).toList();
  }

  /// Obtiene los municipios de un estado específico
  static List<String> getCiudades(String estado) {
    if (!_isLoaded) return [];
    
    try {
      final estadoData = _estadosData.firstWhere(
        (e) => e['estado'] == estado,
        orElse: () => {'municipios': <String>[]},
      );
      
      final municipios = estadoData['municipios'];
      if (municipios is List) {
        return municipios.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('Error obteniendo ciudades para $estado: $e');
      return [];
    }
  }

  /// Verifica si los datos ya están cargados
  static bool get isLoaded => _isLoaded;
}
