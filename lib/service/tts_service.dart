import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

/// Servicio de Text-to-Speech con soporte para ElevenLabs en Web
/// y flutter_tts como fallback en móviles
class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  // Flutter TTS para móviles
  late FlutterTts _flutterTts;
  
  // ElevenLabs para Web
  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // ⚠️ IMPORTANTE: Reemplaza con tu API Key de ElevenLabs
  // Obtén una gratis en: https://elevenlabs.io/
  static const String _elevenLabsApiKey = 'sk_21f5a952eaf133de154789e0f96d320c95b4be116c91f2de';
  
  // Voz de ElevenLabs - Jaider (masculina mexicana)
  static const Map<String, Map<String, dynamic>> _elevenLabsVoices = {
    'jaider': {
      'id': 'rpqlUOplj0Q0PIilat8h',
      'name': 'Jaider', 
      'description': 'Masculina, mexicana',
    },
  };
  
  // Voz seleccionada por defecto
  String _selectedElevenLabsVoice = 'jaider';
  
  // Configuración de voz ElevenLabs
  // Ajustados para voz joven, aguda y ritmo normal-rápido
  double _stability = 0.5;        // Estabilidad (0-1)
  double _similarityBoost = 0.75; // Claridad (0-1)
  double _speed = 1.15;           // Velocidad (0.5-2.0), 1.15 = ligeramente rápido
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _useElevenLabs = true; // Usar ElevenLabs en Web y Móvil
  
  // Lista de voces disponibles
  List<Map<String, String>> _availableVoices = [];
  String _currentVoiceName = 'Jaider (ElevenLabs)';
  
  List<Map<String, String>> get availableVoices => _availableVoices;
  String get currentVoiceName => _currentVoiceName;
  bool get isPlaying => _isPlaying;
  bool get useElevenLabs => _useElevenLabs; // Ahora disponible en todas las plataformas
  
  TtsService._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    // Configuración para flutter_tts (móviles))
    await _flutterTts.setLanguage("es-MX");
    await _flutterTts.setVolume(0.9);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.1); // Ligeramente agudo

    // Cargar voces disponibles
    await _loadAvailableVoices();
    
    // Seleccionar la mejor voz disponible
    if (!kIsWeb) {
      await _selectBestVoice();
    }

    // Configurar AudioPlayer para ElevenLabs
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });

    _isInitialized = true;
  }

  Future<void> _loadAvailableVoices() async {
    _availableVoices = [];
    
    // Agregar voces de ElevenLabs (disponible en todas las plataformas)
    for (var entry in _elevenLabsVoices.entries) {
      _availableVoices.add({
        'name': entry.key,
        'locale': 'es-MX',
        'displayName': '${entry.value['name']} (ElevenLabs) - ${entry.value['description']}',
        'type': 'elevenlabs',
      });
    }
    
    // Agregar voces del sistema
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      
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
            'type': 'system',
          });
        }
      }
    } catch (e) {
      // Ignorar errores de flutter_tts
    }
    
    // Ordenar: ElevenLabs primero, luego mexicanas
    _availableVoices.sort((a, b) {
      if (a['type'] == 'elevenlabs' && b['type'] != 'elevenlabs') return -1;
      if (a['type'] != 'elevenlabs' && b['type'] == 'elevenlabs') return 1;
      bool aMx = a['locale']!.contains('MX') || a['name']!.contains('MX');
      bool bMx = b['locale']!.contains('MX') || b['name']!.contains('MX');
      if (aMx && !bMx) return -1;
      if (!aMx && bMx) return 1;
      return a['displayName']!.compareTo(b['displayName']!);
    });
    
    notifyListeners();
  }
  
  String _getDisplayName(String name, String locale) {
    if (name.contains('Microsoft') && name.contains('Online')) {
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
    if (name.length > 30) {
      return '${name.substring(0, 27)}...';
    }
    return '$name - $locale';
  }

  Future<void> _selectBestVoice() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      
      final preferredVoices = [
        'Microsoft Jorge Online (Natural)',
        'Microsoft Dalia Online (Natural)',
        'Google español de México',
        'es-mx-x-iad',
        'Juan',
      ];
      
      for (var prefName in preferredVoices) {
        for (var voice in voices) {
          String voiceName = voice['name']?.toString() ?? '';
          if (voiceName.toLowerCase().contains(prefName.toLowerCase())) {
            await setVoice(voiceName, voice['locale']?.toString() ?? 'es-MX');
            return;
          }
        }
      }
      
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

  /// Selecciona una voz de ElevenLabs
  void setElevenLabsVoice(String voiceKey) {
    if (_elevenLabsVoices.containsKey(voiceKey)) {
      _selectedElevenLabsVoice = voiceKey;
      _currentVoiceName = '${_elevenLabsVoices[voiceKey]!['name']} (ElevenLabs)';
      _useElevenLabs = true;
      notifyListeners();
    }
  }

  /// Configura los parámetros de voz de ElevenLabs
  void setElevenLabsSettings({
    double? stability,
    double? similarityBoost,
    double? speed,
  }) {
    if (stability != null) _stability = stability.clamp(0.0, 1.0);
    if (similarityBoost != null) _similarityBoost = similarityBoost.clamp(0.0, 1.0);
    if (speed != null) _speed = speed.clamp(0.5, 2.0);
    notifyListeners();
  }

  Future<void> setVoice(String name, String locale) async {
    // Verificar si es una voz de ElevenLabs
    if (_elevenLabsVoices.containsKey(name)) {
      setElevenLabsVoice(name);
      return;
    }
    
    // Es una voz del sistema
    _useElevenLabs = false;
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

  /// Habla el texto usando ElevenLabs o flutter_tts como fallback
  Future<void> speak(String text) async {
    if (!_isInitialized) await _initTts();
    await stop();
    
    if (text.isEmpty) return;
    
    // Usar ElevenLabs si está habilitado y configurado (Web y Móvil)
    if (_useElevenLabs && _elevenLabsApiKey != 'TU_API_KEY_AQUI') {
      await _speakWithElevenLabs(text);
    } else {
      // Fallback a flutter_tts
      await _flutterTts.speak(text);
    }
  }

  /// Genera y reproduce audio con ElevenLabs
  Future<void> _speakWithElevenLabs(String text) async {
    try {
      _isPlaying = true;
      notifyListeners();
      
      final voiceId = _elevenLabsVoices[_selectedElevenLabsVoice]?['id'] ?? 
                      _elevenLabsVoices['mateo']!['id'];
      
      final response = await _dio.post(
        'https://api.elevenlabs.io/v1/text-to-speech/$voiceId',
        options: Options(
          headers: {
            'Accept': 'audio/mpeg',
            'Content-Type': 'application/json',
            'xi-api-key': _elevenLabsApiKey,
          },
          responseType: ResponseType.bytes,
        ),
        data: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2', // Mejor modelo para español
          'voice_settings': {
            'stability': _stability,
            'similarity_boost': _similarityBoost,
            'style': 0.0,
            'use_speaker_boost': true,
          },
          // Velocidad ligeramente rápida para voz joven
          'generation_config': {
            'speed': _speed,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final audioBytes = response.data as Uint8List;
        
        // Reproducir el audio
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
        // Fallback a flutter_tts si hay error
        _isPlaying = false;
        await _flutterTts.speak(text);
      }
    } catch (e) {
      _isPlaying = false;
      // Fallback a flutter_tts si hay error
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    try {
      // Detener AudioPlayer (ElevenLabs en Web)
      if (_isPlaying) {
        await _audioPlayer.stop();
        await _audioPlayer.release(); // Liberar recursos
        _isPlaying = false;
      }
      
      // Detener flutter_tts (móviles)
      if (_isInitialized) {
        await _flutterTts.stop();
      }
    } catch (e) {
      // Ignorar errores al detener
      _isPlaying = false;
    }
    notifyListeners();
  }

  /// Detiene todo el audio inmediatamente (para cerrar tutoriales)
  Future<void> stopImmediately() async {
    _isPlaying = false;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
      await _flutterTts.stop();
    } catch (e) {
      // Ignorar errores
    }
    notifyListeners();
  }

  /// Alterna entre ElevenLabs y voces del sistema
  void toggleElevenLabs(bool enabled) {
    _useElevenLabs = enabled;
    if (enabled && kIsWeb) {
      _currentVoiceName = '${_elevenLabsVoices[_selectedElevenLabsVoice]!['name']} (ElevenLabs)';
    }
    notifyListeners();
  }

  /// Obtiene las voces disponibles de ElevenLabs
  List<Map<String, dynamic>> getElevenLabsVoices() {
    return _elevenLabsVoices.entries.map((e) => {
      'key': e.key,
      ...e.value,
    }).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
