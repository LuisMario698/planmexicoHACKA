import 'package:flutter/material.dart';
import '../../core/theme/theme_provider.dart';
import '../../web/widgets/web_sidebar.dart';
import '../../mobile/widgets/mobile_bottom_nav.dart';

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
    NavItem(icon: Icons.analytics_rounded, label: 'Datos'),
    NavItem(icon: Icons.hub_rounded, label: 'Polos'),
    NavItem(icon: Icons.poll_rounded, label: 'Encuestas'),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      return Scaffold(
        body: Row(
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
      );
    }

    return Scaffold(
      body: _buildContent(context),
      bottomNavigationBar: MobileBottomNav(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
        themeProvider: widget.themeProvider,
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}
