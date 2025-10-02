import 'package:flutter/material.dart';
import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/loading_screen.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

class CoordinarCitaScreen extends StatefulWidget {
  final Map<ProductModel, int> selectedProducts;
  final double subtotal; // NUEVO
  final double discountAmount; // NUEVO
  final double totalCost;
  final LocationModel province;
  final LocationModel district;
  final LocationModel corregimiento;
  final String barrio;
  final String casa;

  const CoordinarCitaScreen({
    super.key,
    required this.selectedProducts,
    required this.subtotal, // REQUERIDO
    required this.discountAmount, // REQUERIDO
    required this.totalCost,
    required this.province,
    required this.district,
    required this.corregimiento,
    required this.barrio,
    required this.casa,
  });

  @override
  State<CoordinarCitaScreen> createState() => _CoordinarCitaScreenState();
}

class _CoordinarCitaScreenState extends State<CoordinarCitaScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // --- Lógica de la Cita ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary, // Color primario del picker
            colorScheme: const ColorScheme.light(
              primary: AppColors.elevatedButton, // Color del header
              onPrimary: AppColors
                  .elevatedButtonForeground, // Color del texto del header
              onSurface: AppColors.cardTitle, // Color del texto de la fecha
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.elevatedButton,
              onPrimary: AppColors.elevatedButtonForeground,
              onSurface: AppColors.cardTitle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _confirmAppointment() {
    // Aquí iría la lógica para guardar la cita en tu backend
    // ... (Se mantiene la lógica de impresión y navegación original)

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoadingScreen()),
      (route) => false,
    );
  }

  // --- Widgets de Visualización ---

  Widget _buildProductDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.selectedProducts.entries.map((entry) {
        final product = entry.key;
        final quantity = entry.value;
        final itemTotal = (product.costo ?? 0) * quantity;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${quantity}x ${product.nombre}',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${itemTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.white70,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummaryCard() {
    final totalItems = widget.selectedProducts.values.fold(
      0,
      (sum, q) => sum + q,
    );

    // Calcular el porcentaje de descuento para mostrarlo
    double discountPercentage = widget.subtotal > 0
        ? (widget.discountAmount / widget.subtotal) * 100
        : 0.0;

    return Card(
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Productos
            Text(
              'Servicios Seleccionados ($totalItems ítems)',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const Divider(color: AppColors.white54, height: 16),
            _buildProductDetail(),

            const Divider(color: AppColors.white54, height: 20),

            // Sección de Desglose de Costos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: AppTextStyles.h3),
                Text(
                  '\$${widget.subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descuento Llamativo
            if (widget.discountAmount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descuento Ahorrado (${discountPercentage.toStringAsFixed(0)}%):',
                    style: AppTextStyles.listSubtitle.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '-\$${widget.discountAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.listSubtitle.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            if (widget.discountAmount > 0)
              const Divider(color: AppColors.white54, height: 24),

            // Total a Pagar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a Pagar:', style: AppTextStyles.h2),
                Text(
                  '\$${widget.totalCost.toStringAsFixed(2)}',
                  style: AppTextStyles.h1.copyWith(fontSize: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección de la Cita',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const Divider(color: AppColors.white54, height: 16),
            Text(
              '${widget.barrio}, ${widget.casa}',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
            ),
            Text(
              '${widget.corregimiento.name}, ${widget.district.name}, ${widget.province.name}',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinar Cita')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          // 1. Resumen de la Orden (Productos y Descuento)
          _buildOrderSummaryCard(),
          const SizedBox(height: 16),

          // 2. Dirección de la Cita
          _buildAddressCard(),
          const SizedBox(height: 32),

          // 3. Selectores de Fecha y Hora
          const Text('Selecciona la Fecha y Hora', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedDate == null
                  ? 'Seleccionar Fecha'
                  : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _selectTime(context),
            icon: const Icon(Icons.access_time),
            label: Text(
              _selectedTime == null
                  ? 'Seleccionar Hora'
                  : 'Hora: ${_selectedTime!.format(context)}',
            ),
          ),
          const SizedBox(height: 40),

          // 4. Botón de Confirmación
          ElevatedButton(
            onPressed: _selectedDate != null && _selectedTime != null
                ? _confirmAppointment
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirmar Cita'),
          ),
        ],
      ),
    );
  }
}
