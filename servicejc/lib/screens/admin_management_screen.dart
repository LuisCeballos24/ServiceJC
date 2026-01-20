import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/user_address_model.dart';
import 'package:servicejc/models/location_model.dart';
// 💡 CAMBIO: Usamos CategoriaPrincipalModel porque representa los Servicios ahora
import 'package:servicejc/models/categoria_principal_model.dart'; 
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/services/servicio_service.dart';
import 'package:servicejc/services/user_api_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

import 'package:servicejc/screens/map_picker_screen.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Clientes y Citas',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelStyle: AppTextStyles.h3.copyWith(color: AppColors.accent),
          unselectedLabelStyle: AppTextStyles.h3.copyWith(color: AppColors.white54),
          tabs: const [
            Tab(text: 'Crear Usuario/Técnico', icon: Icon(Icons.person_add, color: AppColors.accent)),
            Tab(text: 'Crear Cita para Cliente', icon: Icon(Icons.schedule_send, color: AppColors.accent)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            _BuildCreateUserTab(),
            _BuildCreateAppointmentTab()
          ],
        ),
      ),
    );
  }
}
// =============================================================================
// TAB 1: CREAR USUARIO (Lógica Refactorizada)
// =============================================================================

class _BuildCreateUserTab extends StatefulWidget {
  const _BuildCreateUserTab();
  @override
  __BuildCreateUserTabState createState() => __BuildCreateUserTabState();
}

class __BuildCreateUserTabState extends State<_BuildCreateUserTab> {
  // El padre solo gestiona el Rol, el formulario hijo gestiona el resto
  String _selectedRole = 'user'; 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos del Empleado/Cliente',
            style: AppTextStyles.h2.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          
          // Selector de Rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.white54),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                dropdownColor: AppColors.secondary,
                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Usuario Final (Cliente)')),
                  DropdownMenuItem(value: 'tecnico', child: Text('Técnico')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedRole = newValue);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Aquí insertamos el formulario reutilizable
          _UserRegistrationForm(selectedRole: _selectedRole),
        ],
      ),
    );
  }
}

// --- FORMULARIO REUTILIZABLE (Lógica de Registro y Mapa) ---
class _UserRegistrationForm extends StatefulWidget {
  final String selectedRole;
  const _UserRegistrationForm({required this.selectedRole});

  @override
  __UserRegistrationFormState createState() => __UserRegistrationFormState();
}

class __UserRegistrationFormState extends State<_UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _barrioController = TextEditingController();
  final _casaController = TextEditingController();

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _corregimientos = [];

  LocationModel? _selectedProvince;
  LocationModel? _selectedDistrict;
  LocationModel? _selectedCorregimiento;

  double? _latitude;
  double? _longitude;
  bool _isAutoFilling = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _barrioController.dispose();
    _casaController.dispose();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    final provinces = await _locationService.fetchProvinces();
    setState(() => _provinces = provinces);
  }

  Future<void> _loadDistricts(String provinceId) async {
    setState(() {
      _districts = [];
      _corregimientos = [];
      _selectedDistrict = null;
      _selectedCorregimiento = null;
    });
    final districts = await _locationService.fetchDistrictsByProvinceId(provinceId);
    setState(() => _districts = districts);
  }

  Future<void> _loadCorregimientos(String districtId) async {
    setState(() {
      _corregimientos = [];
      _selectedCorregimiento = null;
    });
    final corregimientos = await _locationService.fetchCorregimientosByDistrictId(districtId);
    setState(() => _corregimientos = corregimientos);
  }

  Future<void> _autoFillAddressFromCoordinates(double lat, double long) async {
    setState(() => _isAutoFilling = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Lógica de auto-rellenado simplificada para brevedad
        LocationModel? foundProvince;
        try {
           foundProvince = _provinces.firstWhere((p) => place.administrativeArea?.toLowerCase().contains(p.name.toLowerCase()) ?? false);
        } catch (_) {}

        if (foundProvince != null) {
           setState(() => _selectedProvince = foundProvince);
           await _loadDistricts(foundProvince.id);
           // (Aquí iría la lógica para Distrito y Corregimiento similar al RegisterScreen)
        }
      }
    } catch (e) {
      print("Error geocoding: $e");
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      await _autoFillAddressFromCoordinates(result.latitude, result.longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ubicación seleccionada.'), backgroundColor: AppColors.success));
      }
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProvince == null || _selectedDistrict == null || _selectedCorregimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete la dirección.'), backgroundColor: AppColors.danger));
        return;
      }

      try {
        final userAddress = UserAddressModel(
          province: _selectedProvince!.name,
          district: _selectedDistrict!.name,
          corregimiento: _selectedCorregimiento!.name,
          barrio: _barrioController.text,
          house: _casaController.text,
          latitude: _latitude,
          longitude: _longitude,
        );

        final user = UserModel(
          id: '',
          nombre: _nameController.text,
          correo: _emailController.text,
          contrasena: _passwordController.text,
          telefono: _phoneController.text,
          direccion: userAddress,
          rol: widget.selectedRole, // Usa el rol pasado por el padre
        );

        String message = await _authService.registerUser(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.success));
        }

        // Resetear
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
        _barrioController.clear();
        _casaController.clear();
        setState(() {
          _selectedProvince = null;
          _selectedDistrict = null;
          _selectedCorregimiento = null;
          _districts = [];
          _corregimientos = [];
          _latitude = null;
          _longitude = null;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
        }
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.white54)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
      ),
      validator: (v) {
        if (v!.isEmpty) return 'Requerido';
        if (label.contains('Correo') && !v.contains('@')) return 'Inválido';
        if (label.contains('Contraseña') && v.length < 6) return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildLocationDropdown(String label, LocationModel? selectedValue, List<LocationModel> items, void Function(LocationModel?) onChanged) {
    return DropdownButtonFormField<LocationModel>(
      value: selectedValue,
      dropdownColor: AppColors.secondary,
      style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.white54)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
      ),
      isExpanded: true,
      items: items.map((value) => DropdownMenuItem(value: value, child: Text(value.name))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            _buildTextField(_nameController, 'Nombre Completo'),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Contraseña', isPassword: true),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Teléfono', keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dirección (Panamá)', style: AppTextStyles.h4.copyWith(color: AppColors.accent)),
                if (_isAutoFilling) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
                onPressed: _isAutoFilling ? null : _pickLocation,
                icon: Icon(_latitude != null ? Icons.check_circle : Icons.map, color: Colors.white),
                label: Text(_latitude != null ? 'Ubicación Seleccionada' : 'Seleccionar en Mapa', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: _latitude != null ? AppColors.success : AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                ),
            ),
            const SizedBox(height: 16),

            _buildLocationDropdown('Provincia', _selectedProvince, _provinces, (v) { setState(() { _selectedProvince = v; _selectedDistrict = null; _selectedCorregimiento = null; if(v!=null) _loadDistricts(v.id); }); }),
            const SizedBox(height: 16),
            _buildLocationDropdown('Distrito', _selectedDistrict, _districts, (v) { setState(() { _selectedDistrict = v; _selectedCorregimiento = null; if(v!=null) _loadCorregimientos(v.id); }); }),
            const SizedBox(height: 16),
            _buildLocationDropdown('Corregimiento', _selectedCorregimiento, _corregimientos, (v) { setState(() => _selectedCorregimiento = v); }),
            const SizedBox(height: 16),
            _buildTextField(_barrioController, 'Barrio / PH / Edificio'),
            const SizedBox(height: 16),
            _buildTextField(_casaController, 'Casa / Apartamento No.'),
            const SizedBox(height: 32),
            
            ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Registrar', style: AppTextStyles.button),
            ),
            const SizedBox(height: 40),
        ],
      ),
    );
  }
}


// =============================================================================
// TAB 2: CREAR CITA PARA CLIENTE (Sin Cambios Lógicos, Solo Estilo)
// =============================================================================

class _BuildCreateAppointmentTab extends StatefulWidget {
  const _BuildCreateAppointmentTab();
  @override
  __BuildCreateAppointmentTabState createState() => __BuildCreateAppointmentTabState();
}

class __BuildCreateAppointmentTabState extends State<_BuildCreateAppointmentTab> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final UserApiService _userApiService = UserApiService();
  final ServicioService _servicioService = ServicioService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedClientId;
  
  // 💡 CAMBIO: Ahora usamos CategoriaPrincipalModel (que son los Servicios)
  CategoriaPrincipalModel? _selectedService; 
  ProductModel? _selectedProduct;
  double _costoTotal = 0.0;

  // 💡 CAMBIO: El futuro devuelve CategoriaPrincipalModel
  Future<List<CategoriaPrincipalModel>>? _servicesFuture;
  Future<List<ProductModel>>? _productsFuture;
  Future<List<UserModel>>? _clientsFuture; 

  @override
  void initState() {
    super.initState();
    // 💡 CAMBIO: Llamamos a fetchCategoriasPrincipales en lugar de fetchServicios
    _servicesFuture = _servicioService.fetchCategoriasPrincipales();
    _clientsFuture = _fetchClients(); 
  }

  Future<List<UserModel>> _fetchClients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      UserModel(id: 'cliente1@mail.com', nombre: 'Cliente 1', correo: 'cliente1@mail.com', telefono: '60001000', rol: 'user'),
      UserModel(id: 'cliente2@mail.com', nombre: 'Cliente 2', correo: 'cliente2@mail.com', telefono: '60002000', rol: 'user'),
    ];
  }
  
  @override
  void dispose() {
      _descriptionController.dispose();
      super.dispose();
  }

  // 💡 CAMBIO: Recibe CategoriaPrincipalModel
  void _updateProducts(CategoriaPrincipalModel? service) {
      setState(() {
        _selectedService = service;
        _selectedProduct = null;
        // fetchProductos usa el ID, que CategoriaPrincipalModel tiene, así que esto funciona
        _productsFuture = service != null ? _servicioService.fetchProductos(service.id) : null;
      });
  }

  Future<void> _selectDateTime(BuildContext context) async {
      final pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2028));
      if(pickedDate != null) {
          final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if(pickedTime != null) {
              setState(() {
                  _selectedDate = pickedDate;
                  _selectedTime = pickedTime;
              });
          }
      }
  }

  void _createAppointment() async {
      if(_formKey.currentState!.validate() && _selectedClientId != null && _selectedProduct != null && _selectedDate != null && _selectedTime != null) {
          final dt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
          
          try {
            final citaData = {
                'usuarioId': _selectedClientId,
                'serviciosSeleccionados': [_selectedProduct!.id],
                'fechaHora': dt.toIso8601String(),
                'estado': 'confirmada',
                'costoTotal': _costoTotal,
                'descripcion': _descriptionController.text,
                'tecnicoId': 'admin_scheduled'
            };

            await _userApiService.createAppointment(citaData);
            
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita creada.'), backgroundColor: AppColors.success));
            
            _formKey.currentState!.reset();
            setState(() { _selectedService = null; _selectedProduct = null; _selectedDate = null; _selectedTime = null; _costoTotal = 0.0; });

          } catch (e) {
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
          }
      } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete campos.'), backgroundColor: AppColors.danger));
      }
  }

  InputDecoration _inputDeco(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.white54)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Text('Programar Nueva Cita', style: AppTextStyles.h2.copyWith(color: AppColors.accent)),
                    const SizedBox(height: 24),
                    
                    // CLIENTE
                    FutureBuilder<List<UserModel>>(
                        future: _clientsFuture,
                        builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                            return DropdownButtonFormField<String>(
                                value: _selectedClientId,
                                dropdownColor: AppColors.secondary,
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
                                decoration: _inputDeco('Cliente Asignado'),
                                items: (snapshot.data ?? []).map((c) => DropdownMenuItem(value: c.correo, child: Text('${c.nombre} (${c.correo})'))).toList(),
                                onChanged: (v) => setState(() => _selectedClientId = v),
                                validator: (v) => v == null ? 'Requerido' : null,
                            );
                        }
                    ),
                    const SizedBox(height: 16),

                    // SERVICIO (CATEGORÍA)
                    // 💡 CAMBIO: FutureBuilder de CategoriaPrincipalModel
                    FutureBuilder<List<CategoriaPrincipalModel>>(
                        future: _servicesFuture,
                        builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                             return DropdownButtonFormField<CategoriaPrincipalModel>(
                                value: _selectedService,
                                dropdownColor: AppColors.secondary,
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
                                decoration: _inputDeco('Categoría / Servicio'),
                                items: (snapshot.data ?? []).map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                                onChanged: _updateProducts,
                            );
                        }
                    ),
                    const SizedBox(height: 16),
                    
                    // PRODUCTO
                    FutureBuilder<List<ProductModel>>(
                        future: _productsFuture,
                        builder: (context, snapshot) {
                             return DropdownButtonFormField<ProductModel>(
                                value: _selectedProduct,
                                dropdownColor: AppColors.secondary,
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
                                decoration: _inputDeco('Producto'),
                                items: (snapshot.data ?? []).map((p) => DropdownMenuItem(value: p, child: Text('${p.nombre} (\$${p.costo})'))).toList(),
                                onChanged: (p) => setState(() { _selectedProduct = p; _costoTotal = p?.costo ?? 0.0; }),
                                validator: (v) => v == null ? 'Requerido' : null,
                            );
                        }
                    ),
                    // ... Resto del formulario (Fecha, Hora, Botón) igual ...
                    const SizedBox(height: 24),
                    
                    ElevatedButton.icon(
                        onPressed: () => _selectDateTime(context),
                        icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                        label: Text(_selectedDate == null ? 'Seleccionar Fecha' : DateFormat('dd/MM/yyyy HH:mm').format(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime?.hour ?? 0, _selectedTime?.minute ?? 0)), style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
                        decoration: _inputDeco('Descripción'),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton.icon(
                        onPressed: _createAppointment,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirmar Cita'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.elevatedButton, padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                ],
            ),
        ),
    );
  }
}