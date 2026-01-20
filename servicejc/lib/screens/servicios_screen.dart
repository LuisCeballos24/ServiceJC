import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart'; // Modelo que viene del Home
import 'package:servicejc/models/product_model.dart'; // Modelo de los productos
import 'package:servicejc/services/servicio_service.dart';
// Importamos la pantalla siguiente: Selección de Ubicación
import 'package:servicejc/screens/location_selection_screen.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServiciosScreen extends StatefulWidget {
  // Recibe el ítem seleccionado en el Home (que actúa como Servicio)
  final CategoriaPrincipalModel categoria; 

  const ServiciosScreen({super.key, required this.categoria});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  late Future<List<ProductModel>> _futureProductos;
  final ServicioService _servicioService = ServicioService();
  
  // Mapa para controlar cantidades seleccionadas
  final Map<ProductModel, int> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    // 💡 AHORA SÍ: Usamos el ID para buscar PRODUCTOS directamente
    _futureProductos = _servicioService.fetchProductos(widget.categoria.id);
  }

  // Lógica de selección (igual que tenías en ProductosScreen)
  void _updateQuantity(ProductModel product, int delta) {
    setState(() {
      int currentQty = _selectedProducts[product] ?? 0;
      int newQty = currentQty + delta;
      if (newQty > 0) {
        _selectedProducts[product] = newQty;
      } else {
        _selectedProducts.remove(product);
      }
    });
  }

  void _continueToLocation() {
    if (_selectedProducts.isEmpty) return;

    double subtotal = 0;
    _selectedProducts.forEach((p, qty) => subtotal += p.costo * qty);
    
    // Lógica de descuento simple (ejemplo)
    double discount = subtotal > 100 ? subtotal * 0.10 : 0;
    double total = subtotal - discount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          selectedProducts: _selectedProducts,
          subtotal: subtotal,
          discountAmount: discount,
          totalCost: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoria.nombre, // Nombre del servicio (ej: Electricidad)
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      // Botón flotante para continuar si hay selección
      floatingActionButton: _selectedProducts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _continueToLocation,
              backgroundColor: AppColors.accent,
              label: const Text("Continuar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<ProductModel>>(
          future: _futureProductos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay actividades disponibles para este servicio.', style: TextStyle(color: Colors.white70)));
            }

            final productos = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final producto = productos[index];
                final quantity = _selectedProducts[producto] ?? 0;

                return Card(
                  color: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: quantity > 0 ? AppColors.accent : Colors.transparent,
                      width: 1.5
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: AppTextStyles.bodyText.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${producto.costo.toStringAsFixed(2)}",
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                        // Controles de cantidad
                        Row(
                          children: [
                            if (quantity > 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                                onPressed: () => _updateQuantity(producto, -1),
                              ),
                            if (quantity > 0)
                              Text(
                                '$quantity',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle, 
                                color: quantity > 0 ? AppColors.accent : Colors.white54
                              ),
                              onPressed: () => _updateQuantity(producto, 1),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}