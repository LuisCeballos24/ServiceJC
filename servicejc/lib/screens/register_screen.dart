import 'package:flutter/material.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/user_address_model.dart'; // Nuevo modelo de dirección
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/services/location_service.dart'; // Servicio para ubicaciones
import 'package:servicejc/models/location_model.dart'; // Modelo de ubicación geográfica

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de campos básicos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _barrioController =
      TextEditingController(); // Nuevo
  final TextEditingController _casaController =
      TextEditingController(); // Nuevo

  // NUEVO: Estado para la postulación a Técnico
  bool _isTechnicianApplicant = false;

  // Instancias de servicios
  final AuthService _authService = AuthService();
  final LocationService _locationService =
      LocationService(); // Nueva instancia del servicio

  // Variables de estado para la ubicación
  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _corregimientos = [];

  LocationModel? _selectedProvince;
  LocationModel? _selectedDistrict;
  LocationModel? _selectedCorregimiento;

  @override
  void initState() {
    super.initState();
    _loadProvinces(); // Cargar la lista inicial de provincias al iniciar la pantalla
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _barrioController.dispose();
    _casaController.dispose();
    _locationService.dispose(); // Buena práctica liberar el cliente HTTP
    super.dispose();
  }

  // Lógica de carga de ubicaciones
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

  void _registerUser() async {
    // Validar que se hayan seleccionado las ubicaciones jerárquicas
    if (_selectedProvince == null ||
        _selectedDistrict == null ||
        _selectedCorregimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos de dirección.'),
        ),
      );
      return;
    }

    // Determinar el rol basado en el interruptor
    final userRole = _isTechnicianApplicant ? 'tecnico' : 'user';

    // Crear el modelo de dirección
    final userAddress = UserAddressModel(
      province: _selectedProvince!.name,
      district: _selectedDistrict!.name,
      corregimiento: _selectedCorregimiento!.name,
      barrio: _barrioController.text,
      house: _casaController.text,
    );

    try {
      // Crear el modelo de usuario con el rol determinado
      final user = UserModel(
        id: '', // El backend asignará el ID
        nombre: _nameController.text,
        correo: _emailController.text,
        contrasena: _passwordController.text,
        telefono: _phoneController.text,
        direccion: userAddress, // Añadiendo la dirección al usuario
        rol: userRole, // AHORA ES DINÁMICO
      );

      String message = await _authService.registerUser(user);

      // Lógica de feedback basada en la postulación
      String finalMessage = message;
      if (_isTechnicianApplicant) {
        finalMessage +=
            '\nSe ha enviado un correo con los pasos para completar tu postulación como Técnico.';
      } else {
        finalMessage += '\nRecibirás un correo de confirmación de cuenta.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(finalMessage),
          duration: const Duration(seconds: 4),
        ),
      );
      // Navega a la pantalla de login después del registro exitoso
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: ${e.toString()}')),
      );
    }
  }

  // Widget genérico para los campos de texto
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // Añadido para manejar la contraseña
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
      ),
    );
  }

  // Widget genérico para los Dropdowns
  Widget _buildDropdown<T>(
    String label,
    T? selectedValue,
    List<T> items,
    void Function(T?) onChanged, {
    String Function(T)? itemLabel, // Función para obtener el texto a mostrar
  }) {
    // Si no se proporciona una función de etiqueta, asumimos que T es LocationModel
    final labelGetter = itemLabel ?? (item) => (item as LocationModel).name;

    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
      ),
      value: selectedValue,
      isExpanded: true,
      items: items.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(labelGetter(value)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Seleccione $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Color.fromRGBO(52, 73, 94, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(52, 73, 94, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(230, 240, 250, 1),
              Color.fromRGBO(255, 255, 255, 1),
            ],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                // Cambiamos Column a ListView para manejar el scroll
                children: <Widget>[
                  const Text(
                    'Crea una cuenta para solicitar servicios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(52, 73, 94, 1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(_nameController, 'Nombre Completo'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Correo Electrónico'),
                  const SizedBox(height: 16),
                  // Se actualiza para manejar la propiedad isPassword
                  _buildTextField(
                    _passwordController,
                    'Contraseña',
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Teléfono'),

                  const SizedBox(height: 32),

                  // NUEVO: Interruptor para postularse como Técnico
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Postularme como Técnico',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(52, 73, 94, 1),
                        ),
                      ),
                      subtitle: const Text(
                        'Activar para recibir un correo con los requisitos de postulación.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isTechnicianApplicant,
                      onChanged: (bool value) {
                        setState(() {
                          _isTechnicianApplicant = value;
                        });
                      },
                      activeColor: const Color.fromRGBO(39, 174, 96, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Dirección (Panamá)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(52, 73, 94, 1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Dropdown de Provincias
                  _buildDropdown<LocationModel>(
                    'Provincia',
                    _selectedProvince,
                    _provinces,
                    (LocationModel? newValue) {
                      setState(() {
                        _selectedProvince = newValue;
                        _selectedDistrict = null;
                        _selectedCorregimiento = null;
                        if (newValue != null) {
                          _loadDistricts(newValue.id);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Dropdown de Distritos
                  _buildDropdown<LocationModel>(
                    'Distrito',
                    _selectedDistrict,
                    _districts,
                    (LocationModel? newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                        _selectedCorregimiento = null;
                        if (newValue != null) {
                          _loadCorregimientos(newValue.id);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Dropdown de Corregimientos
                  _buildDropdown<LocationModel>(
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

                  // 4. Campo Barrio
                  _buildTextField(_barrioController, 'Barrio / PH / Edificio'),
                  const SizedBox(height: 16),

                  // 5. Campo Casa/Apartamento
                  _buildTextField(_casaController, 'Casa / Apartamento No.'),

                  const SizedBox(height: 32),

                  // Botón de registro
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(39, 174, 96, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 50), // Espacio extra para el scroll
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
