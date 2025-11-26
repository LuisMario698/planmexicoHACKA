import 'package:flutter/material.dart';
import '../widgets/home/home_widgets.dart';

/// Pantalla principal del Home - Inicio
/// Presenta información del Plan México de forma moderna y estructurada
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner principal con logo y mujeres
          const HeroBanner(),

          const SizedBox(height: 40),

          // Contenido con padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ¿Qué es el Plan México?
                const WhatIsPlanSection(),

                const SizedBox(height: 40),

                // Objetivos Centrales
                const ObjetivosSection(),

                const SizedBox(height: 40),

                // ¿Por qué es importante?
                const ImportanceSection(),

                const SizedBox(height: 40),

                // Polos de Bienestar
                // const PolosSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
