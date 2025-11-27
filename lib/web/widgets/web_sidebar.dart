import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/responsive_scaffold.dart';
import '../../service/tts_service.dart';

class WebSidebar extends StatefulWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final ThemeProvider themeProvider;

  const WebSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.themeProvider,
  });

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  int? _hoveredIndex;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
    _expandController.forward();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final width = 64.0 + (_expandAnimation.value * 176.0);

        return Container(
          width: width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryLight,
                AppTheme.primaryColor,
                AppTheme.primaryDark,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(isDark),
              const SizedBox(height: 24),
              Expanded(child: _buildNavItems(isDark)),
              _buildVoiceSelector(isDark),
              const SizedBox(height: 8),
              _buildThemeToggle(isDark),
              const SizedBox(height: 8),
              _buildToggleButton(isDark),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    // Tamaño del logo basado en si está expandido o no
    final logoSize = _isExpanded ? 150.0 : 80.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: logoSize,
        height: logoSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_isExpanded ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(_isExpanded ? 10 : 6),
        child: SvgPicture.asset(
          'assets/images/logo_planMX_solo.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildNavItems(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = index == widget.selectedIndex;
        final isHovered = index == _hoveredIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => widget.onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: _isExpanded ? 12 : 0,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : isHovered
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: _isExpanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    if (_expandAnimation.value > 0.5) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Opacity(
                          opacity: ((_expandAnimation.value - 0.5) * 2).clamp(
                            0.0,
                            1.0,
                          ),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceSelector(bool isDark) {
    final ttsService = TtsService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showVoiceDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 12 : 0,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.record_voice_over,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                if (_expandAnimation.value > 0.5) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: ((_expandAnimation.value - 0.5) * 2).clamp(
                        0.0,
                        1.0,
                      ),
                      child: ListenableBuilder(
                        listenable: ttsService,
                        builder: (context, _) {
                          return Text(
                            ttsService.currentVoiceName.length > 12
                                ? '${ttsService.currentVoiceName.substring(0, 12)}...'
                                : ttsService.currentVoiceName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVoiceDialog(BuildContext context) async {
    final ttsService = TtsService();
    final voices = await ttsService.getVoices();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Seleccionar Voz'),
          ],
        ),
        content: SizedBox(
          width: 350,
          height: 400,
          child: voices.isEmpty
              ? const Center(child: Text('No hay voces disponibles'))
              : ListView.builder(
                  itemCount: voices.length,
                  itemBuilder: (context, index) {
                    final voice = voices[index];
                    final isSelected =
                        ttsService.currentVoiceName == voice['displayName'];
                    final isMexican = voice['locale']!.contains('MX');

                    return ListTile(
                      leading: Icon(
                        isMexican ? Icons.flag : Icons.language,
                        color: isMexican ? AppTheme.primaryColor : Colors.grey,
                      ),
                      title: Text(
                        voice['displayName'] ?? voice['name'] ?? 'Desconocido',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                      subtitle: Text(
                        isMexican ? '🇲🇽 México' : voice['locale'] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                            )
                          : null,
                      onTap: () {
                        ttsService.setVoice(voice['name']!, voice['locale']!);
                        // Probar la voz
                        ttsService.speak('Hola, esta es mi voz');
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.themeProvider.toggleTheme(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 12 : 0,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                if (_expandAnimation.value > 0.5) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: ((_expandAnimation.value - 0.5) * 2).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Text(
                        isDark ? 'Oscuro' : 'Claro',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: ((_expandAnimation.value - 0.5) * 2).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Container(
                      width: 36,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        alignment: isDark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: _isExpanded ? 12 : 0,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                if (_expandAnimation.value > 0.5) ...[
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: ((_expandAnimation.value - 0.5) * 2).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Text(
                      'Colapsar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
