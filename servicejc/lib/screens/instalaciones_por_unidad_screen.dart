import 'package:flutter/material.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/location_selection_screen.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import '../services/service_data.dart'; // Importar la nueva clase

class InstalacionesPorUnidadScreen extends StatefulWidget {
  const InstalacionesPorUnidadScreen({super.key});

  @override
  State<InstalacionesPorUnidadScreen> createState() =>
      _InstalacionesPorUnidadScreenState();
}

class _InstalacionesPorUnidadScreenState
    extends State<InstalacionesPorUnidadScreen> {
  final List<Map<String, dynamic>> _servicios = [
    {
      'title': 'Electricidad',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Electricidad',
      'id': 'electricidad_id',
    },
    {
      'title': 'Plomeria',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Plomeria',
      'id': 'plomeria_id',
    },
    {
      'title': 'Instalaciones menores',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Instalaciones menores',
      'id': 'instalaciones_menores_id',
    },
    {
      'title': 'Aire acondicionado (instalación y mantenimiento)',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Aire acondicionado (instalación y mantenimiento)',
      'id': 'aire_acondicionado_id',
    },
    {
      'title': 'Pintores',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Pintores',
      'id': 'pintores_id',
    },
    {
      'title': 'Ebanistas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Ebanistas',
      'id': 'ebanistas_id',
    },
    {
      'title': 'Soldadura',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Soldadura',
      'id': 'soldadura_id',
    },
    {
      'title': 'Aluminio y vidrio',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Aluminio y vidrio',
      'id': 'aluminio_y_vidrio_id',
    },
    {
      'title': 'Cielo raso',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Cielo raso',
      'id': 'cielo_raso_id',
    },
    {
      'title': 'Instalaciones decorativas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Instalaciones decorativas',
      'id': 'instalaciones_decorativas_id',
    },
    {
      'title': 'Revestimientos de piso y paredes',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Revestimientos de piso y paredes',
      'id': 'revestimientos_id',
    },
    {
      'title': 'Remodelaciones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Remodelaciones',
      'id': 'remodelaciones_id',
    },
    {
      'title': 'Construcción',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Construcción',
      'id': 'construccion_id',
    },
    {
      'title': 'Mantenimientos preventivos',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Mantenimientos preventivos',
      'id': 'mantenimientos_preventivos_id',
    },
    {
      'title': 'Limpieza de sillones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Limpieza de sillones',
      'id': 'limpieza_sillones_id',
    },
    {
      'title': 'Limpieza de áreas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Limpieza de áreas',
      'id': 'limpieza_areas_id',
    },
    {
      'title': 'Chefs',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Chefs',
      'id': 'chefs_id',
    },
    {
      'title': 'Salonerros',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Salonerros',
      'id': 'saloneros_id',
    },
    {
      'title': 'Bartender',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Bartender',
      'id': 'bartender_id',
    },
    {
      'title': 'Decoraciones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Decoraciones',
      'id': 'decoraciones_id',
    },
    {
      'title': 'Otros',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Otros',
      'id': 'otros_id',
    },
  ];

  List<Map<String, dynamic>> _getSelectedServices() {
    return _servicios.where((s) => s['isSelected'] == true).toList();
  }

  double _calculateSubtotal() {
    return _getSelectedServices().fold(
      0.0,
      (sum, item) => sum + (item['price'] as double),
    );
  }

  double _getDiscountPercentage(int totalItems) {
    if (totalItems >= 4) return 0.12;
    if (totalItems == 3) return 0.08;
    if (totalItems == 2) return 0.05;
    return 0.0;
  }

  double _calculateDiscountAmount() {
    final subtotal = _calculateSubtotal();
    final discountPercentage = _getDiscountPercentage(
      _getSelectedServices().length,
    );
    return subtotal * discountPercentage;
  }

  double _calculateTotal() {
    return _calculateSubtotal() - _calculateDiscountAmount();
  }

  void _onContinuePressed() {
    final selectedServices = _getSelectedServices();
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos un servicio.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final Map<ProductModel, int> selectedProducts = {
      for (var service in selectedServices)
        ProductModel(
          id: service['id'],
          nombre: service['title'],
          costo: service['price'],
          servicioId: 'instalacion_por_unidad',
        ): 1,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          selectedProducts: selectedProducts,
          subtotal: _calculateSubtotal(),
          discountAmount: _calculateDiscountAmount(),
          totalCost: _calculateTotal(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _getSelectedServices().length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instalaciones por Unidad',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _servicios.length,
              itemBuilder: (context, index) {
                return _buildServiceCheckbox(_servicios[index]);
              },
            ),
          ),
        ],
      ),
      bottomSheet: selectedCount > 0 ? _buildTotalSummary() : null,
    );
  }

  Widget _buildServiceCheckbox(Map<String, dynamic> servicio) {
    final String titulo = servicio['title'];
    final String originalTitle = servicio['originalTitle'];
    final Map<String, dynamic>? iconoData = ServiceData.getServiceData(
      originalTitle,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(
          titulo,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'B/. ${servicio['price'].toStringAsFixed(2)}',
          style: AppTextStyles.listSubtitle.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: servicio['isSelected'],
        onChanged: (bool? newValue) {
          setState(() {
            if (originalTitle == 'Otros') {
              if (newValue == true) {
                _showOtherServiceModal(servicio);
              } else {
                servicio['title'] = servicio['originalTitle'];
                servicio['isSelected'] = false;
              }
            } else {
              servicio['isSelected'] = newValue!;
            }
          });
        },
        secondary: Icon(
          iconoData?['icon'] ?? Icons.help_outline,
          color: iconoData?['color'] ?? AppColors.cardTitle,
          size: 30,
        ),
        activeColor: AppColors.success,
      ),
    );
  }

  void _showOtherServiceModal(Map<String, dynamic> servicio) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Especificar Servicio', style: AppTextStyles.modalTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ej: Instalar caja de fusibles',
              hintStyle: AppTextStyles.bodyText.copyWith(
                color: AppColors.white54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: AppColors.secondary,
            ),
            style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.modalButton.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    servicio['title'] = 'Otros: ${controller.text.trim()}';
                    servicio['isSelected'] = true;
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.elevatedButton,
              ),
              child: Text('Aceptar', style: AppTextStyles.modalButton),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalSummary() {
    final subtotal = _calculateSubtotal();
    final totalItems = _getSelectedServices().length;
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
            if (discountAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
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
              ),
            const Divider(color: AppColors.white54, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a Pagar:', style: AppTextStyles.h2),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppTextStyles.h1.copyWith(fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onContinuePressed,
              child: const Text('Continuar al Domicilio'),
            ),
          ],
        ),
      ),
    );
  }
}
