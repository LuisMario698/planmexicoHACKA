import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'shared/widgets/responsive_scaffold.dart';
import 'app_config.dart';
import 'service/encuesta_service.dart';

/// Resetea todos los tutoriales para que vuelvan a aparecer
Future<void> _resetTutorials() async {
  final prefs = await SharedPreferences.getInstance();
  // Lista de todas las keys de tutoriales
  await prefs.remove('tutorial_home_seen');
  await prefs.remove('tutorial_inversiones_seen');
  await prefs.remove('tutorial_info_seen');
  await prefs.remove('polos_tutorial_seen');
  await prefs.remove('polos_state_tutorial_seen');
  await prefs.remove('polos_polo_tutorial_seen');
  await prefs.remove('encuesta_tutorial_seen');
  await prefs.remove('seen_mi_region_tutorial');
  await prefs.remove('seen_module_empleos_tutorial');
  await prefs.remove('seen_module_cursos_tutorial');
  await prefs.remove('seen_module_obras_tutorial');
  await prefs.remove('seen_module_noticias_tutorial');
  await prefs.remove('seen_module_polos_tutorial');
  await prefs.remove('seen_module_eventos_tutorial');
  debugPrint('✅ Tutoriales reseteados');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resetear todos los tutoriales para que vuelvan a aparecer
  await _resetTutorials();

  // Inicializar Supabase si está configurado
  if (SupabaseConfig.isConfigured) {
    await EncuestaService.initialize(
      supabaseUrl: SupabaseConfig.supabaseUrl,
      supabaseAnonKey: SupabaseConfig.supabaseAnonKey,
    );
  } else {
    debugPrint(
      '⚠️ Supabase no configurado. Edita lib/app_config.dart con tus credenciales.',
    );
  }

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Plan México',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeProvider.themeMode,
          home: ResponsiveScaffold(themeProvider: _themeProvider),
        );
      },
    );
  }
}
