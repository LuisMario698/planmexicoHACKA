import 'package:flutter/material.dart';

class AppTheme {
  // Colores oficiales del Gobierno de México
  static const Color primaryColor = Color(0xFF691C32);      // Guinda/Vino institucional
  static const Color primaryDark = Color(0xFF4A1525);       // Guinda oscuro
  static const Color primaryLight = Color(0xFF8B2346);      // Guinda claro
  static const Color accentColor = Color(0xFFBC955C);       // Dorado/Bronce (acentos)

  // Colores para tema oscuro
  static const Color darkBackground = Color(0xFF13151A);
  static const Color darkSurface = Color(0xFF1E2029);
  static const Color darkCard = Color(0xFF262830);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkDivider = Color(0xFF3A3D47);

  // Colores para tema claro
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // ============ TEMA OSCURO ============
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          surface: darkSurface,
          onSurface: darkText,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: darkText,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: darkDivider,
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: darkTextSecondary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkTextSecondary),
        ),
      );

  // ============ TEMA CLARO ============
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          surface: lightSurface,
          onSurface: lightText,
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightSurface,
          foregroundColor: lightText,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: lightDivider,
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: lightTextSecondary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: lightText),
          bodyMedium: TextStyle(color: lightTextSecondary),
        ),
      );
}
