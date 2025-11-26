import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget del banner principal del Home
/// Muestra el logo de Plan México y la imagen de mujeres
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 768;

    // ============================================================
    // ALTURA DEL BANNER - Modifica estos valores para cambiar el tamaño
    // ============================================================
    final bannerHeight = isDesktop
        ? screenHeight * 0.20 + 275 // Desktop
        : screenHeight * 0.30; // Móvil

    final minHeight = isDesktop ? 400.0 : 320.0;
    final finalHeight = bannerHeight < minHeight ? minHeight : bannerHeight;

    return SizedBox(
      height: finalHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con gradiente guinda
          _buildGradientBackground(),

          // Contenido principal - Row con logo y mujeres
          Row(
            children: [
              // Lado izquierdo - Logo y texto
              Expanded(
                flex: isDesktop ? 3 : 4,
                child: _buildLogoSection(isDesktop),
              ),

              // Lado derecho - Imagen de mujeres
              Expanded(
                flex: isDesktop ? 5 : 4,
                child: _buildImageSection(finalHeight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primaryColor,
              Color(0xFF8B2942),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.only(
        left: isDesktop ? 60 : 24,
        right: 20,
        top: 20,
        bottom: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Plan México desde imagen
          Image.asset(
            'assets/images/logo_plan_mexico.png',
            height: isDesktop ? 140 : 100,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo(isDesktop);
            },
          ),

          SizedBox(height: isDesktop ? 20 : 14),

          // Subtítulo
          Text(
            'Estrategia de Desarrollo Económico\nEquitativo y Sustentable para la\nProsperidad Compartida',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(double height) {
    return ClipRect(
      child: Image.asset(
        'assets/images/mujeres.png',
        fit: BoxFit.cover,
        height: height,
        alignment: Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFallbackLogo(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12,
            vertical: isDesktop ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Plan',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.auto_awesome,
                size: isDesktop ? 28 : 20,
                color: AppTheme.primaryDark,
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 4 : 2),
        Text(
          'México',
          style: TextStyle(
            fontSize: isDesktop ? 56 : 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
