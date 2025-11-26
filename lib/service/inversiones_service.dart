import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Modelo de datos para un proyecto de inversión
class ProyectoInversion {
  final String proyecto;
  final String alias;
  final String sector;
  final String subsector;
  final String tipoInversion;
  final String moneda;
  final double? inversionMXN;
  final double? inversionUSD;
  final String alcancesContrato;
  final String descripcion;
  final String tipoProyecto;
  final String tipoContrato;
  final String plazoContrato;
  final String etapa;
  final String subetapa;
  final String estados;
  final String entidadResponsable;
  final String url;
  final String activo;
  final String cantidad;
  final String medida;

  ProyectoInversion({
    required this.proyecto,
    required this.alias,
    required this.sector,
    required this.subsector,
    required this.tipoInversion,
    required this.moneda,
    this.inversionMXN,
    this.inversionUSD,
    required this.alcancesContrato,
    required this.descripcion,
    required this.tipoProyecto,
    required this.tipoContrato,
    required this.plazoContrato,
    required this.etapa,
    required this.subetapa,
    required this.estados,
    required this.entidadResponsable,
    required this.url,
    required this.activo,
    required this.cantidad,
    required this.medida,
  });

  /// Formatea número a formato legible
  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}B';
    } else if (number >= 1) {
      return '${number.toStringAsFixed(0)}M';
    }
    return number.toStringAsFixed(2);
  }

  /// Obtiene el monto formateado para mostrar (prioriza MXN)
  String get montoFormateado {
    if (inversionMXN != null && inversionMXN! > 0) {
      return '\$${_formatNumber(inversionMXN!)} MXN';
    } else if (inversionUSD != null && inversionUSD! > 0) {
      return '\$${_formatNumber(inversionUSD!)} USD';
    }
    return 'Por definir';
  }

  /// Obtiene un ícono representativo basado en el sector
  String get iconoSector {
    switch (sector.toLowerCase()) {
      case 'transporte':
        return 'directions_bus';
      case 'electricidad':
        return 'bolt';
      case 'agua y medio ambiente':
        return 'water_drop';
      case 'inmobiliario y turismo':
        return 'beach_access';
      case 'telecomunicaciones':
        return 'cell_tower';
      case 'hidrocarburos':
        return 'oil_barrel';
      case 'social':
        return 'people';
      default:
        return 'business';
    }
  }

  /// Crea un ProyectoInversion desde una fila CSV
  factory ProyectoInversion.fromCsvRow(List<String> headers, List<String> values) {
    String getValue(String columnName) {
      final index = headers.indexWhere(
        (h) => h.toLowerCase().trim() == columnName.toLowerCase().trim()
      );
      if (index >= 0 && index < values.length) {
        return values[index].trim();
      }
      return '';
    }

    double? parseDouble(String value) {
      if (value.isEmpty) return null;
      // Limpiar el valor:
      // 1. Remover espacios
      // 2. Remover símbolos de moneda ($, etc)
      // 3. Manejar formato mexicano: usar coma como decimal
      //    Ejemplo: "1,234.56" o "1.234,56" o "97,5"
      String cleaned = value.trim();
      
      // Remover caracteres no numéricos excepto punto, coma y guión
      cleaned = cleaned.replaceAll(RegExp(r'[^\d.,\-]'), '');
      
      if (cleaned.isEmpty) return null;
      
      // Detectar formato:
      // Si tiene coma después del último punto, es formato europeo (1.234,56)
      // Si tiene punto después de la última coma, es formato americano (1,234.56)
      // Si solo tiene coma, es decimal con coma (97,5)
      // Si solo tiene punto, es decimal con punto (97.5)
      
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      
      if (lastComma > lastDot) {
        // Formato europeo: la coma es el decimal
        // Remover puntos (separadores de miles) y cambiar coma por punto
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else if (lastDot > lastComma) {
        // Formato americano: el punto es el decimal
        // Remover comas (separadores de miles)
        cleaned = cleaned.replaceAll(',', '');
      } else if (lastComma >= 0 && lastDot < 0) {
        // Solo tiene coma, es el separador decimal
        cleaned = cleaned.replaceAll(',', '.');
      }
      // Si solo tiene punto o ninguno, ya está en formato correcto
      
      return double.tryParse(cleaned);
    }

    return ProyectoInversion(
      proyecto: getValue('Proyecto'),
      alias: getValue('Alias'),
      sector: getValue('Sector'),
      subsector: getValue('Subsector'),
      tipoInversion: getValue('Tipo de inversión'),
      moneda: getValue('Moneda del contrato'),
      inversionMXN: parseDouble(getValue('Inversión (Millones MXN)')),
      inversionUSD: parseDouble(getValue('Inversión (Millones USD)')),
      alcancesContrato: getValue('Alcances del contrato'),
      descripcion: getValue('Descripción'),
      tipoProyecto: getValue('Tipo de proyecto'),
      tipoContrato: getValue('Tipo de contrato'),
      plazoContrato: getValue('Plazo de contrato'),
      etapa: getValue('Etapa'),
      subetapa: getValue('Subetapa'),
      estados: getValue('Estado(s)'),
      entidadResponsable: getValue('Entidad responsable'),
      url: getValue('URL'),
      activo: getValue('Activo'),
      cantidad: getValue('Cantidad'),
      medida: getValue('Medida'),
    );
  }

  /// Convierte a Map para uso en UI
  Map<String, dynamic> toMap() {
    return {
      'proyecto': proyecto,
      'alias': alias,
      'sector': sector,
      'subsector': subsector,
      'tipoInversion': tipoInversion,
      'inversionMXN': inversionMXN,
      'inversionUSD': inversionUSD,
      'montoFormateado': montoFormateado,
      'alcancesContrato': alcancesContrato,
      'descripcion': descripcion,
      'tipoProyecto': tipoProyecto,
      'tipoContrato': tipoContrato,
      'plazoContrato': plazoContrato,
      'etapa': etapa,
      'subetapa': subetapa,
      'estados': estados,
      'entidadResponsable': entidadResponsable,
      'url': url,
      'activo': activo,
      'cantidad': cantidad,
      'medida': medida,
    };
  }
}

/// Servicio para obtener proyectos de inversión desde Google Sheets
class InversionesService {
  static final InversionesService _instance = InversionesService._internal();
  factory InversionesService() => _instance;
  InversionesService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Cache de proyectos
  List<ProyectoInversion>? _cachedProyectos;
  DateTime? _lastFetch;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // ============================================================
  // CONFIGURACIÓN DE GOOGLE SHEETS
  // ============================================================
  // 
  // El Google Sheet ya está publicado como CSV.
  // Los datos se actualizan automáticamente cuando editas el Sheet.
  //
  // ============================================================

  /// URL directa del CSV publicado
  static const String _csvUrl = 
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vRGKtmXI1JkWlytgNlfOP4yg-ujRdfFchLa5S48V4s3Ovx__R2ngG323SsyEgYreLXNxgl9gFFLuPFN/pub?gid=0&single=true&output=csv';

  /// Obtiene todos los proyectos desde Google Sheets
  /// 
  /// Si hay datos en cache y no han expirado, retorna el cache.
  /// De lo contrario, hace una petición al Google Sheet.
  Future<List<ProyectoInversion>> getProyectos({bool forceRefresh = false}) async {
    // Verificar cache
    if (!forceRefresh && _cachedProyectos != null && _lastFetch != null) {
      final elapsed = DateTime.now().difference(_lastFetch!);
      if (elapsed < _cacheExpiration) {
        debugPrint('📦 InversionesService: Retornando ${_cachedProyectos!.length} proyectos desde cache');
        return _cachedProyectos!;
      }
    }

    try {
      debugPrint('🌐 InversionesService: Obteniendo proyectos desde Google Sheets...');
      
      final response = await _dio.get<String>(_csvUrl);
      
      if (response.statusCode == 200 && response.data != null) {
        final proyectos = _parseCsv(response.data!);
        
        // Guardar en cache
        _cachedProyectos = proyectos;
        _lastFetch = DateTime.now();
        
        debugPrint('✅ InversionesService: ${proyectos.length} proyectos cargados exitosamente');
        return proyectos;
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ InversionesService DioError: ${e.message}');
      
      // Si hay cache, retornarlo aunque esté expirado
      if (_cachedProyectos != null) {
        debugPrint('⚠️ InversionesService: Retornando cache expirado');
        return _cachedProyectos!;
      }
      
      rethrow;
    } catch (e) {
      debugPrint('❌ InversionesService Error: $e');
      
      if (_cachedProyectos != null) {
        return _cachedProyectos!;
      }
      
      rethrow;
    }
  }

  /// Obtiene la lista de sectores únicos
  Future<List<String>> getSectores() async {
    final proyectos = await getProyectos();
    final sectores = proyectos
        .map((p) => p.sector)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    sectores.sort();
    return ['Todos', ...sectores];
  }

  /// Obtiene la lista de subsectores únicos
  Future<List<String>> getSubsectores() async {
    final proyectos = await getProyectos();
    final subsectores = proyectos
        .map((p) => p.subsector)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    subsectores.sort();
    return ['Todos', ...subsectores];
  }

  /// Obtiene la lista de etapas únicas
  Future<List<String>> getEtapas() async {
    final proyectos = await getProyectos();
    final etapas = proyectos
        .map((p) => p.etapa)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    etapas.sort();
    return ['Todas', ...etapas];
  }

  /// Obtiene la lista de tipos de inversión únicos
  Future<List<String>> getTiposInversion() async {
    final proyectos = await getProyectos();
    final tipos = proyectos
        .map((p) => p.tipoInversion)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    tipos.sort();
    return ['Todos', ...tipos];
  }

  /// Filtra proyectos según criterios
  Future<List<ProyectoInversion>> filtrarProyectos({
    String? sector,
    String? subsector,
    String? etapa,
    String? tipoInversion,
    String? busqueda,
    double? inversionMinima,
    double? inversionMaxima,
  }) async {
    var proyectos = await getProyectos();

    if (sector != null && sector != 'Todos') {
      proyectos = proyectos.where((p) => p.sector == sector).toList();
    }

    if (subsector != null && subsector != 'Todos') {
      proyectos = proyectos.where((p) => p.subsector == subsector).toList();
    }

    if (etapa != null && etapa != 'Todas') {
      proyectos = proyectos.where((p) => p.etapa == etapa).toList();
    }

    if (tipoInversion != null && tipoInversion != 'Todos') {
      proyectos = proyectos.where((p) => p.tipoInversion == tipoInversion).toList();
    }

    if (busqueda != null && busqueda.isNotEmpty) {
      final query = busqueda.toLowerCase();
      proyectos = proyectos.where((p) =>
          p.proyecto.toLowerCase().contains(query) ||
          p.sector.toLowerCase().contains(query) ||
          p.subsector.toLowerCase().contains(query) ||
          p.descripcion.toLowerCase().contains(query) ||
          p.estados.toLowerCase().contains(query)
      ).toList();
    }

    if (inversionMinima != null) {
      proyectos = proyectos.where((p) {
        final monto = p.inversionUSD ?? p.inversionMXN ?? 0;
        return monto >= inversionMinima;
      }).toList();
    }

    if (inversionMaxima != null) {
      proyectos = proyectos.where((p) {
        final monto = p.inversionUSD ?? p.inversionMXN ?? 0;
        return monto <= inversionMaxima;
      }).toList();
    }

    return proyectos;
  }

  /// Limpia el cache
  void clearCache() {
    _cachedProyectos = null;
    _lastFetch = null;
    debugPrint('🗑️ InversionesService: Cache limpiado');
  }

  /// Parsea el contenido CSV a lista de ProyectoInversion
  List<ProyectoInversion> _parseCsv(String csvContent) {
    final lines = _parseCsvLines(csvContent);
    
    if (lines.isEmpty) {
      return [];
    }

    final headers = lines.first;
    final proyectos = <ProyectoInversion>[];

    for (int i = 1; i < lines.length; i++) {
      try {
        final values = lines[i];
        if (values.isNotEmpty && values.any((v) => v.isNotEmpty)) {
          final proyecto = ProyectoInversion.fromCsvRow(headers, values);
          // Solo agregar si tiene un nombre de proyecto
          if (proyecto.proyecto.isNotEmpty) {
            proyectos.add(proyecto);
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error parseando fila $i: $e');
      }
    }

    return proyectos;
  }

  /// Parsea líneas CSV manejando campos con comas y saltos de línea entre comillas
  List<List<String>> _parseCsvLines(String csv) {
    final lines = <List<String>>[];
    final fields = <String>[];
    var field = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < csv.length) {
      final char = csv[i];

      if (char == '"') {
        if (inQuotes && i + 1 < csv.length && csv[i + 1] == '"') {
          // Comilla escapada ""
          field.write('"');
          i++;
        } else {
          // Toggle estado de comillas
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Fin del campo
        fields.add(field.toString().trim());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        // Fin de la fila (solo si no estamos dentro de comillas)
        // Ignorar \r si viene seguido de \n
        if (char == '\r' && i + 1 < csv.length && csv[i + 1] == '\n') {
          i++;
        }
        // Agregar último campo de la fila
        fields.add(field.toString().trim());
        field = StringBuffer();
        
        // Solo agregar la fila si tiene contenido
        if (fields.isNotEmpty && fields.any((f) => f.isNotEmpty)) {
          lines.add(List.from(fields));
        }
        fields.clear();
      } else if (char == '\r' || char == '\n') {
        // Salto de línea dentro de comillas - reemplazar con espacio
        field.write(' ');
      } else {
        field.write(char);
      }
      i++;
    }

    // Agregar último campo y fila si quedan
    if (field.isNotEmpty || fields.isNotEmpty) {
      fields.add(field.toString().trim());
      if (fields.any((f) => f.isNotEmpty)) {
        lines.add(List.from(fields));
      }
    }

    debugPrint('📊 CSV parseado: ${lines.length} filas encontradas');
    return lines;
  }
}
