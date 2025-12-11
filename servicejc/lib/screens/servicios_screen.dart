import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/models/service_model.dart'; 
import 'package:servicejc/services/servicio_service.dart';
// 💡 La siguiente pantalla es la que contiene la selección de productos/inspección
import 'package:servicejc/screens/productos_screen.dart'; 

// Asumimos que existen AppColors y AppTextStyles en lib/theme/
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServiciosScreen extends StatefulWidget {
  // Recibe la Categoría Principal seleccionada del Nivel 1
  final CategoriaPrincipalModel categoria; 

  const ServiciosScreen({super.key, required this.categoria});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  late Future<List<ServiceModel>> _futureServicios;
  final ServicioService _servicioService = ServicioService();

  @override
  void initState() {
    super.initState();
    // 💡 Filtrar los servicios usando el ID de la Categoría Principal
    _futureServicios = _servicioService.fetchServiciosByCategoriaId(widget.categoria.id);
  }

  void _navigateToProductos(ServiceModel servicio) {
    // Navegación a la Pantalla 3 (ProductosScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pasa el Servicio (Ej: 'Electricidad') a la pantalla de actividades
        builder: (context) => ProductosScreen(servicio: servicio), 
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título de la Categoría Principal
        title: Text(
          widget.categoria.nombre,
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ), 
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.accent),
      ),
      body: FutureBuilder<List<ServiceModel>>(
        future: _futureServicios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar servicios: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron servicios para ${widget.categoria.nombre}.'));
          }

          final servicios = snapshot.data!;

          // Mostrar los Servicios (Electricidad, Plomería, Ebanistería, etc.) en un Grid
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final servicio = servicios[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => _navigateToProductos(servicio),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        servicio.nombre, 
                        textAlign: TextAlign.center,
                        style: AppTextStyles.listTitle.copyWith(color: AppColors.cardTitle),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}