import 'package:flutter/material.dart';
import '../../core/theme/theme_provider.dart';
import '../../web/widgets/web_sidebar.dart';
import '../../mobile/widgets/mobile_bottom_nav.dart';
import '../screens/home_screen.dart';
import '../screens/polos_screen.dart';
import '../screens/inversiones_screen.dart';
import '../screens/asistente_screen.dart';
import '../screens/voice_chat_widget.dart';

class ResponsiveScaffold extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ResponsiveScaffold({super.key, required this.themeProvider});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home_rounded, label: 'Inicio'),
    NavItem(icon: Icons.smart_toy_rounded, label: 'Asistente'),
    NavItem(icon: Icons.trending_up_rounded, label: 'Inversiones'),
    NavItem(icon: Icons.hub_rounded, label: 'Polos'),
    NavItem(icon: Icons.poll_rounded, label: 'Encuestas'),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        // Pantalla del Asistente IA
        return const AsistenteScreen();
      case 2:
        return const InversionesScreen();
      case 3:
        return const PolosScreen();
      default:
        return Center(
          child: Text(
            _navItems[_selectedIndex].label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        );
    }
  }

  // --- 1. WIDGET DEL BOTÓN (AJOLOTE) ---
  Widget _buildAjoloteFab(BuildContext context) {
    return GestureDetector(
      onTap: () => _openChatModal(context),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF9D2449),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/ajolotito.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // --- 2. LÓGICA DE LA VENTANA FLOTANTE (MODAL) ---
  void _openChatModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Ancho: 450px fijo en escritorio, o 90% en móvil
            final double width = constraints.maxWidth > 600
                ? 450
                : constraints.maxWidth * 0.90;

            // Alto: 700px fijo en pantallas grandes, o 85% en laptops/móviles
            final double height = constraints.maxHeight > 800
                ? 700
                : constraints.maxHeight * 0.85;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  // Opcional: Sombra extra para el modal
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  // Importante: VoiceChatWidget debe tener el LayoutBuilder interno
                  // que te pasé antes para que la imagen de fondo no se corte.
                  child: const VoiceChatWidget(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    // --- MODO ESCRITORIO ---
    if (isDesktop) {
      return Scaffold(
        body: Stack(
          children: [
            Row(
              children: [
                WebSidebar(
                  items: _navItems,
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                  themeProvider: widget.themeProvider,
                ),
                Expanded(child: _buildContent(context)),
              ],
            ),
            // Botón flotante Ajolote (Escritorio)
            Positioned(bottom: 30, right: 30, child: _buildAjoloteFab(context)),
          ],
        ),
      );
    }

    // --- MODO MÓVIL ---
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(context),

          // Botón de configuración (Arriba derecha)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildSettingsButton(context),
          ),

          // Botón flotante Ajolote (Móvil)
          Positioned(bottom: 20, right: 16, child: _buildAjoloteFab(context)),
        ],
      ),
      bottomNavigationBar: MobileBottomNav(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }

  // --- BOTÓN DE CONFIGURACIÓN ---
  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSettingsModal(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF691C32), Color(0xFF4A1525)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF691C32).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // --- MODAL DE CONFIGURACIÓN ---
  void _showSettingsModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2029) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Configuración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),

            // Opción de Tema
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.themeProvider.toggleTheme();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF691C32), Color(0xFF8B2346)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apariencia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDark
                                  ? 'Modo oscuro activado'
                                  : 'Modo claro activado',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Switch visual
                      Container(
                        width: 52,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF691C32).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isDark
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF691C32),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info Row (Pie de página del modal)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFFBC955C).withOpacity(0.9),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Gobierno de México',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Plan México',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
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
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}
