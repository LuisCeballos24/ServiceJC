import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart'; 
import 'package:servicejc/models/product_model.dart'; 
import 'package:servicejc/services/servicio_service.dart';
import 'package:servicejc/screens/location_selection_screen.dart';

// 👇 1. IMPORTAMOS EL HEADER Y EL FOOTER GLOBALES
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServiciosScreen extends StatefulWidget {
  final CategoriaPrincipalModel categoria; 

  const ServiciosScreen({super.key, required this.categoria});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  late Future<List<ProductModel>> _futureProductos;
  final ServicioService _servicioService = ServicioService();
  final Map<ProductModel, int> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _futureProductos = _servicioService.fetchProductos(widget.categoria.id);
  }

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
    // 💡 Detectamos el tamaño de la pantalla para el Header
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      // 👇 2. USAMOS EL HEADER GLOBAL
      appBar: AppBar(
        title: AppBarContent(isLargeScreen: isLargeScreen),
        toolbarHeight: isLargeScreen ? 100 : 80,
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false, // Oculta la flecha por defecto para que no choque con el logo
      ),
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
        child: Column(
          children: [
            // 👇 3. SUB-HEADER (Botón de regresar y Título de la página)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.secondary.withOpacity(0.5),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.categoria.nombre,
                      style: AppTextStyles.h2.copyWith(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),

            // 👇 4. CONTENIDO Y FOOTER EN UN SCROLL COMPARTIDO
            Expanded(
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

                  // 🔥 CustomScrollView permite combinar Listas y Widgets simples (como el Footer)
                  return CustomScrollView(
                    slivers: [
                      // La lista de productos
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final producto = productos[index];
                              final quantity = _selectedProducts[producto] ?? 0;

                              // Envolvemos el Card en Padding para simular el espacio de ListView.separated
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Card(
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
                                ),
                              );
                            },
                            childCount: productos.length,
                          ),
                        ),
                      ),
                      
                      // 👇 5. EL FOOTER GLOBAL AL FINAL DE LA PANTALLA
                      const SliverToBoxAdapter(
                        child: AppFooterBarContent(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}