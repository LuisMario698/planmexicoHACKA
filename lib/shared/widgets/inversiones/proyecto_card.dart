import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../service/inversiones_service.dart';

/// Card individual de proyecto de inversión
class ProyectoCard extends StatelessWidget {
  final ProyectoInversion proyecto;
  final VoidCallback? onTap;
  
  const ProyectoCard({
    super.key,
    required this.proyecto,
    this.onTap,
  });

  /// Obtiene el ícono según el sector
  IconData _getIconForSector(String sector) {
    switch (sector.toLowerCase()) {
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'electricidad':
        return Icons.bolt_rounded;
      case 'agua y medio ambiente':
        return Icons.water_drop_rounded;
      case 'inmobiliario y turismo':
        return Icons.beach_access_rounded;
      case 'telecomunicaciones':
        return Icons.cell_tower_rounded;
      case 'hidrocarburos':
        return Icons.oil_barrel_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.business_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;
    
    // Tamaños responsivos
    final bool isExtraSmall = screenWidth < 400;
    final bool isSmall = screenWidth >= 400 && screenWidth < 600;
    
    final double iconSize = isExtraSmall ? 16 : (isSmall ? 18 : (isDesktop ? 22 : 20));
    final double iconPadding = isExtraSmall ? 6 : (isSmall ? 8 : 10);
    final double cardPadding = isExtraSmall ? 8 : (isSmall ? 10 : (isDesktop ? 16 : 12));
    final double titleSize = isExtraSmall ? 11 : (isSmall ? 12 : (isDesktop ? 14 : 13));
    final double montoSize = isExtraSmall ? 12 : (isSmall ? 14 : (isDesktop ? 18 : 15));
    final double sectorFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    final double descFontSize = isExtraSmall ? 8 : (isSmall ? 9 : 10);
    final double tipoFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxHeight < 180;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(isExtraSmall ? 10 : 14),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.08) 
                  : const Color(0xFFE8E8E8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(isExtraSmall ? 10 : 14),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono y sector
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(iconPadding),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(isExtraSmall ? 6 : 10),
                          ),
                          child: Icon(
                            _getIconForSector(proyecto.sector),
                            color: AppTheme.primaryColor,
                            size: iconSize,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isExtraSmall ? 4 : 6, 
                              vertical: isExtraSmall ? 2 : 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              proyecto.sector,
                              style: TextStyle(
                                fontSize: sectorFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isCompact ? 4 : 8),

                    // Título
                    Text(
                      proyecto.proyecto,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.lightText,
                        height: 1.2,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Descripción
                    if (!isCompact && proyecto.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        proyecto.descripcion,
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Espacio flexible
                    const Expanded(child: SizedBox(height: 4)),

                    // Monto
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        proyecto.montoFormateado,
                        style: TextStyle(
                          fontSize: montoSize,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 2 : 6),

                    // Tipo de proyecto
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: isExtraSmall ? 10 : 12,
                          color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            proyecto.tipoProyecto.isNotEmpty 
                                ? proyecto.tipoProyecto 
                                : 'Sin clasificar',
                            style: TextStyle(
                              fontSize: tipoFontSize,
                              color: isDark ? Colors.white54 : AppTheme.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
