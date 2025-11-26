import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../service/inversiones_service.dart';
import '../../../service/unsplash_service.dart';
import 'inversiones_info.dart'; // Importación necesaria

class ProyectoCard extends StatelessWidget {
  final ProyectoInversion proyecto;
  final VoidCallback? onTap;

  const ProyectoCard({super.key, required this.proyecto, this.onTap});

  IconData _getIconForSector(String sector) {
    final s = sector.toLowerCase();
    if (s.contains('transporte')) return Icons.directions_bus_rounded;
    if (s.contains('electricidad') || s.contains('cfe'))
      return Icons.bolt_rounded;
    if (s.contains('agua')) return Icons.water_drop_rounded;
    if (s.contains('turismo') || s.contains('inmobiliario'))
      return Icons.beach_access_rounded;
    if (s.contains('telecom')) return Icons.cell_tower_rounded;
    if (s.contains('hidrocarburos') || s.contains('pemex'))
      return Icons.oil_barrel_rounded;
    if (s.contains('social')) return Icons.people_rounded;
    if (s.contains('industria')) return Icons.factory_rounded;
    return Icons.business_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    final bool isExtraSmall = screenWidth < 400;
    final bool isSmall = screenWidth >= 400 && screenWidth < 600;

    final double iconSize = isExtraSmall
        ? 16
        : (isSmall ? 18 : (isDesktop ? 22 : 20));
    final double cardPadding = isExtraSmall
        ? 8
        : (isSmall ? 10 : (isDesktop ? 16 : 12));
    final double titleSize = isExtraSmall
        ? 11
        : (isSmall ? 12 : (isDesktop ? 14 : 13));
    final double montoSize = isExtraSmall
        ? 12
        : (isSmall ? 14 : (isDesktop ? 18 : 15));
    final double sectorFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    final double descFontSize = isExtraSmall ? 8 : (isSmall ? 9 : 10);
    final double tipoFontSize = isExtraSmall ? 7 : (isSmall ? 8 : 9);
    
    // Obtener imagen de Unsplash según el sector
    final imageUrl = UnsplashService.getImageForSector(proyecto.sector);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxHeight < 180;
        final double imageHeight = isCompact ? 60 : (isExtraSmall ? 70 : (isSmall ? 80 : 100));

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
              // AQUI SE ABRE LA VENTANA EMERGENTE
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (context) => InversionesInfo(proyecto: proyecto),
                );
              },
              borderRadius: BorderRadius.circular(isExtraSmall ? 10 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen de cabecera
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isExtraSmall ? 10 : 14),
                      topRight: Radius.circular(isExtraSmall ? 10 : 14),
                    ),
                    child: SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              child: Icon(
                                _getIconForSector(proyecto.sector),
                                color: Colors.white.withValues(alpha: 0.7),
                                size: iconSize * 2,
                              ),
                            ),
                          ),
                          // Overlay gradiente
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                          // Badge del sector sobre la imagen
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isExtraSmall ? 4 : 6,
                                vertical: isExtraSmall ? 2 : 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getIconForSector(proyecto.sector),
                                    color: Colors.white,
                                    size: isExtraSmall ? 10 : 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    proyecto.sector.length > 15 
                                        ? '${proyecto.sector.substring(0, 15)}...' 
                                        : proyecto.sector,
                                    style: TextStyle(
                                      fontSize: sectorFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Contenido de la tarjeta
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                color: isDark
                                    ? Colors.white60
                                    : AppTheme.lightTextSecondary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const Spacer(),

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
                                color: isDark
                                    ? Colors.white54
                                    : AppTheme.lightTextSecondary,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  proyecto.tipoProyecto.isNotEmpty
                                      ? proyecto.tipoProyecto
                                      : 'Sin clasificar',
                                  style: TextStyle(
                                    fontSize: tipoFontSize,
                                    color: isDark
                                        ? Colors.white54
                                        : AppTheme.lightTextSecondary,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
