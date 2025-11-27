import 'package:flutter/material.dart';
import '../data/gamification_data.dart';

class LogrosScreen extends StatelessWidget {
  const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    final profile = GamificationData.demoProfile;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context, isDark, isDesktop, profile),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 24,
                ),
                child: isDesktop
                    ? _buildDesktopLayout(context, isDark, profile)
                    : _buildMobileLayout(context, isDark, profile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop, UserProfile profile) {
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
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Mis Logros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderStat(
                      Icons.star_rounded,
                      '${profile.totalPoints}',
                      'Puntos',
                      const Color(0xFFBC955C),
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderStat(
                      Icons.local_fire_department_rounded,
                      '${profile.currentStreak}',
                      'Racha',
                      const Color(0xFFFF9600),
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderStat(
                      Icons.emoji_events_rounded,
                      '${profile.unlockedMedalsCount}/${GamificationData.medals.length}',
                      'Logros',
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStreakCard(isDark, profile),
        const SizedBox(height: 24),
        _buildSectionTitle(isDark, 'Medallas'),
        const SizedBox(height: 12),
        _buildMedalsGrid(context, isDark, profile),
        const SizedBox(height: 24),
        _buildSectionTitle(isDark, 'Actividad reciente'),
        const SizedBox(height: 12),
        _buildActivityList(isDark),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark, UserProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakCard(isDark, profile),
                  const SizedBox(height: 24),
                  _buildSectionTitle(isDark, 'Actividad reciente'),
                  const SizedBox(height: 12),
                  _buildActivityList(isDark),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(isDark, 'Medallas'),
                  const SizedBox(height: 12),
                  _buildMedalsGrid(context, isDark, profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildStreakCard(bool isDark, UserProfile profile) {
    final hasStreak = profile.currentStreak > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasStreak
              ? const Color(0xFFFF9600).withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: hasStreak
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9600), Color(0xFFFF4B4B)],
                    )
                  : null,
              color: hasStreak ? null : (isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E5E5)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 28,
              color: hasStreak ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasStreak ? '¡Racha de ${profile.currentStreak} días!' : 'Sin racha activa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasStreak
                        ? const Color(0xFFFF9600)
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasStreak
                      ? 'Sigue explorando para mantenerla'
                      : 'Entra mañana para comenzar',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (hasStreak)
            Column(
              children: [
                Text(
                  '${profile.longestStreak}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9600),
                  ),
                ),
                Text(
                  'récord',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMedalsGrid(BuildContext context, bool isDark, UserProfile profile) {
    final unlockedMedals = GamificationData.medals.where((m) {
      final progress = profile.medalProgress.firstWhere(
        (p) => p.medalId == m.id,
        orElse: () => MedalProgress(medalId: m.id, currentProgress: 0, isUnlocked: false),
      );
      return progress.isUnlocked;
    }).toList();

    final lockedMedals = GamificationData.medals.where((m) {
      final progress = profile.medalProgress.firstWhere(
        (p) => p.medalId == m.id,
        orElse: () => MedalProgress(medalId: m.id, currentProgress: 0, isUnlocked: false),
      );
      return !progress.isUnlocked;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ...unlockedMedals.map((m) => _buildMedalItem(context, isDark, m, profile, isUnlocked: true)),
          ...lockedMedals.map((m) => _buildMedalItem(context, isDark, m, profile, isUnlocked: false)),
        ],
      ),
    );
  }

  Widget _buildMedalItem(BuildContext context, bool isDark, Medal medal, UserProfile profile, {required bool isUnlocked}) {
    final progress = profile.medalProgress.firstWhere(
      (p) => p.medalId == medal.id,
      orElse: () => MedalProgress(medalId: medal.id, currentProgress: 0, isUnlocked: false),
    );

    return GestureDetector(
      onTap: () => _showMedalDetail(context, isDark, medal, progress),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? medal.color
                    : (isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isUnlocked
                    ? [BoxShadow(color: medal.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Icon(
                medal.icon,
                size: 26,
                color: isUnlocked ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              medal.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isUnlocked
                    ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                    : (isDark ? Colors.grey[600] : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedalDetail(BuildContext context, bool isDark, Medal medal, MedalProgress progress) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2029) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: progress.isUnlocked
                    ? medal.color
                    : (isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: progress.isUnlocked
                    ? [BoxShadow(color: medal.color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8))]
                    : null,
              ),
              child: Icon(
                medal.icon,
                size: 40,
                color: progress.isUnlocked ? Colors.white : (isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              medal.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              medal.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            if (progress.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF691C32),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '¡Completado!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    '${progress.currentProgress} / ${medal.requiredProgress}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 180,
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progress.currentProgress / medal.requiredProgress).clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF2A3C42) : const Color(0xFFE5E5E5),
                        valueColor: AlwaysStoppedAnimation(medal.color),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(bool isDark) {
    final activities = [
      {'icon': Icons.place_rounded, 'color': const Color(0xFF1CB0F6), 'title': 'Exploraste Polo de Sonora', 'points': 10},
      {'icon': Icons.psychology_rounded, 'color': const Color(0xFFCE82FF), 'title': 'Consultaste al asistente', 'points': 5},
      {'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFFF9600), 'title': '¡Racha de 5 días!', 'points': 50},
      {'icon': Icons.share_rounded, 'color': const Color(0xFF58CC02), 'title': 'Compartiste Tamaulipas', 'points': 15},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return _buildActivityItem(
            isDark,
            icon: activity['icon'] as IconData,
            color: activity['color'] as Color,
            title: activity['title'] as String,
            points: activity['points'] as int,
            isLast: index == activities.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required int points,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFBC955C).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFBC955C), size: 14),
                const SizedBox(width: 4),
                Text(
                  '+$points',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBC955C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
