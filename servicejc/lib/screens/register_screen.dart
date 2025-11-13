import 'package:flutter/material.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/user_address_model.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/models/location_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _barrioController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();

  bool _isTechnicianApplicant = false;

  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _corregimientos = [];

  LocationModel? _selectedProvince;
  LocationModel? _selectedDistrict;
  LocationModel? _selectedCorregimiento;

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

  void _registerUser() async {
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

    final userRole = _isTechnicianApplicant ? 'tecnico' : 'user';

    final userAddress = UserAddressModel(
      province: _selectedProvince!.name,
      district: _selectedDistrict!.name,
      corregimiento: _selectedCorregimiento!.name,
      barrio: _barrioController.text,
      house: _casaController.text,
    );

    try {
      final user = UserModel(
        id: '',
        nombre: _nameController.text,
        correo: _emailController.text,
        contrasena: _passwordController.text,
        telefono: _phoneController.text,
        direccion: userAddress,
        rol: userRole,
      );

      String message = await _authService.registerUser(user);

      String finalMessage = message;
      if (_isTechnicianApplicant) {
        finalMessage +=
            '\nSe ha enviado un correo con los pasos para completar tu postulación como Técnico.';
      } else {
        finalMessage += '\nRecibirás un correo de confirmación de cuenta.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            finalMessage,
            style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al registrar usuario: ${e.toString()}',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: AppColors.secondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? selectedValue,
    List<T> items,
    void Function(T?) onChanged, {
    String Function(T)? itemLabel,
  }) {
    final labelGetter = itemLabel ?? (item) => (item as LocationModel).name;
    return DropdownButtonFormField<T>(
      dropdownColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: AppColors.secondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      initialValue: selectedValue,
      isExpanded: true,
      items: items.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(
            labelGetter(value),
            style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
          ),
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
        title: Text(
          'Registro',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
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
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: <Widget>[
                  Text(
                    'Crea una cuenta para solicitar servicios.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.white54),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Postularme como Técnico',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Activar para recibir un correo con los requisitos de postulación.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      value: _isTechnicianApplicant,
                      onChanged: (bool value) {
                        setState(() {
                          _isTechnicianApplicant = value;
                        });
                      },
                      activeThumbColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Dirección (Panamá)',
                    style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 16),
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
                  _buildTextField(_barrioController, 'Barrio / PH / Edificio'),
                  const SizedBox(height: 16),
                  _buildTextField(_casaController, 'Casa / Apartamento No.'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: Text(
                      'Registrarse',
                      style: AppTextStyles.elevatedButton,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
