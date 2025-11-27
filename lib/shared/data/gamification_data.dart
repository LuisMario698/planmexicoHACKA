import 'package:flutter/material.dart';

/// Modelo de una medalla/logro
class Medal {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredProgress; // Progreso requerido para desbloquear
  final String category; // 'exploracion', 'participacion', 'constancia', 'social'

  const Medal({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredProgress,
    required this.category,
  });
}

/// Progreso del usuario en una medalla
class MedalProgress {
  final String medalId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const MedalProgress({
    required this.medalId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progressPercent => currentProgress / _getMedal(medalId).requiredProgress;

  Medal _getMedal(String id) {
    return GamificationData.medals.firstWhere((m) => m.id == id);
  }
}

/// Perfil del usuario con gamificación
class UserProfile {
  final String name;
  final String email;
  final String avatarUrl;
  final int totalPoints;
  final int currentStreak; // Racha actual en días
  final int longestStreak; // Racha más larga
  final DateTime? lastVisit;
  final String level; // 'ciudadano', 'promotor', 'embajador', 'lider'
  final List<MedalProgress> medalProgress;
  final Map<String, int> stats; // Estadísticas varias

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastVisit,
    this.level = 'ciudadano',
    this.medalProgress = const [],
    this.stats = const {},
  });

  int get unlockedMedalsCount => medalProgress.where((m) => m.isUnlocked).length;
}

/// Datos estáticos de gamificación
class GamificationData {
  // Colores del tema
  static const Color gold = Color(0xFFBC955C);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color guinda = Color(0xFF691C32);

  /// Lista de todas las medallas disponibles
  static const List<Medal> medals = [
    // === EXPLORACIÓN ===
    Medal(
      id: 'explorador_novato',
      name: 'Explorador Novato',
      description: 'Visita tu primer polo de desarrollo',
      icon: Icons.explore_rounded,
      color: Color(0xFF2563EB),
      requiredProgress: 1,
      category: 'exploracion',
    ),
    Medal(
      id: 'conocedor_nacional',
      name: 'Conocedor Nacional',
      description: 'Visita polos en 5 estados diferentes',
      icon: Icons.map_rounded,
      color: Color(0xFF16A34A),
      requiredProgress: 5,
      category: 'exploracion',
    ),
    Medal(
      id: 'experto_noroeste',
      name: 'Experto Noroeste',
      description: 'Explora todos los polos de la región Noroeste',
      icon: Icons.terrain_rounded,
      color: Color(0xFFF59E0B),
      requiredProgress: 4,
      category: 'exploracion',
    ),
    Medal(
      id: 'cartografo',
      name: 'Cartógrafo',
      description: 'Visita 15 polos de desarrollo',
      icon: Icons.public_rounded,
      color: Color(0xFF8B5CF6),
      requiredProgress: 15,
      category: 'exploracion',
    ),

    // === PARTICIPACIÓN ===
    Medal(
      id: 'voz_del_pueblo',
      name: 'Voz del Pueblo',
      description: 'Envía tu primera opinión sobre un polo',
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFEC4899),
      requiredProgress: 1,
      category: 'participacion',
    ),
    Medal(
      id: 'ciudadano_informado',
      name: 'Ciudadano Informado',
      description: 'Lee sobre los 13 objetivos del Plan México',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF0EA5E9),
      requiredProgress: 13,
      category: 'participacion',
    ),
    Medal(
      id: 'curioso',
      name: 'Curioso',
      description: 'Haz 10 preguntas al asistente virtual',
      icon: Icons.psychology_rounded,
      color: Color(0xFF14B8A6),
      requiredProgress: 10,
      category: 'participacion',
    ),
    Medal(
      id: 'inversor_potencial',
      name: 'Inversor Potencial',
      description: 'Consulta la sección de inversiones 5 veces',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF22C55E),
      requiredProgress: 5,
      category: 'participacion',
    ),

    // === CONSTANCIA ===
    Medal(
      id: 'madrugador',
      name: 'Madrugador',
      description: 'Entra a la app 7 días consecutivos',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFF97316),
      requiredProgress: 7,
      category: 'constancia',
    ),
    Medal(
      id: 'dedicado',
      name: 'Dedicado',
      description: 'Mantén una racha de 30 días',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEF4444),
      requiredProgress: 30,
      category: 'constancia',
    ),
    Medal(
      id: 'comprometido',
      name: 'Comprometido',
      description: 'Mantén una racha de 100 días',
      icon: Icons.diamond_rounded,
      color: Color(0xFFBC955C),
      requiredProgress: 100,
      category: 'constancia',
    ),

    // === SOCIAL ===
    Medal(
      id: 'embajador',
      name: 'Embajador',
      description: 'Comparte información de 5 polos diferentes',
      icon: Icons.share_rounded,
      color: Color(0xFF6366F1),
      requiredProgress: 5,
      category: 'social',
    ),
    Medal(
      id: 'influencer',
      name: 'Influencer del Cambio',
      description: 'Comparte información 20 veces',
      icon: Icons.campaign_rounded,
      color: Color(0xFFD946EF),
      requiredProgress: 20,
      category: 'social',
    ),
    Medal(
      id: 'patriota_digital',
      name: 'Patriota Digital',
      description: 'Completa tu perfil al 100%',
      icon: Icons.verified_rounded,
      color: Color(0xFF691C32),
      requiredProgress: 1,
      category: 'social',
    ),
  ];

  /// Niveles del usuario
  static const Map<String, Map<String, dynamic>> levels = {
    'ciudadano': {
      'name': 'Ciudadano',
      'minPoints': 0,
      'icon': Icons.person_rounded,
      'color': Color(0xFF6B7280),
    },
    'promotor': {
      'name': 'Promotor',
      'minPoints': 500,
      'icon': Icons.star_rounded,
      'color': Color(0xFF2563EB),
    },
    'embajador': {
      'name': 'Embajador',
      'minPoints': 2000,
      'icon': Icons.workspace_premium_rounded,
      'color': Color(0xFFBC955C),
    },
    'lider': {
      'name': 'Líder del Cambio',
      'minPoints': 5000,
      'icon': Icons.military_tech_rounded,
      'color': Color(0xFF691C32),
    },
  };

  /// Puntos por acción
  static const Map<String, int> pointsPerAction = {
    'visit_polo': 10,
    'ask_assistant': 5,
    'share_polo': 15,
    'daily_login': 20,
    'complete_profile': 50,
    'send_opinion': 25,
    'read_objective': 10,
    'visit_investments': 5,
  };

  /// Perfil de ejemplo/demo
  static UserProfile get demoProfile => UserProfile(
    name: 'Usuario Demo',
    email: 'usuario@planmexico.gob.mx',
    totalPoints: 850,
    currentStreak: 5,
    longestStreak: 12,
    lastVisit: DateTime.now(),
    level: 'promotor',
    medalProgress: [
      const MedalProgress(
        medalId: 'explorador_novato',
        currentProgress: 1,
        isUnlocked: true,
        unlockedAt: null,
      ),
      const MedalProgress(
        medalId: 'conocedor_nacional',
        currentProgress: 3,
        isUnlocked: false,
      ),
      const MedalProgress(
        medalId: 'madrugador',
        currentProgress: 5,
        isUnlocked: false,
      ),
      const MedalProgress(
        medalId: 'curioso',
        currentProgress: 7,
        isUnlocked: false,
      ),
      const MedalProgress(
        medalId: 'voz_del_pueblo',
        currentProgress: 1,
        isUnlocked: true,
      ),
      const MedalProgress(
        medalId: 'embajador',
        currentProgress: 2,
        isUnlocked: false,
      ),
    ],
    stats: {
      'polos_visitados': 8,
      'estados_explorados': 3,
      'preguntas_asistente': 7,
      'compartidos': 2,
      'opiniones': 1,
    },
  );
}
