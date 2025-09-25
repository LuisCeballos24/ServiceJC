import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/screens/servicios_screen.dart';

class ServicesGrid extends StatelessWidget {
  final Future<List<ServiceModel>> futureServicios;
  final bool isLargeScreen;

  const ServicesGrid({
    super.key,
    required this.futureServicios,
    required this.isLargeScreen,
  });

  // Colores basados en el logo
  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFFFD700);

  // Mapa de íconos y colores para los servicios
  final Map<String, dynamic> _servicioData = const {
    'electricidad': {'icon': Icons.power_rounded, 'color': Color(0xFFFFB300)},
    'plomería': {'icon': Icons.plumbing_rounded, 'color': Color(0xFF1976D2)},
    'instalaciones menores': {'icon': Icons.handyman_rounded, 'color': Color(0xFF6D4C41)},
    'aire acondicionado (instalación y mantenimiento)': {'icon': Icons.ac_unit_rounded, 'color': Color(0xFF4DD0E1)},
    'pintores': {'icon': Icons.format_paint_rounded, 'color': Color(0xFFD32F2F)},
    'ebanistas': {'icon': Icons.chair_rounded, 'color': Color(0xFF795548)},
    'soldadura': {'icon': Icons.construction_rounded, 'color': Color(0xFF424242)},
    'aluminio y vidrio': {'icon': Icons.apps_rounded, 'color': Color(0xFF757575)},
    'cielo raso': {'icon': Icons.roofing_rounded, 'color': Color(0xFF8D6E63)},
    'instalaciones decorativas': {'icon': Icons.star_rounded, 'color': Color(0xFFE57373)},
    'revestimientos de piso y paredes': {'icon': Icons.square_foot_rounded, 'color': Color(0xFF4CAF50)},
    'remodelaciones': {'icon': Icons.home_repair_service_rounded, 'color': Color(0xFF607D8B)},
    'construcción': {'icon': Icons.engineering_rounded, 'color': Color(0xFF37474F)},
    'mantenimientos preventivos': {'icon': Icons.settings_rounded, 'color': Color(0xFF26A69A)},
    'limpieza textil': {'icon': Icons.cleaning_services_rounded, 'color': Color(0xFF8D6E63)},
    'limpieza de sillones': {'icon': Icons.weekend_rounded, 'color': Color(0xFFBCAAA4)},
    'limpieza de cocinas': {'icon': Icons.kitchen_rounded, 'color': Color(0xFF8D6E63)},
    'limpieza de baños': {'icon': Icons.bathroom_rounded, 'color': Color(0xFF4527A0)},
    'limpieza de recamaras': {'icon': Icons.bed_rounded, 'color': Color(0xFFBDBDBD)},
    'limpieza general de vivienda': {'icon': Icons.house_rounded, 'color': Color(0xFF607D8B)},
    'limpieza de estacionamientos con hidrolavadora': {'icon': Icons.local_parking_rounded, 'color': Color(0xFF78909C)},
    'limpieza de canales de techado': {'icon': Icons.roofing_rounded, 'color': Color(0xFF8D6E63)},
    'chefs': {'icon': Icons.restaurant_menu_rounded, 'color': Color(0xFFD32F2F)},
    'saloneros': {'icon': Icons.person_rounded, 'color': Color(0xFFD32F2F)},
    'bartender': {'icon': Icons.local_bar_rounded, 'color': Color(0xFFD32F2F)},
    'decoraciones para fiestas': {'icon': Icons.cake_rounded, 'color': Color(0xFFD32F2F)},
    'trabajos de repello bofo de edificios': {'icon': Icons.home_work_rounded, 'color': Color(0xFF37474F)},
    'trabajos de pintura exterior de edificios': {'icon': Icons.format_paint_rounded, 'color': Color(0xFFD32F2F)},
    'trabajo de limpieza de vidrio y cambio de silicón de ventanas': {'icon': Icons.cleaning_services_rounded, 'color': Color(0xFFBCAAA4)},
    'inspecciones con dron profesional': {'icon': Icons.airplanemode_on_rounded, 'color': Color(0xFF757575)},
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceModel>>(
      future: futureServicios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accentColor));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.hasData) {
          final servicios = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLargeScreen ? 4 : 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2,
            ),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final servicio = servicios[index];
              final data = _servicioData[servicio.nombre.toLowerCase()] ?? {'icon': Icons.construction_rounded, 'color': Colors.white};

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiciosScreen(servicio: servicio),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(data['icon'], color: data['color'], size: 40),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          servicio.nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No hay servicios disponibles.', style: TextStyle(color: Colors.white)));
        }
      },
    );
  }
}