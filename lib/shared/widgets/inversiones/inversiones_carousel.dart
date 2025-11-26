import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Carrusel hero de inversiones con auto-scroll
class InversionesCarousel extends StatefulWidget {
  final double height;
  
  const InversionesCarousel({
    super.key,
    this.height = 300,
  });

  @override
  State<InversionesCarousel> createState() => _InversionesCarouselState();
}

class _InversionesCarouselState extends State<InversionesCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'Infraestructura Energética',
      'subtitle': '\$40.2 mil millones USD en inversión',
      'color': '0xFF1565C0',
    },
    {
      'title': 'Manufactura Especializada',
      'subtitle': '1.5 millones de empleos nuevos',
      'color': '0xFF2E7D32',
    },
    {
      'title': 'Nearshoring',
      'subtitle': 'Relocalización de cadenas productivas',
      'color': '0xFF7B1FA2',
    },
    {
      'title': 'Contenido Nacional',
      'subtitle': 'Fortalecimiento de proveedores locales',
      'color': '0xFFE65100',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;
    
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentPage = index);
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) => _buildCarouselItem(
              _carouselItems[index],
              isDesktop,
            ),
          ),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(Map<String, String> item, bool isDesktop) {
    final color = Color(int.parse(item['color']!));
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
            AppTheme.primaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Patrón decorativo
          Positioned(
            right: -50,
            bottom: -50,
            child: Icon(
              Icons.trending_up_rounded,
              size: 200,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(isDesktop ? 40 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'INVERSIÓN ESTRATÉGICA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['title']!,
                  style: TextStyle(
                    fontSize: isDesktop ? 32 : 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['subtitle']!,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_carouselItems.length, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
