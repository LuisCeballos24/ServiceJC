import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/product_model.dart'; // Asumo que ProductModel tiene: nombre, costo, isSelected (mutable)
import 'package:servicejc/screens/location_selection_screen.dart'; // ¡NUEVA PANTALLA DE DESTINO!
import 'package:servicejc/services/servicio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ServiciosScreen extends StatefulWidget {
  final ServiceModel servicio;

  const ServiciosScreen({super.key, required this.servicio});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  late Future<List<ProductModel>> _futureProductos;

  // Mapa para rastrear los productos seleccionados y sus cantidades
  // { ProductModel: Cantidad }
  final Map<ProductModel, int> _selectedProductsWithQuantity = {};

  @override
  void initState() {
    super.initState();
    // En un proyecto real, necesitarías la ID del servicio para buscar sus productos.
    // Usaremos un valor de ejemplo por ahora.
    _futureProductos = ServicioService().fetchProductos(widget.servicio.id);
  }

  // --- Lógica de Descuentos y Totales ---

  int _totalItemsCount() {
    // Suma la cantidad de todos los productos seleccionados en el mapa
    return _selectedProductsWithQuantity.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    _selectedProductsWithQuantity.forEach((product, quantity) {
      subtotal += (product.costo ?? 0.0) * quantity;
    });
    return subtotal;
  }

  double _getDiscountPercentage(int totalItems) {
    if (totalItems >= 4) {
      return 0.12; // 12% de descuento
    } else if (totalItems == 3) {
      return 0.08; // 8% de descuento
    } else if (totalItems == 2) {
      return 0.05; // 5% de descuento
    }
    return 0.0; // Sin descuento
  }

  double _calculateDiscountAmount() {
    final subtotal = _calculateSubtotal();
    final discountPercentage = _getDiscountPercentage(_totalItemsCount());
    return subtotal * discountPercentage;
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final discountAmount = _calculateDiscountAmount();
    return subtotal - discountAmount;
  }

  // --- Lógica de Interacción ---

  void _updateProductQuantity(ProductModel product, int quantity) {
    setState(() {
      if (quantity > 0) {
        _selectedProductsWithQuantity[product] = quantity;
      } else {
        _selectedProductsWithQuantity.remove(product);
      }
    });
  }

  // *** FUNCIÓN DE NAVEGACIÓN ACTUALIZADA ***
  void _onCotizarPressed() {
    if (_selectedProductsWithQuantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona al menos un producto para continuar.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Navega a LocationSelectionScreen, pasando el desglose de costos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          selectedProducts: _selectedProductsWithQuantity,
          subtotal: _calculateSubtotal(),
          discountAmount: _calculateDiscountAmount(),
          totalCost: _calculateTotal(),
        ),
      ),
    );
  }

  // --- Widgets de la Interfaz ---

  Widget _buildProductItem(ProductModel product) {
    // Obtiene la cantidad actual del producto
    final currentQuantity = _selectedProductsWithQuantity[product] ?? 0;
    final isSelected = currentQuantity > 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              product.nombre,
              style: AppTextStyles.listTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Costo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Costo: \$${product.costo?.toStringAsFixed(2) ?? 'N/A'}',
                  style: AppTextStyles.listSubtitle,
                ),
                // Botones de cantidad (sólo si está seleccionado o se va a seleccionar)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Menos
                      IconButton(
                        icon: const Icon(Icons.remove, color: AppColors.white),
                        onPressed: isSelected
                            ? () => _updateProductQuantity(
                                product,
                                currentQuantity - 1,
                              )
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      // Contador
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          '$currentQuantity',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      // Botón Más
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.white),
                        onPressed: () => _updateProductQuantity(
                          product,
                          currentQuantity + 1,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary() {
    final subtotal = _calculateSubtotal();
    final totalItems = _totalItemsCount();
    final discountPercentage = _getDiscountPercentage(totalItems);
    final discountAmount = _calculateDiscountAmount();
    final total = _calculateTotal();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${totalItems} ítems):',
                  style: AppTextStyles.h3,
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Resumen de Descuento (mostrar solo si hay descuento)
            if (discountAmount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descuento (${(discountPercentage * 100).toStringAsFixed(0)}%):',
                    style: AppTextStyles.listSubtitle.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '-\$${discountAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.listSubtitle.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            if (discountAmount > 0)
              const Divider(color: AppColors.white54, height: 24),

            // Resumen de Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a Pagar:', style: AppTextStyles.h2),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 28,
                  ), // Un poco más grande para destacar
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón principal
            ElevatedButton(
              onPressed: _onCotizarPressed,
              child: const Text('Continuar al Domicilio'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Servicio: ${widget.servicio.nombre}')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProductos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron productos para este servicio.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite,
                      ),
                    ),
                  );
                } else {
                  final productos = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: productos.length,
                    itemBuilder: (context, index) =>
                        _buildProductItem(productos[index]),
                  );
                }
              },
            ),
          ),
          if (_totalItemsCount() > 0) _buildTotalSummary(),
        ],
      ),
    );
  }
}
