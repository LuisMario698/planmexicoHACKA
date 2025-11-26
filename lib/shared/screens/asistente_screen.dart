import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../service/voice_chat_service.dart';
import '../../attractions.dart';

/// Pantalla del Asistente IA
class AsistenteScreen extends StatefulWidget {
  final String defaultVoice;
  final bool isDialog;

  const AsistenteScreen({
    super.key,
    this.defaultVoice = 'verse',
    this.isDialog = false,
  });

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final service = VoiceChatService();
  final player = AudioPlayer();
  final ScrollController _scrollController =
      ScrollController(); // Para bajar automáticamente

  String? selectedAttraction = kAttractions.isNotEmpty
      ? kAttractions.first
      : null;

  // CAMBIO 1: En lugar de strings sueltos, usamos una lista para el historial
  // Cada item será un mapa: {'text':String, 'isUser':bool}
  final List<Map<String, dynamic>> _messages = [];

  bool recording = false;
  bool loading = false;

  final Color primaryColor = const Color(0xFF9D2449);
  final Color _darkBackground = const Color(0xFF121212);
  final Color _darkBotBubble = const Color(0xFF2C3E50).withOpacity(0.8);

  @override
  void dispose() {
    player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para bajar el scroll al último mensaje
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  Future<void> _stopRecordingLogic() async {
    setState(() {
      recording = false;
      loading = true;
    });

    try {
      // 1. Transcribir
      final text = await service.stopAndTranscribe();
      if (text == null || text.isEmpty) throw 'No se pudo transcribir.';

      // AGREGAR PREGUNTA AL HISTORIAL
      setState(() {
        _messages.add({'text': text, 'isUser': true});
      });
      _scrollToBottom(); // Bajar scroll

      // 2. Gate
      final gateResp = await service.gate(text, attraction: selectedAttraction);
      final allowed = gateResp['allowed'] == true;
      final matched =
          (gateResp['matched'] as String?) ?? selectedAttraction ?? '';

      if (!allowed) {
        final reason =
            'Fuera de tema: ${gateResp['reason'] ?? 'sin razón'}. Tema: $matched';
        setState(() {
          _messages.add({'text': reason, 'isUser': false});
          loading = false;
        });
        _scrollToBottom();
        return;
      }

      // 3. Chat
      final answer = await service.chat(text, attraction: matched);

      // AGREGAR RESPUESTA AL HISTORIAL
      setState(() {
        _messages.add({'text': answer, 'isUser': false});
      });
      _scrollToBottom();

      // 4. TTS
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

  Widget _buildChatBubble(
    String text, {
    required bool isUser,
    required Color botBgColor,
    required Color textColor,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryColor.withOpacity(0.9) : botBgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : textColor,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? _darkBackground : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final botBubbleColorDynamic = isDark ? _darkBotBubble : Colors.grey[200]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        double bannerHeight;
        double ajoloteSize;

        if (availableWidth > 600) {
          bannerHeight = availableWidth * 0.35;
          if (bannerHeight > 500) bannerHeight = 500;
          ajoloteSize = 300;
        } else {
          bannerHeight = availableWidth * 0.6;
          if (bannerHeight > 250) bannerHeight = 250;
          if (bannerHeight < 180) bannerHeight = 180;
          ajoloteSize = bannerHeight * 0.75;
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // --- HEADER SUPERIOR (FIJO) ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        "Asistente IA",
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // --- BANNER + MICRÓFONO (FIJO - NO SCROLL) ---
              // Al estar fuera del ListView, esto siempre se quedará arriba
              SizedBox(
                height: bannerHeight + 40,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.2),
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
                      child: _buildMicButton(isDark),
                    ),
                  ],
                ),
              ),

              // --- ZONA DE CHAT (SCROLLABLE) ---
              // Usamos Expanded + ListView.builder para eficiencia y manejo de listas
              Expanded(
                child: _messages.isEmpty && !loading
                    // Mensaje de Bienvenida si está vacío
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            "Hola, soy tu asistente inteligente.\nMantén presionado el micrófono para preguntar.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      )
                    // Lista de mensajes si hay datos
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount:
                            _messages.length +
                            (loading
                                ? 1
                                : 0), // +1 para el loader si es necesario
                        itemBuilder: (context, index) {
                          // Si estamos cargando y es el último elemento, mostrar spinner
                          if (loading && index == _messages.length) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white : primaryColor,
                                ),
                              ),
                            );
                          }

                          final msg = _messages[index];
                          return _buildChatBubble(
                            msg['text'],
                            isUser: msg['isUser'],
                            botBgColor: botBubbleColorDynamic,
                            textColor: textColor,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMicButton(bool isDark) {
    Color btnColor;
    Color iconColor;

    if (recording) {
      btnColor = primaryColor;
      iconColor = Colors.white;
    } else {
      btnColor = isDark ? const Color(0xFF2C3E50) : Colors.white;
      iconColor = isDark ? Colors.white : primaryColor;
    }

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
            backgroundColor: btnColor,
            radius: 35.0,
            child: Icon(
              recording ? Icons.mic : Icons.mic_none_outlined,
              size: 30,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
