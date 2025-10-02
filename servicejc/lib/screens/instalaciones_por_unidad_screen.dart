import 'package:flutter/material.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/location_selection_screen.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

class InstalacionesPorUnidadScreen extends StatefulWidget {
  const InstalacionesPorUnidadScreen({super.key});

  @override
  State<InstalacionesPorUnidadScreen> createState() =>
      _InstalacionesPorUnidadScreenState();
}

class _InstalacionesPorUnidadScreenState
    extends State<InstalacionesPorUnidadScreen> {
  // Lista mutable de servicios
  final List<Map<String, dynamic>> _servicios = [
    {
      'title': 'Electricidad',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Electricidad',
    },
    {
      'title': 'Plomeria',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Plomeria',
    },
    {
      'title': 'Instalaciones menores',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Instalaciones menores',
    },
    {
      'title': 'Aire acondicionado (instalación y mantenimiento)',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Aire acondicionado (instalación y mantenimiento)',
    },
    {
      'title': 'Pintores',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Pintores',
    },
    {
      'title': 'Ebanistas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Ebanistas',
    },
    {
      'title': 'Soldadura',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Soldadura',
    },
    {
      'title': 'Aluminio y vidrio',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Aluminio y vidrio',
    },
    {
      'title': 'Cielo raso',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Cielo raso',
    },
    {
      'title': 'Instalaciones decorativas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Instalaciones decorativas',
    },
    {
      'title': 'Revestimientos de piso y paredes',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Revestimientos de piso y paredes',
    },
    {
      'title': 'Remodelaciones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Remodelaciones',
    },
    {
      'title': 'Construcción',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Construcción',
    },
    {
      'title': 'Mantenimientos preventivos',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Mantenimientos preventivos',
    },
    {
      'title': 'Limpieza de sillones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Limpieza de sillones',
    },
    {
      'title': 'Limpieza de áreas',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Limpieza de áreas',
    },
    {
      'title': 'Chefs',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Chefs',
    },
    {
      'title': 'Salonerros',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Salonerros',
    },
    {
      'title': 'Bartender',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Bartender',
    },
    {
      'title': 'Decoraciones',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Decoraciones',
    },
    {
      'title': 'Otros',
      'price': 25.00,
      'isSelected': false,
      'originalTitle': 'Otros',
    },
  ];

  final Map<String, Map<String, dynamic>> _iconosPorServicio = {
    'Electricidad': {'icon': Icons.power, 'color': Colors.amber[700]},
    'Plomeria': {'icon': Icons.plumbing, 'color': Colors.blue[600]},
    'Instalaciones menores': {
      'icon': Icons.handyman,
      'color': Colors.brown[400],
    },
    'Aire acondicionado (instalación y mantenimiento)': {
      'icon': Icons.ac_unit,
      'color': Colors.cyan[400],
    },
    'Pintores': {'icon': Icons.format_paint, 'color': Colors.pink[400]},
    'Ebanistas': {'icon': Icons.chair, 'color': Colors.brown[700]},
    'Soldadura': {'icon': Icons.engineering, 'color': Colors.grey[700]},
    'Aluminio y vidrio': {'icon': Icons.window, 'color': Colors.blueGrey[400]},
    'Cielo raso': {'icon': Icons.roofing, 'color': Colors.orange[400]},
    'Instalaciones decorativas': {
      'icon': Icons.design_services,
      'color': Colors.purple[400],
    },
    'Revestimientos de piso y paredes': {
      'icon': Icons.layers,
      'color': Colors.teal[400],
    },
    'Remodelaciones': {'icon': Icons.construction, 'color': Colors.red[400]},
    'Construcción': {'icon': Icons.apartment, 'color': Colors.green[400]},
    'Mantenimientos preventivos': {
      'icon': Icons.build_circle,
      'color': Colors.lime[600],
    },
    'Limpieza de sillones': {
      'icon': Icons.cleaning_services,
      'color': Colors.indigo[400],
    },
    'Limpieza de áreas': {'icon': Icons.wash, 'color': Colors.lightBlue[400]},
    'Chefs': {'icon': Icons.restaurant_menu, 'color': Colors.orange[700]},
    'Salonerros': {'icon': Icons.room_service, 'color': Colors.deepOrange[400]},
    'Bartender': {'icon': Icons.local_bar, 'color': Colors.lightGreen[600]},
    'Decoraciones': {'icon': Icons.cake, 'color': Colors.pink[300]},
    'Otros': {'icon': Icons.more_horiz, 'color': Colors.grey[500]},
  };

  // --- LÓGICA DE DESCUENTOS Y TOTALES ---
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
    if (totalItems >= 4) return 0.12; // 12%
    if (totalItems == 3) return 0.08; // 8%
    if (totalItems == 2) return 0.05; // 5%
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
          // CORRECCIÓN APLICADA AQUÍ
          id: service['originalTitle'],
          nombre: service['title'],
          costo: service['price'],
          servicioId:
              'instalacion_por_unidad', // ID genérico para esta pantalla
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
      appBar: AppBar(title: const Text('Instalaciones por Unidad')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ), // Espacio para el summary
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
    final Map<String, dynamic>? iconoData = _iconosPorServicio[originalTitle];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'B/. ${servicio['price'].toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.green,
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
          color: iconoData?['color'] ?? Colors.black,
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
          title: const Text('Especificar Servicio'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ej: Instalar caja de fusibles',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
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
              child: const Text('Aceptar'),
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
