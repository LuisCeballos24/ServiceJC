import 'package:flutter/material.dart';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/user_address_model.dart';
import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/models/service_model.dart'; // Nuevo
import 'package:servicejc/models/product_model.dart'; // Nuevo
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/services/servicio_service.dart'; // Nuevo
import 'package:servicejc/services/user_api_service.dart'; // Usado para crear la cita
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

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
        title: const Text('Gestión de Clientes y Citas'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelStyle: AppTextStyles.h3.copyWith(color: AppColors.accent),
          unselectedLabelStyle: AppTextStyles.h3.copyWith(
            color: AppColors.white54,
          ),
          tabs: const [
            Tab(
              text: 'Crear Usuario/Técnico',
              icon: Icon(Icons.person_add, color: AppColors.accent),
            ),
            Tab(
              text: 'Crear Cita para Cliente',
              icon: Icon(Icons.schedule_send, color: AppColors.accent),
            ),
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
            _BuildCreateAppointmentTab(), // Nueva pestaña implementada
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Pestaña 1: Creación de Usuarios/Técnicos (Sin cambios)
// =====================================================================
class _BuildCreateUserTab extends StatefulWidget {
  const _BuildCreateUserTab({Key? key}) : super(key: key);
  @override
  __BuildCreateUserTabState createState() => __BuildCreateUserTabState();
}

class __BuildCreateUserTabState extends State<_BuildCreateUserTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _barrioController = TextEditingController();
  final _casaController = TextEditingController();

  final LocationService _locationService = LocationService();
  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _corregimientos = [];

  LocationModel? _selectedProvince;
  LocationModel? _selectedDistrict;
  LocationModel? _selectedCorregimiento;

  String _selectedRole = 'USUARIO_FINAL';
  final AuthService _authService = AuthService();

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
    setState(() {
      _provinces = provinces;
    });
  }

  Future<void> _loadDistricts(String provinceId) async {
    setState(() {
      _districts = [];
      _corregimientos = [];
      _selectedDistrict = null;
      _selectedCorregimiento = null;
    });
    final districts = await _locationService.fetchDistrictsByProvinceId(
      provinceId,
    );
    setState(() {
      _districts = districts;
    });
  }

  Future<void> _loadCorregimientos(String districtId) async {
    setState(() {
      _corregimientos = [];
      _selectedCorregimiento = null;
    });
    final corregimientos = await _locationService
        .fetchCorregimientosByDistrictId(districtId);
    setState(() {
      _corregimientos = corregimientos;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProvince == null ||
          _selectedDistrict == null ||
          _selectedCorregimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, complete todos los campos de dirección.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      try {
        final userAddress = UserAddressModel(
          province: _selectedProvince!.name,
          district: _selectedDistrict!.name,
          corregimiento: _selectedCorregimiento!.name,
          barrio: _barrioController.text,
          house: _casaController.text,
        );

        final user = UserModel(
          id: _emailController.text,
          nombre: _nameController.text,
          correo: _emailController.text,
          contrasena: _passwordController.text,
          telefono: _phoneController.text,
          rol: _selectedRole,
          direccion: userAddress,
        );

        String message = await _authService.registerUser(user);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.success),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      validator: (v) {
        if (v!.isEmpty) return 'Campo requerido';
        if (label.contains('Correo') && !v.contains('@'))
          return 'Correo inválido';
        if (label.contains('Contraseña') && v.length < 6)
          return 'Mínimo 6 caracteres';
        return null;
      },
    );
  }

  Widget _buildLocationDropdown(
    String label,
    LocationModel? selectedValue,
    List<LocationModel> items,
    void Function(LocationModel?) onChanged,
  ) {
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      isExpanded: true,
      items: items.map<DropdownMenuItem<LocationModel>>((LocationModel value) {
        return DropdownMenuItem<LocationModel>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione $label' : null,
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
            Text(
              'Datos del Empleado/Cliente',
              style: AppTextStyles.h2.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 16),
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
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'USUARIO_FINAL',
                      child: Text('Usuario Final (Cliente)'),
                    ),
                    DropdownMenuItem(value: 'TECNICO', child: Text('Técnico')),
                    DropdownMenuItem(
                      value: 'ADMINISTRATIVO',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Nombre Completo'),
            const SizedBox(height: 16),
            _buildTextField(
              _emailController,
              'Correo Electrónico',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _passwordController,
              'Contraseña',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _phoneController,
              'Teléfono',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            Text(
              'Dirección (Panamá)',
              style: AppTextStyles.h2.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            _buildLocationDropdown('Provincia', _selectedProvince, _provinces, (
              LocationModel? newValue,
            ) {
              setState(() {
                _selectedProvince = newValue;
                _selectedDistrict = null;
                _selectedCorregimiento = null;
                if (newValue != null) {
                  _loadDistricts(newValue.id);
                }
              });
            }),
            const SizedBox(height: 16),
            _buildLocationDropdown('Distrito', _selectedDistrict, _districts, (
              LocationModel? newValue,
            ) {
              setState(() {
                _selectedDistrict = newValue;
                _selectedCorregimiento = null;
                if (newValue != null) {
                  _loadCorregimientos(newValue.id);
                }
              });
            }),
            const SizedBox(height: 16),
            _buildLocationDropdown(
              'Corregimiento',
              _selectedCorregimiento,
              _corregimientos,
              (LocationModel? newValue) {
                setState(() {
                  _selectedCorregimiento = newValue;
                });
              },
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Registrar Nuevo Empleado/Cliente',
                style: AppTextStyles.button,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Pestaña 2: Creación de Citas para Cliente
// =====================================================================
class _BuildCreateAppointmentTab extends StatefulWidget {
  const _BuildCreateAppointmentTab({Key? key}) : super(key: key);

  @override
  __BuildCreateAppointmentTabState createState() =>
      __BuildCreateAppointmentTabState();
}

class __BuildCreateAppointmentTabState
    extends State<_BuildCreateAppointmentTab> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final UserApiService _userApiService = UserApiService();
  final ServicioService _servicioService = ServicioService();

  // Estados del formulario
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedClientId; // Usaremos el ID (correo) del cliente
  ServiceModel? _selectedService;
  ProductModel? _selectedProduct;
  double _costoTotal = 0.0;

  // Datos de carga
  Future<List<ServiceModel>>? _servicesFuture;
  Future<List<ProductModel>>? _productsFuture;
  Future<List<UserModel>>? _clientsFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _servicioService.fetchServicios();
    // Simulación: asumimos que hay un endpoint para obtener clientes/usuarios finales.
    // Si no existe, este fetchClients debe implementarse en el backend.
    _clientsFuture = _fetchClients();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Función simulada para obtener clientes (debes implementar el endpoint en Java)
  Future<List<UserModel>> _fetchClients() async {
    // Esta es una SIMULACIÓN. En tu backend, deberías crear un endpoint
    // en AdminController para obtener una lista de usuarios de rol USUARIO_FINAL.
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      UserModel(
        id: 'cliente1@mail.com',
        nombre: 'Cliente 1',
        correo: 'cliente1@mail.com',
        telefono: '60001000',
        rol: 'USUARIO_FINAL',
      ),
      UserModel(
        id: 'cliente2@mail.com',
        nombre: 'Cliente 2',
        correo: 'cliente2@mail.com',
        telefono: '60002000',
        rol: 'USUARIO_FINAL',
      ),
    ];
  }

  Future<void> _updateProducts(ServiceModel? service) async {
    setState(() {
      _selectedService = service;
      _selectedProduct = null;
      _productsFuture = null;
    });

    if (service != null) {
      setState(() {
        _productsFuture = _servicioService.fetchProductos(service.id);
      });
    }
  }

  void _updateCost(ProductModel? product) {
    setState(() {
      _selectedProduct = product;
      _costoTotal = product?.costo ?? 0.0;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
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

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  String _formatDateTime() {
    if (_selectedDate == null || _selectedTime == null)
      return 'Seleccionar Fecha y Hora';
    final DateTime fullDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    return 'Fecha: ${fullDate.day}/${fullDate.month}/${fullDate.year} Hora: ${_selectedTime!.format(context)}';
  }

  void _createAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedClientId != null &&
        _selectedProduct != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      final DateTime appointmentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      try {
        final appointment = AppointmentModel(
          id: '', // Será generado por el backend
          clienteId: _selectedClientId!,
          // Usamos el ID del correo como Técnico ID (asumiendo que el admin se asigna a sí mismo o se define después)
          tecnicoId: 'admin_scheduled',
          servicioId: _selectedService!.id,
          fechaHora: appointmentDateTime.toIso8601String(),
          status: 'confirmada', // Estado inicial forzado
        );

        // **Aviso**: El endpoint de crear cita en tu backend (`/api/citas`)
        // espera un modelo 'Cita.java' que tiene `List<String> serviciosSeleccionados`
        // y `costoTotal`. El AppointmentModel de Flutter actual no mapea a esto
        // perfectamente, pero vamos a forzar la estructura que tu backend necesita.

        // Simulación de envío de datos ajustado a la estructura que el backend podría esperar
        final Map<String, dynamic> citaData = {
          'usuarioId': _selectedClientId,
          // Mapeamos el producto seleccionado al campo de servicios seleccionados (asumiendo que es una lista de IDs de producto)
          'serviciosSeleccionados': [_selectedProduct!.id],
          'fechaHora': appointmentDateTime.toIso8601String(),
          'estado': 'confirmada',
          'costoTotal': _costoTotal,
          'descripcion': _descriptionController.text,
          'tecnicoId': appointment.tecnicoId, // 'admin_scheduled'
        };

        // NOTA: El UserApiService no tiene un método para crear cita, usamos AuthService.
        // Asumiendo que el método createCita se mueve a UserApiService, o se usa AppointmentService
        // Aquí vamos a usar AppointmentService (debe importarse)
        await _userApiService.createAppointment(
          citaData,
        ); // Enviamos el mapa de datos.

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada y confirmada manualmente.'),
            backgroundColor: AppColors.success,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedService = null;
          _selectedProduct = null;
          _selectedDate = null;
          _selectedTime = null;
          _costoTotal = 0.0;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la cita: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos los campos obligatorios.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
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
            Text(
              'Programar Nueva Cita (Cobro Manual)',
              style: AppTextStyles.h2.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 24),

            // 1. Selección de Cliente
            FutureBuilder<List<UserModel>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                final clients = snapshot.data ?? [];

                return _buildCustomDropdown<String>(
                  'Cliente Asignado',
                  _selectedClientId,
                  clients
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.correo,
                          child: Text('${c.nombre} (${c.correo})'),
                        ),
                      )
                      .toList(),
                  (String? newValue) {
                    setState(() {
                      _selectedClientId = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Selección de Servicio
            FutureBuilder<List<ServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                final services = snapshot.data ?? [];

                return _buildCustomDropdown<ServiceModel>(
                  'Categoría de Servicio',
                  _selectedService,
                  services
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s, child: Text(s.nombre)),
                      )
                      .toList(),
                  _updateProducts,
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Selección de Producto
            FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (_selectedService == null) {
                  return Text(
                    'Seleccione una categoría primero.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.white70,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                final products = snapshot.data ?? [];

                return _buildCustomDropdown<ProductModel>(
                  'Producto Específico',
                  _selectedProduct,
                  products
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.nombre} (\$${p.costo.toStringAsFixed(2)})',
                          ),
                        ),
                      )
                      .toList(),
                  _updateCost,
                  isEnabled: products.isNotEmpty,
                );
              },
            ),
            const SizedBox(height: 24),

            // 4. Descripción del Requerimiento
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              decoration: _getAdminInputDecoration('Descripción Detallada'),
              validator: (v) => v!.isEmpty ? 'Descripción requerida' : null,
            ),
            const SizedBox(height: 24),

            // 5. Selección de Fecha y Hora
            ElevatedButton.icon(
              onPressed: () => _selectDateTime(context),
              icon: const Icon(Icons.calendar_today, color: AppColors.primary),
              label: Text(
                _formatDateTime(),
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Resumen de Costo
            Text(
              'Costo Estimado: \$${_costoTotal.toStringAsFixed(2)}',
              style: AppTextStyles.h3.copyWith(color: AppColors.success),
            ),
            const SizedBox(height: 24),

            // 7. Botón de Creación
            ElevatedButton.icon(
              onPressed: _createAppointment,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                'Confirmar Cita (Cobro Manual)',
                style: AppTextStyles.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.elevatedButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget de ayuda para Dropdowns
  Widget _buildCustomDropdown<T>(
    String label,
    T? selectedValue,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged, {
    bool isEnabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: selectedValue,
      dropdownColor: AppColors.secondary,
      style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
      decoration: _getAdminInputDecoration(label),
      isExpanded: true,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      validator: (value) => value == null ? 'Seleccione $label' : null,
    );
  }

  // Widget de ayuda para el estilo de inputs
  InputDecoration _getAdminInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    );
  }
}
