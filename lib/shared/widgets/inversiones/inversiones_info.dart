import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../service/inversiones_service.dart';

class InversionesInfo extends StatelessWidget {
  final ProyectoInversion proyecto;

  const InversionesInfo({super.key, required this.proyecto});

  // Función para abrir URL oficial
  Future<void> _launchUrl() async {
    // 1. Limpiar la URL de espacios vacíos
    final String urlString = proyecto.url.trim();

    if (urlString.isEmpty) return;

    // 2. Asegurar que Uri la pueda procesar
    final Uri? url = Uri.tryParse(urlString);

    if (url != null) {
      try {
        // 3. Intentar abrir. Si falla 'externalApplication', intentar sin modo específico
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          // Fallback: intentar abrir sin forzar navegador externo
          await launchUrl(url);
        }
      } catch (e) {
        debugPrint('❌ Error lanzando URL: $e');
      }
    } else {
      debugPrint('❌ URL inválida: $urlString');
    }
  }

  IconData _getIconForSector(String sector) {
    final s = sector.toLowerCase();
    if (s.contains('transporte')) return Icons.directions_bus_rounded;
    if (s.contains('electricidad')) return Icons.bolt_rounded;
    if (s.contains('agua')) return Icons.water_drop_rounded;
    if (s.contains('turismo')) return Icons.beach_access_rounded;
    if (s.contains('telecom')) return Icons.cell_tower_rounded;
    if (s.contains('hidrocarburos')) return Icons.oil_barrel_rounded;
    if (s.contains('social')) return Icons.people_rounded;
    return Icons.business_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.lightText;
    final labelColor = isDark ? Colors.white54 : AppTheme.lightTextSecondary;
    final primaryColor = AppTheme.primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? size.width * 0.2 : 16,
        vertical: isDesktop ? size.height * 0.1 : 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconForSector(proyecto.sector),
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proyecto.sector.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proyecto.proyecto,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: labelColor),
                  ),
                ],
              ),
            ),

            // --- BODY SCROLLABLE ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Inversión',
                            proyecto.montoFormateado,
                            primaryColor,
                            labelColor,
                          ),
                          _buildVerticalDivider(isDark),
                          _buildStatItem(
                            'Etapa',
                            proyecto.etapa,
                            textColor,
                            labelColor,
                          ),
                          if (isDesktop) ...[
                            _buildVerticalDivider(isDark),
                            _buildStatItem(
                              'Moneda',
                              proyecto.moneda.isEmpty ? 'MXN' : proyecto.moneda,
                              textColor,
                              labelColor,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Descripción del Proyecto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      proyecto.descripcion.isNotEmpty
                          ? proyecto.descripcion
                          : 'Sin descripción detallada.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF555555),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Divider(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Detalles Técnicos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _buildDetailRow(
                          Icons.map_rounded,
                          'Ubicación',
                          proyecto.estados,
                          isDark,
                          isDesktop,
                          textColor,
                          labelColor,
                        ),
                        _buildDetailRow(
                          Icons.category_outlined,
                          'Subsector',
                          proyecto.subsector,
                          isDark,
                          isDesktop,
                          textColor,
                          labelColor,
                        ),
                        _buildDetailRow(
                          Icons.business_outlined,
                          'Tipo',
                          proyecto.tipoProyecto,
                          isDark,
                          isDesktop,
                          textColor,
                          labelColor,
                        ),
                        _buildDetailRow(
                          Icons.account_balance_rounded,
                          'Entidad',
                          proyecto.entidadResponsable,
                          isDark,
                          isDesktop,
                          textColor,
                          labelColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- FOOTER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white70
                          : Colors.grey.shade700,
                    ),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 12),
                  // Botón para ir a la URL oficial
                  if (proyecto.url.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _launchUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Ver ficha oficial'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white12 : Colors.grey.shade300,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
    bool isDesktop,
    Color textColor,
    Color labelColor,
  ) {
    if (value.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: isDesktop ? 200 : 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: labelColor.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
