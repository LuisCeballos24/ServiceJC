import 'package:flutter/material.dart';
// ¡Corrección! Usamos el modelo correcto
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/screens/servicios_screen.dart'; // Importa la pantalla genérica de servicios
import 'package:servicejc/services/servicio_service.dart';

class WelcomeClientScreen extends StatefulWidget {
  const WelcomeClientScreen({super.key});

  @override
  State<WelcomeClientScreen> createState() => _WelcomeClientScreenState();
}

class _WelcomeClientScreenState extends State<WelcomeClientScreen> {
  // ¡Corrección! Usamos el tipo de lista correcto
  late Future<List<ServiceModel>> _futureServicios;

  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos de los servicios cuando se crea la pantalla
    _futureServicios = ServicioService().fetchServicios();
  }

  // Método para asignar un ícono según el nombre del servicio
  IconData _getServiceIcon(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'electricidad':
        return Icons.electrical_services_rounded;
      case 'plomería':
        return Icons.plumbing_rounded;
      case 'carpintería':
        return Icons.carpenter_rounded;
      case 'jardinería':
        return Icons.yard_rounded;
      case 'limpieza':
        return Icons.cleaning_services_rounded;
      case 'cerrajería':
        return Icons.lock_open_rounded;
      default:
        return Icons.build_circle_rounded;
    }
  }

  // Método para asignar un color según el nombre del servicio
  Color _getServiceColor(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'electricidad':
        return const Color.fromRGBO(52, 152, 219, 1);
      case 'plomería':
        return const Color.fromRGBO(39, 174, 96, 1);
      case 'carpintería':
        return const Color.fromRGBO(243, 156, 18, 1);
      case 'jardinería':
        return const Color.fromRGBO(142, 68, 173, 1);
      case 'limpieza':
        return const Color.fromRGBO(231, 76, 60, 1);
      case 'cerrajería':
        return const Color.fromRGBO(189, 195, 199, 1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ServiceJC',
          style: TextStyle(
            color: Color.fromRGBO(52, 73, 94, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '¿Qué servicio necesitas hoy?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(52, 73, 94, 1),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora las categorías para encontrar al técnico ideal.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Expanded(
              // ¡Corrección! Usamos el tipo de FutureBuilder correcto
              child: FutureBuilder<List<ServiceModel>>(
                future: _futureServicios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se encontraron servicios.'));
                  } else {
                    final servicios = snapshot.data!;
                    return LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final double screenWidth = constraints.maxWidth;
                        final int crossAxisCount = (screenWidth / 200).floor();

                        return GridView.count(
                          crossAxisCount: crossAxisCount > 2 ? crossAxisCount : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: servicios.map((servicio) {
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ¡Corrección! Usamos el tipo de modelo correcto para el parámetro
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
}