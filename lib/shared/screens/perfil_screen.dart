import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../service/user_session_service.dart';
import 'registro_screen.dart';
import 'logros_screen.dart';
import 'empleos_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final UserSessionService _sessionService = UserSessionService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    // Si no está logueado, mostrar pantalla de registro
    if (!_sessionService.isLoggedIn) {
      return _buildRegistrationPrompt(context, isDark, isDesktop);
    }

    // Si está logueado, mostrar perfil
    return _buildProfileScreen(context, isDark, isDesktop);
  }

  // --- PANTALLA CUANDO NO ESTÁ REGISTRADO ---
  Widget _buildRegistrationPrompt(BuildContext context, bool isDark, bool isDesktop) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context, isDark, isDesktop, isRegistered: false),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 60 : 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono grande
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF691C32), Color(0xFF4A1525)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF691C32).withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título
                    Text(
                      '¡Regístrate para acceder!',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    Text(
                      'Para acceder a tu perfil, ver tus logros y explorar oportunidades de empleo, necesitas registrarte primero.',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: isDark 
                            ? Colors.white.withOpacity(0.7) 
                            : const Color(0xFF666666),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Beneficios
                    _buildBenefitsList(isDark),
                    const SizedBox(height: 40),
                    
                    // Botón de registro
                    SizedBox(
                      width: isDesktop ? 300 : double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToRegistration(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF691C32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF691C32).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person_add_rounded, size: 22),
                            SizedBox(width: 12),
                            Text(
                              'Registrarme ahora',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(bool isDark) {
    final benefits = [
      {'icon': Icons.emoji_events_rounded, 'text': 'Desbloquea logros y medallas'},
      {'icon': Icons.work_rounded, 'text': 'Accede a ofertas de empleo'},
      {'icon': Icons.trending_up_rounded, 'text': 'Sigue tu progreso'},
      {'icon': Icons.star_rounded, 'text': 'Acumula puntos y recompensas'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFFBC955C).withOpacity(0.15) 
                      : const Color(0xFFBC955C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: const Color(0xFFBC955C),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroScreen(),
      ),
    ).then((_) {
      // Refresh the state when returning from registration
      setState(() {});
    });
  }

  // --- PANTALLA CUANDO ESTÁ REGISTRADO ---
  Widget _buildProfileScreen(BuildContext context, bool isDark, bool isDesktop) {
    final userData = _sessionService.currentUser!;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context, isDark, isDesktop, isRegistered: true),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 24,
              ),
              child: isDesktop
                  ? _buildDesktopProfileLayout(context, isDark, userData)
                  : _buildMobileProfileLayout(context, isDark, userData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProfileLayout(BuildContext context, bool isDark, UserData userData) {
    return Column(
      children: [
        _buildUserInfoCard(isDark, userData),
        const SizedBox(height: 20),
        _buildMenuCard(context, isDark),
        const SizedBox(height: 20),
        _buildStatsCard(isDark),
      ],
    );
  }

  Widget _buildDesktopProfileLayout(BuildContext context, bool isDark, UserData userData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda - Info usuario
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildUserInfoCard(isDark, userData),
              const SizedBox(height: 20),
              _buildStatsCard(isDark),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Columna derecha - Menú
        Expanded(
          flex: 1,
          child: _buildMenuCard(context, isDark),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(bool isDark, UserData userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF691C32), Color(0xFF4A1525)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF691C32).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(userData.nombreCompleto),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Nombre
          Text(
            userData.nombreCompleto,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Ubicación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: const Color(0xFFBC955C),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${userData.ciudad}, ${userData.estado}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF666666),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Teléfono
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_rounded,
                size: 18,
                color: const Color(0xFFBC955C),
              ),
              const SizedBox(width: 6),
              Text(
                userData.telefono,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white.withOpacity(0.7) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Fecha de registro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFFBC955C).withOpacity(0.15) 
                  : const Color(0xFFBC955C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFFBC955C),
                ),
                const SizedBox(width: 8),
                Text(
                  'Miembro desde ${_formatDate(userData.fechaRegistro)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBC955C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMenuItem(
            context,
            icon: Icons.emoji_events_rounded,
            title: 'Mis Logros',
            subtitle: 'Medallas y racha diaria',
            color: const Color(0xFFBC955C),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogrosScreen()),
            ),
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          
          _buildMenuItem(
            context,
            icon: Icons.work_rounded,
            title: 'Empleos',
            subtitle: 'Oportunidades laborales',
            color: const Color(0xFF691C32),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmpleosScreen()),
            ),
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          
          _buildMenuItem(
            context,
            icon: Icons.notifications_rounded,
            title: 'Notificaciones',
            subtitle: 'Preferencias de alertas',
            color: const Color(0xFF2196F3),
            onTap: () {
              // TODO: Implementar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente...')),
              );
            },
            isDark: isDark,
          ),
          _buildMenuDivider(isDark),
          
          _buildMenuItem(
            context,
            icon: Icons.settings_rounded,
            title: 'Configuración',
            subtitle: 'Ajustes de la app',
            color: const Color(0xFF607D8B),
            onTap: () => _showSettingsModal(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(bool isDark) {
    return Divider(
      color: isDark ? const Color(0xFF2A3C42) : Colors.grey.shade200,
      height: 1,
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3C42) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  isDark,
                  icon: Icons.star_rounded,
                  value: '0',
                  label: 'Puntos',
                  color: const Color(0xFFBC955C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  isDark,
                  icon: Icons.emoji_events_rounded,
                  value: '0/12',
                  label: 'Medallas',
                  color: const Color(0xFF691C32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  isDark,
                  icon: Icons.local_fire_department_rounded,
                  value: '0',
                  label: 'Racha',
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    bool isDark, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  // --- HEADER COMÚN ---
  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop, {required bool isRegistered}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF691C32), Color(0xFF4A1525)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 20,
            vertical: 20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRegistered ? 'Mi Perfil' : 'Perfil',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isRegistered 
                          ? 'Gestiona tu cuenta'
                          : 'Regístrate para continuar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (isRegistered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC955C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFBC955C).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFFBC955C),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Verificado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBC955C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODAL DE CONFIGURACIÓN ---
  void _showSettingsModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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

            // Opción de Tema (Modo oscuro)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  themeProvider.toggleTheme();
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
            const SizedBox(height: 16),

            // Opción de Notificaciones
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificaciones - Próximamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
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
                            colors: [Color(0xFFBC955C), Color(0xFFD4A96A)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
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
                              'Notificaciones',
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
                              'Configura tus alertas',
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
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.black.withOpacity(0.3),
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
                  const Text(
                    'Plan México',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
