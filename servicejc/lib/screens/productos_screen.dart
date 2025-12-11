import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/location_selection_screen.dart';
import 'package:servicejc/services/servicio_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 💡 Clase renombrada para reflejar que es la selección de productos/actividades
class ProductosScreen extends StatefulWidget { 
  final ServiceModel servicio;

  const ProductosScreen({super.key, required this.servicio});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  late Future<List<ProductModel>> _futureProductos;

  final Map<ProductModel, int> _selectedProductsWithQuantity = {};

  @override
  void initState() {
    super.initState();
    _futureProductos = ServicioService().fetchProductos(widget.servicio.id);
  }

  // --- MÉTODOS DE CÁLCULO (Se mantienen) ---
  int _totalItemsCount() {
    return _selectedProductsWithQuantity.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;
    _selectedProductsWithQuantity.forEach((product, quantity) {
      subtotal += (product.costo) * quantity;
    });
    return subtotal;
  }

  double _getDiscountPercentage(int totalItems) {
    if (totalItems >= 4) {
      return 0.12;
    } else if (totalItems == 3) {
      return 0.08;
    } else if (totalItems == 2) {
      return 0.05;
    }
    return 0.0;
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
  // ------------------------------------------
  
  void _updateProductQuantity(ProductModel product, int quantity) {
    setState(() {
      if (quantity > 0) {
        _selectedProductsWithQuantity[product] = quantity;
      } else {
        _selectedProductsWithQuantity.remove(product);
      }
    });
  }
  
  // 💡 NUEVO MÉTODO AUXILIAR para navegar
  void _navigateToLocationScreen({
    required Map<ProductModel, int> selectedProducts,
    required double subtotal,
    required double discountAmount,
    required double totalCost,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          selectedProducts: selectedProducts,
          subtotal: subtotal,
          discountAmount: discountAmount,
          totalCost: totalCost,
          // Considere añadir 'isInspection' al modelo de LocationSelectionScreen
        ),
      ),
    );
  }

  // 💡 LÓGICA DE INSPECCIÓN APLICADA EN EL BOTÓN
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

    // 1. Identificar si la solicitud es una Inspección de $10.00
    final inspectionProductEntries = _selectedProductsWithQuantity.entries
        .where((entry) => entry.key.costo == 10.00)
        .where((entry) => entry.key.nombre.toLowerCase().contains('inspección') || entry.key.nombre.toLowerCase().contains('proyecto'))
        .toList();

    // Es inspección exclusiva si: 
    // a) Se encontró el ítem de inspección
    // b) Y es el único ítem seleccionado
    // c) Y la cantidad es 1.
    final isOnlyInspection = inspectionProductEntries.isNotEmpty && 
                             _selectedProductsWithQuantity.length == 1 &&
                             inspectionProductEntries.first.value == 1;


    if (isOnlyInspection) {
      // Caso 1: Flujo de Inspección de $10.00
      final inspectionItem = inspectionProductEntries.first.key;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmación de Inspección'),
            content: Text(
              'Ha seleccionado solo el servicio de inspección/proyecto. '
              'Se cobrarán **\$10.00** para coordinar la visita y crear una cotización detallada. '
              'Este costo es DEDUCIBLE del valor final de la obra. ¿Desea continuar?',
              style: AppTextStyles.bodyText,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.danger)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar diálogo
                  // Navegar fijando el costo en $10.00 e ignorando descuentos/cálculos
                  _navigateToLocationScreen(
                    selectedProducts: {inspectionItem: 1},
                    subtotal: 10.00,
                    discountAmount: 0.0,
                    totalCost: 10.00,
                  );
                },
                child: const Text('Aceptar y Pagar \$10.00'),
              ),
            ],
          );
        },
      );
    } else {
      // Caso 2: Flujo de Costo Fijo / Múltiple / Mixto (Se usa el cálculo normal)
      _navigateToLocationScreen(
        selectedProducts: _selectedProductsWithQuantity,
        subtotal: _calculateSubtotal(),
        discountAmount: _calculateDiscountAmount(),
        totalCost: _calculateTotal(),
      );
    }
  }

  // ... (Widget _buildProductItem se mantiene igual)

  Widget _buildProductItem(ProductModel product) {
    final currentQuantity = _selectedProductsWithQuantity[product] ?? 0;
    final isSelected = currentQuantity > 0;
    
    // 💡 Lógica para deshabilitar la cantidad si es un ítem de inspección de 10.00
    // Esto asegura que solo se pueda pedir 1 inspección a la vez, o que el flujo sea de 10.00
    final isInspectionItem = product.costo == 10.00 && 
                             (product.nombre.toLowerCase().contains('inspección') || product.nombre.toLowerCase().contains('proyecto'));

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.nombre,
              style: AppTextStyles.listTitle.copyWith(
                color: AppColors.cardTitle,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Costo: \$${product.costo.toStringAsFixed(2) ?? 'N/A'}',
                  style: AppTextStyles.listSubtitle.copyWith(
                    color: AppColors.cardTitle,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Quitar
                      IconButton(
                        icon: const Icon(Icons.remove, color: AppColors.white),
                        onPressed: isSelected && !isInspectionItem // No se puede quitar si es inspección de 10.00
                            ? () => _updateProductQuantity(
                                  product,
                                  currentQuantity - 1,
                                )
                            : isSelected && isInspectionItem && currentQuantity > 0
                                ? () => _updateProductQuantity(product, 0)
                                : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          '$currentQuantity',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      // Botón Añadir
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.white),
                        onPressed: isInspectionItem && currentQuantity == 1
                            ? null // Deshabilita si es inspección y ya hay 1
                            : () => _updateProductQuantity(
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
    final discountAmount = _calculateDiscountAmount();
    final total = _calculateTotal();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Descuento:',
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.accent),
                ),
                Text(
                  '-\$${discountAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: AppTextStyles.h2.copyWith(color: AppColors.white),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onCotizarPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continuar',
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Servicio: ${widget.servicio.nombre}',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.accent),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProductos,
              builder: (context, snapshot) {
                // ... (Manejo de estados de FutureBuilder)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.softWhite,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron productos para este servicio.',
                      style: AppTextStyles.bodyText.copyWith(
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