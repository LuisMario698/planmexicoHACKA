import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../service/voice_chat_service.dart';
import '../../attractions.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla completa del Asistente IA con diseño mejorado
class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen>
    with SingleTickerProviderStateMixin {
  final VoiceChatService _service = VoiceChatService();
  final AudioPlayer _player = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String? selectedAttraction =
      kAttractions.isNotEmpty ? kAttractions.first : null;

  final List<Map<String, dynamic>> _messages = [];
  bool _recording = false;
  bool _loading = false;
  bool _isTyping = false; // Para input de texto

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Mensaje de bienvenida
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text':
                '¡Hola! Soy el asistente de Plan México. Puedo ayudarte con información sobre inversiones, proyectos estratégicos y oportunidades de desarrollo. ¿En qué puedo ayudarte hoy?',
            'isUser': false,
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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

  Future<void> _toggleRecording() async {
    if (_recording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    await _askMicPermission();
    if (await _service.hasMicPermission()) {
      setState(() => _recording = true);
      await _service.startRecording();
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _recording = false;
      _loading = true;
    });

    try {
      final text = await _service.stopAndTranscribe();
      if (text == null || text.isEmpty) throw 'No se pudo transcribir.';

      await _processMessage(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isTyping = false;
      _loading = true;
    });

    await _processMessage(text);
  }

  Future<void> _processMessage(String text) async {
    // Agregar mensaje del usuario
    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });
    _scrollToBottom();

    try {
      // Gate check
      final gateResp =
          await _service.gate(text, attraction: selectedAttraction);
      final allowed = gateResp['allowed'] == true;
      final matched =
          (gateResp['matched'] as String?) ?? selectedAttraction ?? '';

      if (!allowed) {
        final reason =
            'Lo siento, esa pregunta está fuera de mi área. ${gateResp['reason'] ?? ''}';
        setState(() {
          _messages.add({'text': reason, 'isUser': false});
          _loading = false;
        });
        _scrollToBottom();
        return;
      }

      // Chat
      final answer = await _service.chat(text, attraction: matched);

      setState(() {
        _messages.add({'text': answer, 'isUser': false});
      });
      _scrollToBottom();

      // TTS
      final bytes = await _service.tts(answer, voice: 'verse');
      final file = await _service.saveBytesAsTempMp3(bytes);
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'text': 'Hubo un error al procesar tu mensaje. Intenta de nuevo.',
            'isUser': false,
          });
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark, isDesktop),

            // Área principal
            Expanded(
              child: Row(
                children: [
                  // Panel lateral en desktop
                  if (isDesktop) _buildSidePanel(isDark),

                  // Chat principal
                  Expanded(
                    child: Column(
                      children: [
                        // Mensajes
                        Expanded(child: _buildChatArea(isDark, isDesktop)),

                        // Input
                        _buildInputArea(isDark, isDesktop),
                      ],
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

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del asistente
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9D2449), Color(0xFF691C32)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9D2449).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/ajolotito.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Plan México',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'En línea • Responde al instante',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acciones
          if (isDesktop) ...[
            _buildHeaderAction(
              Icons.help_outline_rounded,
              'Ayuda',
              isDark,
              () {},
            ),
            const SizedBox(width: 12),
          ],
          _buildHeaderAction(
            Icons.more_vert_rounded,
            'Más',
            isDark,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
    IconData icon,
    String tooltip,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanel(bool isDark) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar grande
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF9D2449), Color(0xFF691C32)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9D2449).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/ajolotito.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Axolotl IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu asistente inteligente',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sugerencias rápidas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugerencias',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionChip(
                    '¿Cuáles son los proyectos más grandes?',
                    Icons.trending_up_rounded,
                    isDark,
                  ),
                  _buildSuggestionChip(
                    '¿Qué sectores tienen más inversión?',
                    Icons.pie_chart_rounded,
                    isDark,
                  ),
                  _buildSuggestionChip(
                    '¿Cómo funciona el nearshoring?',
                    Icons.factory_rounded,
                    isDark,
                  ),
                  _buildSuggestionChip(
                    'Información sobre energías renovables',
                    Icons.bolt_rounded,
                    isDark,
                  ),
                  _buildSuggestionChip(
                    '¿Qué es Plan México?',
                    Icons.info_outline_rounded,
                    isDark,
                  ),
                ],
              ),
            ),
          ),

          // Capacidades
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capacidades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCapabilityIcon(Icons.mic_rounded, isDark),
                    _buildCapabilityIcon(Icons.keyboard_rounded, isDark),
                    _buildCapabilityIcon(Icons.volume_up_rounded, isDark),
                    _buildCapabilityIcon(Icons.translate_rounded, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityIcon(IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: const Color(0xFF9D2449),
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon, bool isDark) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        _sendTextMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF9D2449),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppTheme.lightText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(bool isDark, bool isDesktop) {
    if (_messages.isEmpty && !_loading) {
      return _buildWelcomeView(isDark, isDesktop);
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 0,
        vertical: isDesktop ? 16 : 0,
      ),
      decoration: isDesktop
          ? BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            )
          : null,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
          vertical: 20,
        ),
        itemCount: _messages.length + (_loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (_loading && index == _messages.length) {
            return _buildTypingIndicator(isDark);
          }

          final msg = _messages[index];
          return _buildMessageBubble(
            msg['text'],
            isUser: msg['isUser'],
            isDark: isDark,
            isDesktop: isDesktop,
          );
        },
      ),
    );
  }

  Widget _buildWelcomeView(bool isDark, bool isDesktop) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar animado
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: isDesktop ? 150 : 120,
                    height: isDesktop ? 150 : 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9D2449), Color(0xFF691C32)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9D2449).withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Image.asset(
                        'assets/images/ajolotito.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            Text(
              '¡Hola! Soy tu asistente',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pregúntame sobre inversiones, proyectos\ny oportunidades en Plan México',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 40),

            // Sugerencias en móvil
            if (!isDesktop) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickSuggestion('Proyectos destacados', isDark),
                  _buildQuickSuggestion('Sectores clave', isDark),
                  _buildQuickSuggestion('¿Qué es nearshoring?', isDark),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        _sendTextMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF9D2449).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF9D2449).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF9D2449),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF9D2449).withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    String text, {
    required bool isUser,
    required bool isDark,
    required bool isDesktop,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        constraints: BoxConstraints(
          maxWidth: isDesktop
              ? 500
              : MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF9D2449), Color(0xFF691C32)],
                )
              : null,
          color: isUser
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: isUser
              ? [
                  BoxShadow(
                    color: const Color(0xFF9D2449).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : (isDark ? Colors.white : AppTheme.lightText),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Campo de texto
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onChanged: (value) {
                          setState(() => _isTyping = value.isNotEmpty);
                        },
                        onSubmitted: (_) => _sendTextMessage(),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.lightText,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_isTyping)
                      IconButton(
                        onPressed: _sendTextMessage,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Color(0xFF9D2449),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Botón de micrófono
            GestureDetector(
              onTap: _toggleRecording,
              child: AvatarGlow(
                animate: _recording,
                glowColor: const Color(0xFF9D2449),
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _recording
                          ? [Colors.red, Colors.red.shade700]
                          : [const Color(0xFF9D2449), const Color(0xFF691C32)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_recording ? Colors.red : const Color(0xFF9D2449))
                            .withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
