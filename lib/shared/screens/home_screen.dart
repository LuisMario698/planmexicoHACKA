import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/home/home_widgets.dart';
import '../widgets/ajolote_tutorial.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showTutorial = false;

  final List<String> _tutorialSteps = [
    "¡Hola! Bienvenido al Plan México 2025. Soy Ajo, y seré tu guía en esta plataforma.",
    "Aquí encontrarás la visión estratégica del gobierno, enfocada en prosperidad compartida y soberanía.",
    "Desliza hacia abajo para conocer los objetivos centrales y por qué este plan es vital para el futuro.",
    "Explora las otras pestañas para ver los Proyectos de Inversión y el Mapa interactivo. ¡Comencemos!",
  ];

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  /// Verifica si el usuario ya vio el tutorial
  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('tutorial_home_seen') ?? false;

    if (!seen) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _showTutorial = true);
      }
    }
  }

  /// Cerrar tutorial y guardar que ya se vio
  void _closeTutorial() async {
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_home_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Stack(
      children: [
        // 1. CONTENIDO PRINCIPAL
        Scaffold(
          floatingActionButton: _showTutorial
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    debugPrint("Abrir chat del ajolote");
                  },
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/ajolote.gif',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.smart_toy, color: Colors.pink),
                    ),
                  ),
                ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroBanner(),
                const SizedBox(height: 40),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WhatIsPlanSection(),
                      SizedBox(height: 40),
                      ObjetivosSection(),
                      SizedBox(height: 40),
                      ImportanceSection(),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. CAPA DEL TUTORIAL (si está activo)
        if (_showTutorial)
          AjoloteTutorial(
            steps: _tutorialSteps,
            onComplete: _closeTutorial,
            onSkip: _closeTutorial,
          ),
      ],
    );
  }
}
