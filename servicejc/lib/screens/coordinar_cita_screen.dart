import 'package:flutter/material.dart';
import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/loading_screen.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CoordinarCitaScreen extends StatefulWidget {
  final Map<ProductModel, int> selectedProducts;
  final double subtotal;
  final double discountAmount;
  final double totalCost;
  final LocationModel province;
  final LocationModel district;
  final LocationModel corregimiento;
  final String barrio;
  final String casa;

  const CoordinarCitaScreen({
    super.key,
    required this.selectedProducts,
    required this.subtotal,
    required this.discountAmount,
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
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _selectedDate != null &&
        _selectedTime != null &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(
              primary: AppColors.elevatedButton,
              onPrimary: AppColors.elevatedButtonForeground,
              onSurface: AppColors.cardTitle,
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

  Future<void> _addPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedPhotos.add(File(pickedFile.path));
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto agregada con éxito.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna foto.')),
      );
    }
  }

  Widget _buildPhotoPreview() {
    if (_selectedPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedPhotos.map((photoFile) {
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(photoFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotos.remove(photoFile);
                      });
                    },
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.danger,
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmAppointment() {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa la fecha, hora y la descripción para confirmar.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildProductDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.selectedProducts.entries.map((entry) {
        final product = entry.key;
        final quantity = entry.value;
        final itemTotal = (product.costo) * quantity;

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
            Text(
              'Servicios Seleccionados ($totalItems ítems)',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const Divider(color: AppColors.white54, height: 16),
            _buildProductDetail(),
            const Divider(color: AppColors.white54, height: 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar:',
                  style: AppTextStyles.h2.copyWith(color: AppColors.accent),
                ),
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
    bool canConfirm = _isFormValid();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coordinar Cita',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.accent),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            _buildOrderSummaryCard(),
            const SizedBox(height: 16),
            _buildAddressCard(),
            const SizedBox(height: 32),
            Text(
              '3. Describe tu Requerimiento (Obligatorio)',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Ej: El aire acondicionado gotea y hace un ruido fuerte. Favor revisar el motor.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: AppColors.secondary,
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.white54,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.trim().length < 10) {
                  return 'Por favor, proporciona una descripción detallada (mínimo 10 caracteres).';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(
              '4. Agrega Fotos del Daño (Opcional)',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                _selectedPhotos.isEmpty
                    ? 'Subir Foto'
                    : 'Subir más fotos (${_selectedPhotos.length} añadidas)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.iconButton,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            _buildPhotoPreview(),
            const SizedBox(height: 32),
            Text(
              '5. Selecciona la Fecha y Hora (Obligatorio)',
              style: AppTextStyles.h4.copyWith(color: AppColors.accent),
            ),
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
            ElevatedButton(
              onPressed: canConfirm ? _confirmAppointment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                disabledForegroundColor: AppColors.white54,
              ),
              child: Text(
                canConfirm
                    ? 'Confirmar Cita y Continuar al Pago'
                    : 'Complete los campos obligatorios para continuar',
                style: AppTextStyles.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
