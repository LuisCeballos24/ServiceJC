import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 1. IMPORTANTE PARA WEB
import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/loading_screen.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/services/appointment_service.dart';
import 'package:servicejc/models/cita_model.dart';
import 'package:intl/intl.dart';

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

  // 2. CAMBIO: Usamos XFile en lugar de File para compatibilidad Web/Móvil
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 3. NUEVA LÓGICA PRINCIPAL DEL BOTÓN
  void _handleContinue() async {
    // A. Validar Formulario primero
    if (!_formKey.currentState!.validate() || 
        _selectedDate == null || 
        _selectedTime == null || 
        _descriptionController.text.trim().length < 10) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa la fecha, hora y descripción detallada.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // B. Verificar si está logueado
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('authToken');

    bool isLoggedIn = userId != null && token != null;

    if (!isLoggedIn) {
      // C. SI NO ESTÁ LOGUEADO -> ENVIAR A LOGIN
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para confirmar la cita.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navegamos al login y esperamos a que vuelva
        await Navigator.pushNamed(context, '/login');
        
        // Al volver, verificamos de nuevo (Recursividad simple)
        // El usuario tendrá que volver a dar click en "Confirmar", 
        // pero sus datos del formulario seguirán aquí.
      }
      return;
    }

    // D. SI ESTÁ LOGUEADO -> PROCESAR CITA
    _confirmAppointment(userId);
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
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
    if (_selectedPhotos.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permite subir una foto por cita.')),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedPhotos.clear();
        // Guardamos el XFile directamente
        _selectedPhotos.add(pickedFile);
      });
      // Forzar reconstrucción para ver la imagen
      setState(() {}); 
    }
  }

  void _confirmAppointment(String userId) async {
    // Mostrar carga
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );
    }

    try {
      // Prepara archivo para subir (Conversión de XFile a File si es móvil)
      File? photoFile;
      if (_selectedPhotos.isNotEmpty && !kIsWeb) {
         photoFile = File(_selectedPhotos.first.path);
      }
      // Nota: Si es Web, el servicio debe manejar bytes, 
      // pero asumo que tu servicio actual usa File (dart:io). 
      // Si usas web, el upload de fotos requiere ajustes en el servicio.
      // Por ahora, esto arregla el crash en móvil y visualización.

      final List<String> serviciosSeleccionadosIds = widget
          .selectedProducts
          .keys
          .map((p) => p.id)
          .toList();

      final cita = CitaModel(
        id: '',
        userId: userId,
        tecnicoId: null,
        status: 'PENDIENTE',
        costoTotal: widget.totalCost,
        descripcion: _descriptionController.text.trim(),
        fecha: _selectedDate!,
        hora: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        serviciosSeleccionados: serviciosSeleccionadosIds,
        imageUrl: null,
      );

      // Enviar
      await _appointmentService.createCita(cita, photoFile: photoFile);

      if (mounted) {
        // Limpiar toda la pila y volver al home o pantalla de éxito
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita programada con éxito!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // 4. SOLUCIÓN VISUALIZACIÓN DE FOTO
  Widget _buildPhotoPreview() {
    if (_selectedPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    final XFile photo = _selectedPhotos.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent),
                image: DecorationImage(
                  // LÓGICA HÍBRIDA:
                  // Si es web, usa network (el path es un blob url)
                  // Si es móvil, usa file
                  image: kIsWeb 
                      ? NetworkImage(photo.path) 
                      : FileImage(File(photo.path)) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPhotos.clear();
                  });
                },
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.danger,
                  child: Icon(Icons.close, size: 16, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${itemTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.white70),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummaryCard() {
    final totalItems = widget.selectedProducts.values.fold(0, (sum, q) => sum + q);

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Form(
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
                style: AppTextStyles.bodyText.copyWith(color: Colors.white), // Texto blanco
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: 'Ej: El aire acondicionado gotea y hace un ruido fuerte. Favor revisar el motor.',
                  hintStyle: AppTextStyles.caption.copyWith(color: AppColors.white54),
                  filled: true,
                  fillColor: AppColors.secondary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.trim().length < 10) {
                    return 'Mínimo 10 caracteres de descripción.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                '4. Agrega Fotos del Daño (Opcional)',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                label: Text(
                  _selectedPhotos.isEmpty
                      ? 'Subir Foto'
                      : 'Reemplazar Foto',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              _buildPhotoPreview(),
              
              const SizedBox(height: 32),
              Text(
                '5. Selecciona la Fecha y Hora (Obligatorio)',
                style: AppTextStyles.h4.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 16),
              
              // Botones de Fecha y Hora (estilizados)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: Text(
                        _selectedDate == null
                            ? 'Fecha'
                            : '${_selectedDate!.day}/${_selectedDate!.month}',
                         style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDate != null ? Colors.green : AppColors.secondary,
                        side: const BorderSide(color: AppColors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.access_time, color: Colors.white),
                      label: Text(
                        _selectedTime == null
                            ? 'Hora'
                            : _selectedTime!.format(context),
                         style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTime != null ? Colors.green : AppColors.secondary,
                         side: const BorderSide(color: AppColors.white54),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // 5. BOTÓN PRINCIPAL (Siempre habilitado)
              ElevatedButton(
                onPressed: _handleContinue, // Llamamos a la nueva función que valida y redirige
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'Confirmar Cita y Continuar',
                  style: AppTextStyles.button.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}