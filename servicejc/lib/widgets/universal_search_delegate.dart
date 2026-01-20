import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart'; // Modelo de Servicios (Home)
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/services/servicio_service.dart';
import 'package:servicejc/screens/servicios_screen.dart'; // Pantalla de Productos
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UniversalSearchDelegate extends SearchDelegate {
  final ServicioService _servicioService = ServicioService();
  
  // Si esto es NULL, buscamos en la lista global de SERVICIOS (Home).
  // Si tiene un ID, buscamos PRODUCTOS dentro de ese servicio específico.
  final String? serviceIdContext; 

  UniversalSearchDelegate({this.serviceIdContext});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.accent),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    // Si no hay texto, mostramos fondo oscuro vacío
    if (query.isEmpty) return Container(color: AppColors.secondary);

    return FutureBuilder<List<dynamic>>(
      // 💡 LÓGICA DINÁMICA ACTUALIZADA:
      // 1. Si serviceIdContext tiene valor -> Buscamos PRODUCTOS dentro de ese servicio.
      // 2. Si es NULL -> Buscamos en la lista global de SERVICIOS (fetchCategoriasPrincipales).
      future: serviceIdContext != null 
          ? _servicioService.fetchProductos(serviceIdContext!) 
          : _servicioService.fetchCategoriasPrincipales(), // Esto ahora trae los Servicios
      
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: AppColors.secondary,
            child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            color: AppColors.secondary,
            child: Center(
              child: Text('No se encontraron resultados.', 
                style: AppTextStyles.bodyText.copyWith(color: Colors.white54)),
            ),
          );
        }

        // Filtramos la lista localmente según lo que escribe el usuario
        final results = snapshot.data!.where((item) {
          String nombreItem = '';
          
          if (item is CategoriaPrincipalModel) {
            nombreItem = item.nombre;
          } else if (item is ProductModel) {
            nombreItem = item.nombre;
          }
          
          return nombreItem.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return Container(
          color: AppColors.secondary, // Fondo oscuro
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final item = results[index];

              // --- CASO 1: Es un SERVICIO (Resultado de búsqueda global) ---
              if (item is CategoriaPrincipalModel) {
                return ListTile(
                  leading: const Icon(Icons.work_outline, color: AppColors.accent),
                  title: Text(item.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: const Text("Servicio Disponible", style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    // Al tocar, vamos a la pantalla de productos de ese servicio
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiciosScreen(categoria: item),
                      ),
                    );
                  },
                );
              } 
              
              // --- CASO 2: Es un PRODUCTO (Resultado de búsqueda dentro de un servicio) ---
              else if (item is ProductModel) {
                return ListTile(
                  leading: const Icon(Icons.sell, color: Colors.greenAccent),
                  title: Text(item.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("\$${item.costo.toStringAsFixed(2)}", 
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Aquí podrías seleccionar el producto o mostrar detalle
                    // Por ahora cerramos el buscador devolviendo el producto si fuera necesario
                    // o mostramos un diálogo simple.
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.secondary,
                        title: Text(item.nombre, style: const TextStyle(color: AppColors.accent)),
                        content: Text("Precio: \$${item.costo}", style: const TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text("Cerrar")
                          )
                        ],
                      ),
                    );
                  },
                );
              }
              
              return const SizedBox();
            },
          ),
        );
      },
    );
  }
}