import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  
  // Lista de voces disponibles
  List<Map<String, String>> _availableVoices = [];
  String _currentVoiceName = 'Por defecto';
  
  List<Map<String, String>> get availableVoices => _availableVoices;
  String get currentVoiceName => _currentVoiceName;

  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    // Configuración para voz más natural y amigable
    await _flutterTts.setLanguage("es-ES"); // Español de España como fallback
    await _flutterTts.setVolume(0.9);
    await _flutterTts.setSpeechRate(0.45); // Más lento = más natural
    await _flutterTts.setPitch(1.05); // Ligeramente agudo para sonar amigable

    // Cargar voces disponibles
    await _loadAvailableVoices();
    
    // Seleccionar la mejor voz disponible
    await _selectBestVoice();

    _isInitialized = true;
  }

  Future<void> _loadAvailableVoices() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      _availableVoices = [];
      
      for (var voice in voices) {
        String name = voice['name']?.toString() ?? '';
        String locale = voice['locale']?.toString() ?? '';
        
        // Solo voces en español
        if (locale.toLowerCase().contains('es') || 
            name.toLowerCase().contains('spanish') ||
            name.toLowerCase().contains('español')) {
          _availableVoices.add({
            'name': name,
            'locale': locale,
            'displayName': _getDisplayName(name, locale),
          });
        }
      }
      
      // Ordenar: mexicanas primero
      _availableVoices.sort((a, b) {
        bool aMx = a['locale']!.contains('MX') || a['name']!.contains('MX');
        bool bMx = b['locale']!.contains('MX') || b['name']!.contains('MX');
        if (aMx && !bMx) return -1;
        if (!aMx && bMx) return 1;
        return a['displayName']!.compareTo(b['displayName']!);
      });
      
      notifyListeners();
    } catch (e) {
      _availableVoices = [];
    }
  }
  
  String _getDisplayName(String name, String locale) {
    // Simplificar nombre para mostrar
    if (name.contains('Microsoft') && name.contains('Online')) {
      // Microsoft Dalia Online (Natural) - Spanish (Mexico) -> Dalia (Neural)
      final match = RegExp(r'Microsoft (\w+)').firstMatch(name);
      if (match != null) {
        String voiceName = match.group(1) ?? name;
        bool isNeural = name.contains('Natural') || name.contains('Neural');
        return '$voiceName${isNeural ? ' (Neural)' : ''} - ${locale.contains('MX') ? 'México' : locale}';
      }
    }
    if (name.contains('Google')) {
      return 'Google - ${locale.contains('MX') ? 'México' : locale}';
    }
    // Acortar nombres largos
    if (name.length > 30) {
      return '${name.substring(0, 27)}...';
    }
    return '$name - $locale';
  }

  Future<void> _selectBestVoice() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      
      // Prioridad de voces (de mejor a peor calidad)
      final preferredVoices = [
        // 1. Voces neurales de Microsoft Edge (suenan como humanos)
        'Microsoft Jorge Online (Natural)',  // Masculina MX neural
        'Microsoft Dalia Online (Natural)',  // Femenina MX neural
        'Microsoft Raul',  // Masculina MX
        'Microsoft Sabina', // Femenina MX
        // 2. Google español (decente)
        'Google - es-US',  // Español USA (latino)
        'Google español de México',
        'Google - es-ES',  // Español España
        'Google español',
        // 3. Voces de Android
        'es-mx-x-iad',
        'es-us-x',
        'es-mx-x-sfb',
        // 4. iOS
        'Juan',
        'Paulina',
      ];
      
      // Buscar la mejor voz disponible
      for (var prefName in preferredVoices) {
        for (var voice in voices) {
          String voiceName = voice['name']?.toString() ?? '';
          
          if (voiceName.toLowerCase().contains(prefName.toLowerCase())) {
            await setVoice(voiceName, voice['locale']?.toString() ?? 'es-ES');
            return;
          }
        }
      }
      
      // Fallback: cualquier voz en español
      for (var voice in voices) {
        String locale = voice['locale']?.toString() ?? '';
        if (locale.startsWith('es')) {
          await setVoice(voice['name'], locale);
          return;
        }
      }
    } catch (e) {
      // Usar configuración por defecto
    }
  }

  Future<void> setVoice(String name, String locale) async {
    try {
      await _flutterTts.setVoice({"name": name, "locale": locale});
      _currentVoiceName = _getDisplayName(name, locale);
      notifyListeners();
    } catch (e) {
      // Ignorar errores
    }
  }

  Future<List<Map<String, String>>> getVoices() async {
    if (_availableVoices.isEmpty) {
      await _loadAvailableVoices();
    }
    return _availableVoices;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await _initTts();
    // Detener cualquier reproducción anterior
    await stop();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }
}
