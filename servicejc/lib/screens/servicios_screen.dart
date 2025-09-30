import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/coordinar_cita_screen.dart';
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
  List<ProductModel> _productosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _futureProductos = ServicioService().fetchProductos(widget.servicio.id);
  }

  void _showOtherServiceModal(ProductModel producto) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Especificar Servicio', style: AppTextStyles.modalTitle),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ej: instalación de una caja de fusibles',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  producto.isSelected = false;
                });
              },
              child: const Text('Cancelar', style: AppTextStyles.modalButton),
            ),
            ElevatedButton(
              onPressed: () {
                print('Servicio "Otros" especificado: ${controller.text}');
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar', style: AppTextStyles.modalButton),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCheckbox(ProductModel producto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'B/. ${producto.costo.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        value: producto.isSelected,
        onChanged: (bool? newValue) {
          setState(() {
            producto.isSelected = newValue!;
            if (producto.isSelected) {
              _productosSeleccionados.add(producto);
            } else {
              _productosSeleccionados.remove(producto);
            }
          });
          if (producto.nombre.toLowerCase() == 'otros' && newValue == true) {
            _showOtherServiceModal(producto);
          }
        },
        activeColor: AppColors.activeCheckbox,
      ),
    );
  }

  Widget _buildTotalSummary() {
    final selectedCount = _productosSeleccionados.length;
    final buttonText = selectedCount > 0
        ? 'Solicitar Servicio ($selectedCount)'
        : 'Solicitar Servicio';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: selectedCount > 0
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoordinarCitaScreen()),
                );
              }
            : null,
        child: Text(buttonText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicio.nombre, style: const TextStyle(color: AppColors.cardTitle, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cardTitle),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProductos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No se encontraron productos para este servicio.', style: Theme.of(context).textTheme.bodyMedium));
                } else {
                  final productos = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: productos.length,
                    itemBuilder: (context, index) => _buildProductCheckbox(productos[index]),
                  );
                }
              },
            ),
          ),
          _buildTotalSummary(),
        ],
      ),
    );
  }
}
