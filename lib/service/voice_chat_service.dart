import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:record/record.dart' as rec;
import 'package:path_provider/path_provider.dart';
import '../app_config.dart';

class VoiceChatService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
    ),
  );

  final rec.AudioRecorder _rec = rec.AudioRecorder();
  String? _currentPath;

  Future<bool> hasMicPermission() async => await _rec.hasPermission();

  Future<void> startRecording() async {
    final cfg = rec.RecordConfig(
      encoder: rec.AudioEncoder.aacLc,
      sampleRate: 44100,
      numChannels: 1,
      bitRate: 128000,
    );
    final dir = await getTemporaryDirectory();
    _currentPath =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _rec.start(
      cfg,
      path: _currentPath!,
    ); // config posicional, path nombrado
  }

  Future<String?> stopAndTranscribe() async {
    await _rec.stop();
    final path = _currentPath;
    _currentPath = null;
    if (path == null || !File(path).existsSync()) return null;

    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(path, filename: 'user.m4a'),
    });
    final resp = await _dio.post('/stt', data: form);
    return (resp.data?['text'] as String?)?.trim();
  }

  /// /gate -> retorna allowed/reason/score/matched
  Future<Map<String, dynamic>> gate(String text, {String? attraction}) async {
    final resp = await _dio.post(
      '/gate',
      data: {
        'text': text,
        if (attraction != null && attraction.isNotEmpty) 'topic': attraction,
      },
    );
    return Map<String, dynamic>.from(resp.data as Map);
  }

  /// /chat -> usa el attraction/matched para acotar la respuesta
  Future<String> chat(String userText, {String? attraction}) async {
    final resp = await _dio.post(
      '/chat',
      data: {
        'userText': userText,
        if (attraction != null && attraction.isNotEmpty) 'topic': attraction,
      },
    );
    return (resp.data?['text'] as String?) ?? 'Sin respuesta.';
  }

  Future<Uint8List> tts(String text, {String voice = 'verse'}) async {
    final resp = await _dio.post<List<int>>(
      '/tts',
      data: {'text': text, 'voice': voice},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data!);
  }

  Future<File> saveBytesAsTempMp3(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final f = File(
      '${dir.path}/bot_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    return f.writeAsBytes(bytes, flush: true);
  }
}
