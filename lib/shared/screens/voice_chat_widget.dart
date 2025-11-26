import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../service/voice_chat_service.dart';
import '../../attractions.dart'; // Asegúrate de que este archivo exista y tenga kAttractions

class VoiceChatWidget extends StatefulWidget {
  final String defaultVoice;
  final bool isDialog; // Para saber si estamos en modal

  const VoiceChatWidget({
    super.key,
    this.defaultVoice = 'verse',
    this.isDialog = false,
  });

  @override
  State<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends State<VoiceChatWidget> {
  final service = VoiceChatService();
  final player = AudioPlayer();

  // Recuperamos la variable de atracciones si la usas
  String? selectedAttraction = kAttractions.isNotEmpty
      ? kAttractions.first
      : null;
  String? userText;
  String? botText;
  bool recording = false;
  bool loading = false;

  final Color primaryColor = const Color(0xFF9D2449);
  final Color darkBackground = const Color(0xFF121212);
  final Color botBubbleColor = const Color(0xFF2C3E50).withOpacity(0.8);

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _askMicPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de micrófono denegado')),
      );
    }
  }

  Future<void> _startRecordingLogic() async {
    await _askMicPermission();
    if (await service.hasMicPermission()) {
      setState(() => recording = true);
      await service.startRecording();
    }
  }

  // --- AQUÍ ESTÁ LA CORRECCIÓN: Lógica Real Restaurada ---
  Future<void> _stopRecordingLogic() async {
    setState(() {
      recording = false;
      loading = true;
    });

    try {
      // 1. Transcribir voz a texto
      final text = await service.stopAndTranscribe();
      if (text == null || text.isEmpty) throw 'No se pudo transcribir.';
      setState(() => userText = text);

      // 2. Verificar el tema (Gate)
      final gateResp = await service.gate(text, attraction: selectedAttraction);
      final allowed = gateResp['allowed'] == true;
      final matched =
          (gateResp['matched'] as String?) ?? selectedAttraction ?? '';

      if (!allowed) {
        setState(
          () => botText =
              'Fuera de tema: ${gateResp['reason'] ?? 'sin razón'}. Tema: $matched',
        );
        setState(() => loading = false);
        return;
      }

      // 3. Obtener respuesta del Chatbot
      final answer = await service.chat(text, attraction: matched);
      setState(() => botText = answer);

      // 4. Generar Audio (TTS) y reproducir
      final bytes = await service.tts(answer, voice: widget.defaultVoice);
      final file = await service.saveBytesAsTempMp3(bytes);
      await player.play(DeviceFileSource(file.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildChatBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryColor.withOpacity(0.9) : botBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Lógica de altura responsiva (Mantenemos lo que arreglamos visualmente)
        double bannerHeight;
        double ajoloteSize;

        if (availableWidth > 600) {
          // Escritorio
          bannerHeight = availableWidth * 0.35;
          if (bannerHeight > 500) bannerHeight = 500;
          ajoloteSize = 300;
        } else {
          // Móvil / Modal
          bannerHeight = availableWidth * 0.6;
          if (bannerHeight > 250) bannerHeight = 250;
          if (bannerHeight < 180) bannerHeight = 180;
          ajoloteSize = bannerHeight * 0.75;
        }

        return Scaffold(
          backgroundColor: darkBackground,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // HEADER
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          availableWidth > 600
                              ? Icons.arrow_back_ios
                              : Icons.close_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      if (availableWidth < 600)
                        const Text(
                          "Asistente IA",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // BANNER
                      SizedBox(
                        height: bannerHeight + 40,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              height: bannerHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/Fondo.png'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Image.asset(
                                    'assets/images/ajolotito.png',
                                    height: ajoloteSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: bannerHeight - 35,
                              child: _buildMicButton(),
                            ),
                          ],
                        ),
                      ),

                      // CHAT AREA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            if (loading)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),

                            if (userText == null && botText == null && !loading)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 40,
                                ),
                                child: Text(
                                  "Hola, soy tu asistente inteligente.\nMantén presionado el micrófono para preguntar.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                            if (userText != null)
                              _buildChatBubble(userText!, isUser: true),
                            if (botText != null && !loading)
                              _buildChatBubble(botText!, isUser: false),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecordingLogic(),
      onTapUp: (_) => _stopRecordingLogic(),
      onTapCancel: () => _stopRecordingLogic(),
      child: AvatarGlow(
        animate: recording,
        glowColor: primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: Material(
          elevation: 8.0,
          shape: const CircleBorder(),
          color: Colors.transparent,
          child: CircleAvatar(
            backgroundColor: recording ? primaryColor : const Color(0xFF2C3E50),
            radius: 35.0,
            child: Icon(
              recording ? Icons.mic : Icons.mic_none_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
