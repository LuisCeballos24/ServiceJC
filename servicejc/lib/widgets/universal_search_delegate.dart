import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/product_model.dart'; // 💡 Importante
import 'package:servicejc/services/servicio_service.dart';
import 'package:servicejc/screens/productos_screen.dart'; 
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UniversalSearchDelegate extends SearchDelegate {
  final ServicioService _servicioService = ServicioService();
  
  // 💡 Si esto es NULL, buscamos SERVICIOS (Global).
  // 💡 Si tiene un ID, buscamos PRODUCTOS dentro de ese servicio.
  final String? serviceIdContext; 

  UniversalSearchDelegate({this.serviceIdContext});

  // 1. Estilos (Tema oscuro/dorado)
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

  // 2. Botón limpiar
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

  // 3. Botón atrás
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  // 4. LÓGICA DE BÚSQUEDA
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Container(color: Colors.grey[900]);

    return FutureBuilder<List<dynamic>>(
      // 💡 LÓGICA DINÁMICA:
      // Si tenemos un ID de servicio (estamos dentro de Electricidad), llamamos a fetchProductos.
      // Si no (estamos en el Home), llamamos a fetchServicios.
      future: serviceIdContext != null 
          ? _servicioService.fetchProductos(serviceIdContext!) 
          : _servicioService.fetchServicios(),
      
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay resultados.', style: AppTextStyles.body));
        }

        // Filtramos la lista (sea de productos o servicios)
        final results = snapshot.data!.where((item) {
          // Ambos modelos tienen la propiedad 'nombre', así que podemos hacer esto:
          // (Si tus modelos no tienen 'nombre', tendrás que castear)
          String nombreItem = '';
          if (item is ServiceModel) nombreItem = item.nombre;
          if (item is ProductModel) nombreItem = item.nombre;
          
          return nombreItem.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return Container(
          color: Colors.grey[900],
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final item = results[index];

              // 💡 RENDERIZADO CONDICIONAL
              if (item is ServiceModel) {
                // ES UN SERVICIO -> Navegar a sus productos
                return ListTile(
                  leading: const Icon(Icons.folder_special, color: AppColors.accent),
                  title: Text(item.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: const Text("Servicio", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductosScreen(servicio: item),
                      ),
                    );
                  },
                );
              } else if (item is ProductModel) {
                // ES UN PRODUCTO -> Mostrar detalle
                return ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.greenAccent),
                  title: Text(item.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("\$${item.costo}", style: const TextStyle(color: AppColors.accent)),
                  onTap: () {
                    // Aquí podrías abrir un modal con el detalle del producto
                    showDialog(
                      context: context, 
                      builder: (_) => AlertDialog(
                        title: Text(item.nombre),
                        content: Text("Precio: \$${item.costo}\nDescripción: ..."),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))],
                      )
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