import 'package:flutter/material.dart';

class EmpleosScreen extends StatelessWidget {
  const EmpleosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context, isDark, isDesktop),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20,
                  vertical: 24,
                ),
                child: isDesktop
                    ? _buildDesktopLayout(isDark)
                    : _buildMobileLayout(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop) {
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
                      'Empleos',
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
              
              // Stats
              Row(
                children: [
                  Expanded(child: _buildHeaderStat('1,234', 'Empleos')),
                  Expanded(child: _buildHeaderStat('56', 'Empresas')),
                  Expanded(child: _buildHeaderStat('8', 'Polos')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
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

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(isDark),
        const SizedBox(height: 24),
        _buildSectionTitle(isDark, 'Destacados'),
        const SizedBox(height: 12),
        _buildFeaturedJob(isDark, 
          company: 'Tesla Gigafactory',
          position: 'Ingeniero de Producción',
          location: 'Monterrey, N.L.',
          salary: '\$45,000 - \$65,000',
        ),
        const SizedBox(height: 12),
        _buildFeaturedJob(isDark,
          company: 'BMW Group',
          position: 'Técnico en Automatización',
          location: 'San Luis Potosí',
          salary: '\$35,000 - \$50,000',
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(isDark, 'Empleos recientes'),
        const SizedBox(height: 12),
        _buildJobsList(isDark),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle(isDark, 'Destacados'),
                  const SizedBox(height: 12),
                  _buildFeaturedJob(isDark,
                    company: 'Tesla Gigafactory',
                    position: 'Ingeniero de Producción',
                    location: 'Monterrey, N.L.',
                    salary: '\$45,000 - \$65,000',
                  ),
                  const SizedBox(height: 12),
                  _buildFeaturedJob(isDark,
                    company: 'BMW Group',
                    position: 'Técnico en Automatización',
                    location: 'San Luis Potosí',
                    salary: '\$35,000 - \$50,000',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(isDark, 'Empleos recientes'),
                  const SizedBox(height: 12),
                  _buildJobsList(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar empleo...',
                hintStyle: TextStyle(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                  fontSize: 15,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
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

  Widget _buildFeaturedJob(
    bool isDark, {
    required String company,
    required String position,
    required String location,
    required String salary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF691C32).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF691C32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Color(0xFF691C32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF691C32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              Text(
                salary,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF58CC02),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(bool isDark) {
    final jobs = [
      {'company': 'FEMSA', 'position': 'Analista de Datos', 'location': 'Guadalajara', 'time': 'Hace 2h'},
      {'company': 'Cemex', 'position': 'Supervisor de Planta', 'location': 'Monterrey', 'time': 'Hace 5h'},
      {'company': 'Bimbo', 'position': 'Ing. de Calidad', 'location': 'CDMX', 'time': 'Hace 1d'},
      {'company': 'Grupo México', 'position': 'Técnico Minero', 'location': 'Sonora', 'time': 'Hace 1d'},
      {'company': 'Kia Motors', 'position': 'Diseñador Industrial', 'location': 'Nuevo León', 'time': 'Hace 2d'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2029) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: jobs.asMap().entries.map((entry) {
          final index = entry.key;
          final job = entry.value;
          return _buildJobItem(
            isDark,
            company: job['company']!,
            position: job['position']!,
            location: job['location']!,
            time: job['time']!,
            isLast: index == jobs.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobItem(
    bool isDark, {
    required String company,
    required String position,
    required String location,
    required String time,
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.business_rounded,
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$company • $location',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
