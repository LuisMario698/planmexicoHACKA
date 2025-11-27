import 'package:flutter/material.dart';
import '../data/polos_data.dart';
import '../widgets/mexico_map_widget.dart';

/// Widget de infografía para compartir información de un polo
/// Se diseña para verse bien como imagen estática
class PoloInfografiaWidget extends StatelessWidget {
  final PoloInfo polo;
  final PoloMarker? poloData;

  const PoloInfografiaWidget({
    super.key,
    required this.polo,
    this.poloData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF691C32), // Guinda
            Color(0xFF4A1525), // Guinda oscuro
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con logo
          _buildHeader(),
          const SizedBox(height: 20),
          
          // Nombre del polo
          _buildPoloName(),
          const SizedBox(height: 16),
          
          // Info del estado y tipo
          _buildLocationAndType(),
          const SizedBox(height: 20),
          
          // Sectores clave
          if (poloData != null && poloData!.sectoresClave.isNotEmpty) ...[
            _buildSectores(),
            const SizedBox(height: 16),
          ],
          
          // Datos clave
          if (poloData != null) _buildDatosClave(),
          
          const SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan México',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Polo de Desarrollo',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Escudo de México (simplificado)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFFBC955C),
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              '🇲🇽',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPoloName() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF691C32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF691C32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  polo.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndType() {
    String tipoLabel = '';
    Color tipoColor = const Color(0xFF691C32);
    IconData tipoIcon = Icons.info_outline;
    
    if (poloData != null) {
      switch (poloData!.tipo) {
        case 'nuevo':
          tipoLabel = 'Nuevo Polo';
          tipoColor = const Color(0xFF16A34A);
          tipoIcon = Icons.new_releases_rounded;
          break;
        case 'en_marcha':
          tipoLabel = 'En Marcha';
          tipoColor = const Color(0xFF2563EB);
          tipoIcon = Icons.play_circle_rounded;
          break;
        case 'en_proceso':
          tipoLabel = 'En Proceso';
          tipoColor = const Color(0xFFF59E0B);
          tipoIcon = Icons.pending_rounded;
          break;
        case 'tercera_etapa':
          tipoLabel = 'Tercera Etapa';
          tipoColor = const Color(0xFF8B5CF6);
          tipoIcon = Icons.autorenew_rounded;
          break;
        default:
          tipoLabel = poloData!.tipo;
      }
    }

    return Row(
      children: [
        // Estado
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.map_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    polo.estado,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tipo
        if (tipoLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: tipoColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tipoIcon,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  tipoLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSectores() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.factory_rounded,
                color: Color(0xFFBC955C),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Sectores Clave',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBC955C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: poloData!.sectoresClave.take(4).map((sector) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sector,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosClave() {
    final items = <_DatoItem>[];
    
    if (poloData!.vocacion.isNotEmpty) {
      items.add(_DatoItem(
        icon: Icons.lightbulb_outline_rounded,
        label: 'Vocación',
        value: poloData!.vocacion,
      ));
    }
    
    if (poloData!.empleoEstimado.isNotEmpty) {
      items.add(_DatoItem(
        icon: Icons.people_outline_rounded,
        label: 'Empleo',
        value: poloData!.empleoEstimado,
      ));
    }
    
    if (poloData!.region.isNotEmpty) {
      items.add(_DatoItem(
        icon: Icons.public_rounded,
        label: 'Región',
        value: poloData!.region,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.phone_android_rounded,
            color: Color(0xFFBC955C),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Descarga la app ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const Text(
            'Plan México',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFBC955C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '#PlanMéxico',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoItem {
  final IconData icon;
  final String label;
  final String value;

  _DatoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
