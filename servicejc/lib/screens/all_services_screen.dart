import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/screens/servicios_screen.dart';

class AllServicesScreen extends StatelessWidget {
  final List<ServiceModel> allServicios;

  const AllServicesScreen({super.key, required this.allServicios});

  // Método para asignar un ícono según el nombre del servicio
  IconData _getServiceIcon(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'electricidad':
        return Icons.power_rounded;
      case 'plomería':
        return Icons.plumbing_rounded;
      case 'instalaciones menores':
        return Icons.handyman_rounded;
      case 'aire acondicionado (instalación y mantenimiento)':
        return Icons.ac_unit_rounded;
      case 'pintores':
        return Icons.format_paint_rounded;
      case 'ebanistas':
        return Icons.chair_rounded;
      case 'soldadura':
        return Icons.engineering_rounded;
      case 'aluminio y vidrio':
        return Icons.window_rounded;
      case 'cielo raso':
        return Icons.roofing_rounded;
      case 'instalaciones decorativas':
        return Icons.design_services_rounded;
      case 'revestimientos de piso y paredes':
        return Icons.layers_rounded;
      case 'remodelaciones':
        return Icons.construction_rounded;
      case 'construcción':
        return Icons.apartment_rounded;
      case 'mantenimientos preventivos':
        return Icons.build_circle_rounded;
      case 'limpieza de sillones':
        return Icons.cleaning_services_rounded;
      case 'limpieza de áreas':
        return Icons.wash_rounded;
      case 'chefs':
        return Icons.restaurant_menu_rounded;
      case 'salonerros':
        return Icons.room_service_rounded;
      case 'bartender':
        return Icons.local_bar_rounded;
      case 'decoraciones':
        return Icons.cake_rounded;
      case 'otros':
        return Icons.more_horiz_rounded;
      default:
        return Icons.help_outline;
    }
  }

  // Método para asignar un color según el nombre del servicio
  Color _getServiceColor(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'electricidad':
        return Colors.amber[700]!;
      case 'plomería':
        return Colors.blue[600]!;
      case 'instalaciones menores':
        return Colors.brown[400]!;
      case 'aire acondicionado (instalación y mantenimiento)':
        return Colors.cyan[400]!;
      case 'pintores':
        return Colors.pink[400]!;
      case 'ebanistas':
        return Colors.brown[700]!;
      case 'soldadura':
        return Colors.grey[700]!;
      case 'aluminio y vidrio':
        return Colors.blueGrey[400]!;
      case 'cielo raso':
        return Colors.orange[400]!;
      case 'instalaciones decorativas':
        return Colors.purple[400]!;
      case 'revestimientos de piso y paredes':
        return Colors.teal[400]!;
      case 'remodelaciones':
        return Colors.red[400]!;
      case 'construcción':
        return Colors.green[400]!;
      case 'mantenimientos preventivos':
        return Colors.lime[600]!;
      case 'limpieza de sillones':
        return Colors.indigo[400]!;
      case 'limpieza de áreas':
        return Colors.lightBlue[400]!;
      case 'chefs':
        return Colors.orange[700]!;
      case 'salonerros':
        return Colors.deepOrange[400]!;
      case 'bartender':
        return Colors.lightGreen[600]!;
      case 'decoraciones':
        return Colors.pink[300]!;
      case 'otros':
        return Colors.grey[500]!;
      default:
        return Colors.black;
    }
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
          color: color.withOpacity(0.1),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
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
        title: const Text(
          'Todas las categorías',
          style: TextStyle(
            color: Color.fromRGBO(52, 73, 94, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(52, 73, 94, 1),
          ),
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
                        builder: (context) => ServiciosScreen(servicio: servicio),
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