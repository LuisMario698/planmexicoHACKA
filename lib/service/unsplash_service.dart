/// Servicio para obtener imágenes reales de Unsplash según el sector
class UnsplashService {
  // URLs de imágenes REALES de Unsplash por sector (verificadas)
  static const Map<String, String> _sectorImages = {
    'transporte': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800&q=80',
    'electricidad': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=800&q=80',
    'cfe': 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=800&q=80',
    'agua': 'https://images.unsplash.com/photo-1541844053589-346841d0b34c?w=800&q=80',
    'turismo': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80',
    'inmobiliario': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80',
    'telecom': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
    'hidrocarburos': 'https://images.unsplash.com/photo-1518709766631-a6a7f45921c3?w=800&q=80',
    'pemex': 'https://images.unsplash.com/photo-1518709766631-a6a7f45921c3?w=800&q=80',
    'social': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80',
    'industria': 'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?w=800&q=80',
    'manufactura': 'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?w=800&q=80',
    'salud': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&q=80',
    'educacion': 'https://images.unsplash.com/photo-1562774053-701939374585?w=800&q=80',
    'energia': 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800&q=80',
    'construccion': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=80',
    'medio ambiente': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
  };

  // Imagen por defecto (edificios de negocios)
  static const String _defaultImage = 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80';

  /// Obtiene URL de imagen real según el sector
  static String getImageForSector(String sector) {
    final s = sector.toLowerCase();
    
    for (final entry in _sectorImages.entries) {
      if (s.contains(entry.key)) {
        return entry.value;
      }
    }
    
    return _defaultImage;
  }

  /// Imágenes reales para el carrusel principal
  static const List<String> carouselImages = [
    'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=1200&q=80', // Paneles solares
    'https://images.unsplash.com/photo-1565793298595-6a879b1d9492?w=1200&q=80', // Fábrica moderna
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=1200&q=80', // Logística/almacén
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=1200&q=80', // Construcción
  ];

  /// Obtiene imagen del carrusel por índice
  static String getCarouselImage(int index) {
    return carouselImages[index % carouselImages.length];
  }
}
