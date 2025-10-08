import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/screens/servicios_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/services_grid.dart'; // Importar el mapa de colores

class AllServicesScreen extends StatelessWidget {
  final List<ServiceModel> allServicios;

  const AllServicesScreen({super.key, required this.allServicios});

  // Método para asignar un ícono según el nombre del servicio
  IconData _getServiceIcon(String nombre) {
    // Usamos el mapa de datos centralizado de ServicesGrid para consistencia
    final data = ServicesGrid.getServiceData(nombre);
    return data['icon'] as IconData;
  }

  Color _getServiceColor(String nombre) {
    // Usamos el mapa de datos centralizado de ServicesGrid para consistencia
    final data = ServicesGrid.getServiceData(nombre);
    return data['color'] as Color;
  }

  // Método para crear una tarjeta de servicio
  Widget _buildServiceCard(
    BuildContext context, {
    required ServiceModel servicio,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(
              servicio.nombre,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todas las categorías',
          style: AppTextStyles.h2.copyWith(color: AppColors.cardTitle),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cardTitle),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double screenWidth = constraints.maxWidth;
            final int crossAxisCount = (screenWidth / 200).floor();

            return GridView.count(
              crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: allServicios.map((servicio) {
                return _buildServiceCard(
                  context,
                  servicio: servicio,
                  icon: _getServiceIcon(servicio.nombre),
                  color: _getServiceColor(servicio.nombre),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServiciosScreen(servicio: servicio),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
