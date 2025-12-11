import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar Web
import 'package:http/http.dart' as http; // Para peticiones Web
import 'dart:convert'; // Para decodificar JSON Web

import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/user_address_model.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/models/location_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:servicejc/screens/map_picker_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
// Importa flutter_dotenv si usas variables de entorno para la API KEY
// import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  double? _latitude;
  double? _longitude;
  bool _isAutoFilling = false;

  // TU API KEY DE GOOGLE (Asegúrate de tenerla aquí o en .env)
  static const String _googleApiKey = "AIzaSyAxO8pq5j9Owbp6dlfBg_sWpCWTogKWylE";

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

  // --- MÉTODOS DE CARGA DE DATOS ---

  Future<void> _loadProvinces() async {
    try {
      final provinces = await _locationService.fetchProvinces();
      if (mounted) setState(() => _provinces = provinces);
    } catch (e) {
      print("Error cargando provincias: $e");
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    setState(() {
      _districts = [];
      _corregimientos = [];
      _selectedDistrict = null;
      _selectedCorregimiento = null;
    });
    try {
      final districts = await _locationService.fetchDistrictsByProvinceId(provinceId);
      if (mounted) setState(() => _districts = districts);
    } catch (e) {
      print("Error cargando distritos: $e");
    }
  }

  Future<void> _loadCorregimientos(String districtId) async {
    setState(() {
      _corregimientos = [];
      _selectedCorregimiento = null;
    });
    try {
      final corregimientos = await _locationService.fetchCorregimientosByDistrictId(districtId);
      if (mounted) setState(() => _corregimientos = corregimientos);
    } catch (e) {
      print("Error cargando corregimientos: $e");
    }
  }

  // --- UTILIDADES DE TEXTO ---
  
  // Normaliza el texto para comparar (quita tildes y mayúsculas)
  String _normalize(String? text) {
    if (text == null) return '';
    return text.toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .trim();
  }

  // --- LÓGICA DE AUTO-RELLENADO ---

  Future<void> _autoFillAddressFromCoordinates(double lat, double long) async {
    setState(() => _isAutoFilling = true);

    try {
      String? googleProvince;
      String? googleDistrict;
      String? googleCorregimiento;
      String? street;
      String? number;

      // 1. OBTENER DATOS DE GOOGLE (Soporte Web y Móvil)
      if (kIsWeb) {
        // Lógica para WEB (Usando API HTTP directa)
        final url = Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$_googleApiKey&language=es');
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
            final result = data['results'][0];
            final components = result['address_components'] as List;

            for (var c in components) {
              final types = (c['types'] as List).cast<String>();
              final name = c['long_name'];
              
              if (types.contains('administrative_area_level_1')) {
                googleProvince = name; // Provincia
              } else if (types.contains('administrative_area_level_2')) {
                googleDistrict = name; // Distrito
              } else if (types.contains('locality') || types.contains('sublocality') || types.contains('neighborhood')) {
                // Google varía, tomamos el primero que encontremos como posible corregimiento
                googleCorregimiento ??= name;
              } else if (types.contains('route')) {
                street = name;
              } else if (types.contains('street_number')) {
                number = name;
              }
            }
          }
        }
      } else {
        // Lógica para MÓVIL (Usando paquete geocoding)
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          googleProvince = place.administrativeArea;
          googleDistrict = place.subAdministrativeArea;
          googleCorregimiento = place.locality ?? place.subLocality;
          street = place.thoroughfare;
          number = place.subThoroughfare;
        }
      }

      debugPrint("Google Data -> P: $googleProvince, D: $googleDistrict, C: $googleCorregimiento");

      // 2. EMPAREJAR CON NUESTRAS LISTAS
      if (googleProvince != null) {
        // A. Buscar Provincia
        LocationModel? foundProvince;
        try {
           final search = _normalize(googleProvince);
           foundProvince = _provinces.firstWhere(
             (p) => _normalize(p.name).contains(search) || search.contains(_normalize(p.name))
           );
        } catch (_) {}

        if (foundProvince != null) {
           setState(() => _selectedProvince = foundProvince);
           // Cargar distritos y ESPERAR
           await _loadDistricts(foundProvince.id);

           // B. Buscar Distrito
           if (googleDistrict != null) {
             LocationModel? foundDistrict;
             try {
               final search = _normalize(googleDistrict);
               foundDistrict = _districts.firstWhere(
                 (d) => _normalize(d.name).contains(search) || search.contains(_normalize(d.name))
               );
             } catch (_) {}

             if (foundDistrict != null) {
               setState(() => _selectedDistrict = foundDistrict);
               // Cargar corregimientos y ESPERAR
               await _loadCorregimientos(foundDistrict.id);

               // C. Buscar Corregimiento
               if (googleCorregimiento != null) {
                 LocationModel? foundCorregimiento;
                 try {
                   final search = _normalize(googleCorregimiento);
                   foundCorregimiento = _corregimientos.firstWhere(
                     (c) => _normalize(c.name).contains(search) || search.contains(_normalize(c.name))
                   );
                 } catch (_) {}

                 if (foundCorregimiento != null) {
                   setState(() => _selectedCorregimiento = foundCorregimiento);
                 }
               }
             }
           }
        }
      }

      // 3. RELLENAR CAMPOS DE TEXTO
      if (street != null && street.isNotEmpty) {
        _barrioController.text = street;
      }
      if (number != null && number.isNotEmpty) {
        _casaController.text = number;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dirección actualizada desde el mapa.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      debugPrint("Error en auto-rellenado: $e");
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  // MÉTODO: ABRIR EL MAPA
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
      
      // Ejecutar auto-rellenado
      await _autoFillAddressFromCoordinates(result.latitude, result.longitude);
    }
  }

  void _registerUser() async {
      // Validaciones básicas
      if (_selectedProvince == null || _selectedDistrict == null || _selectedCorregimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete la dirección (Provincia, Distrito, Corregimiento).'), backgroundColor: AppColors.danger),
        );
        return;
      }
      
      if (_latitude == null || _longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Seleccione su ubicación en el mapa.'), backgroundColor: Colors.orange),
          );
          return; 
      }

      // Construcción del modelo
      final userAddress = UserAddressModel(
        province: _selectedProvince!.name,
        district: _selectedDistrict!.name,
        corregimiento: _selectedCorregimiento!.name,
        barrio: _barrioController.text,
        house: _casaController.text,
        latitude: _latitude,
        longitude: _longitude,
      );

      final userRole = _isTechnicianApplicant ? 'tecnico' : 'user';
      final user = UserModel(
        id: '',
        nombre: _nameController.text,
        correo: _emailController.text,
        contrasena: _passwordController.text,
        telefono: _phoneController.text,
        direccion: userAddress,
        rol: userRole,
      );

      // Envío al backend
      try {
        String message = await _authService.registerUser(user);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.success),
          );
          Navigator.pop(context); // Volver al login
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
          );
        }
      }
  }

  // WIDGETS AUXILIARES
  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
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
      ),
    );
  }

  Widget _buildDropdown<T>(String label, T? selectedValue, List<T> items, void Function(T?) onChanged, {String Function(T)? itemLabel}) {
    final labelGetter = itemLabel ?? (item) => (item as LocationModel).name;
    return DropdownButtonFormField<T>(
      value: selectedValue,
      dropdownColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      isExpanded: true,
      items: items.map((T value) => DropdownMenuItem<T>(value: value, child: Text(labelGetter(value), style: AppTextStyles.bodyText.copyWith(color: AppColors.white)))).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro', style: AppTextStyles.h2.copyWith(color: AppColors.accent)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
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
                  Text('Crea una cuenta para solicitar servicios.', textAlign: TextAlign.center, style: AppTextStyles.bodyText.copyWith(color: AppColors.white70)),
                  const SizedBox(height: 32),
                  
                  _buildTextField(_nameController, 'Nombre Completo'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Contraseña', isPassword: true),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Teléfono', keyboardType: TextInputType.phone),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(15)),
                    child: SwitchListTile(
                      title: Text('Postularme como Técnico', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.white)),
                      subtitle: Text('Recibirás requisitos por correo.', style: AppTextStyles.caption.copyWith(color: AppColors.white70)),
                      value: _isTechnicianApplicant,
                      onChanged: (val) => setState(() => _isTechnicianApplicant = val),
                      activeThumbColor: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                        Expanded(child: Text('Dirección (Panamá)', style: AppTextStyles.h4.copyWith(color: AppColors.accent))),
                        if (_isAutoFilling) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN MAPA
                  ElevatedButton.icon(
                    onPressed: _isAutoFilling ? null : _pickLocation,
                    icon: Icon(_latitude != null ? Icons.check_circle : Icons.map, color: Colors.white),
                    label: Text(_latitude != null ? 'Ubicación Seleccionada' : 'Seleccionar en Mapa', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _latitude != null ? AppColors.success : AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdown<LocationModel>('Provincia', _selectedProvince, _provinces, (v) {
                    setState(() { _selectedProvince = v; _selectedDistrict = null; _selectedCorregimiento = null; if(v!=null) _loadDistricts(v.id); });
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown<LocationModel>('Distrito', _selectedDistrict, _districts, (v) {
                    setState(() { _selectedDistrict = v; _selectedCorregimiento = null; if(v!=null) _loadCorregimientos(v.id); });
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown<LocationModel>('Corregimiento', _selectedCorregimiento, _corregimientos, (v) => setState(() => _selectedCorregimiento = v)),
                  
                  const SizedBox(height: 16),
                  _buildTextField(_barrioController, 'Barrio / PH / Edificio'),
                  const SizedBox(height: 16),
                  _buildTextField(_casaController, 'Casa / Apartamento No.'),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _registerUser,
                    child: Text('Registrarse', style: AppTextStyles.elevatedButton),
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