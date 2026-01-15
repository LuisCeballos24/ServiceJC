import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/coordinar_cita_screen.dart';
import 'package:servicejc/screens/map_picker_screen.dart'; // Asegúrate de tener este import

class LocationSelectionScreen extends StatefulWidget {
  final Map<ProductModel, int> selectedProducts;
  final double subtotal;
  final double discountAmount;
  final double totalCost;

  const LocationSelectionScreen({
    super.key,
    required this.selectedProducts,
    required this.subtotal,
    required this.discountAmount,
    required this.totalCost,
  });

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _barrioController = TextEditingController();
  final TextEditingController _casaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<LocationModel> _provinces = [];
  List<LocationModel> _districts = [];
  List<LocationModel> _corregimientos = [];

  LocationModel? _selectedProvince;
  LocationModel? _selectedDistrict;
  LocationModel? _selectedCorregimiento;

  bool _isLoading = true;
  String? _errorMessage;
  
  // --- VARIABLES PARA EL MAPA ---
  double? _latitude;
  double? _longitude;
  bool _isAutoFilling = false;
  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  @override
  void dispose() {
    _barrioController.dispose();
    _casaController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CARGA DE DATOS ---

  Future<void> _fetchProvinces() async {
    setState(() => _isLoading = true);
    try {
      _provinces = await _locationService.fetchProvinces();
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar las provincias.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDistricts(String provinceId) async {
    setState(() {
      _isLoading = true;
      _districts = [];
      _corregimientos = [];
      _selectedDistrict = null;
      _selectedCorregimiento = null;
    });
    try {
      _districts = await _locationService.fetchDistrictsByProvinceId(provinceId);
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar los distritos.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCorregimientos(String districtId) async {
    setState(() {
      _isLoading = true;
      _corregimientos = [];
      _selectedCorregimiento = null;
    });
    try {
      _corregimientos = await _locationService.fetchCorregimientosByDistrictId(districtId);
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar los corregimientos.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- LÓGICA DEL MAPA Y AUTO-RELLENADO ---
  
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

  Future<void> _autoFillAddressFromCoordinates(double lat, double long) async {
    setState(() => _isAutoFilling = true);

    try {
      String? googleProvince;
      String? googleDistrict;
      String? googleCorregimiento;
      String? street;
      String? number;

      if (kIsWeb) {
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
                googleProvince = name; 
              } else if (types.contains('administrative_area_level_2')) {
                googleDistrict = name; 
              } else if (types.contains('locality') || types.contains('sublocality') || types.contains('neighborhood')) {
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

      // Lógica de emparejamiento con tus listas
      if (googleProvince != null) {
        LocationModel? foundProvince;
        try {
           final search = _normalize(googleProvince);
           foundProvince = _provinces.firstWhere(
             (p) => _normalize(p.name).contains(search) || search.contains(_normalize(p.name))
           );
        } catch (_) {}

        if (foundProvince != null) {
           setState(() => _selectedProvince = foundProvince);
           await _fetchDistricts(foundProvince.id);

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
               await _fetchCorregimientos(foundDistrict.id);

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
    }
  }

  // --- LÓGICA DE NAVEGACIÓN ---

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProvince == null ||
          _selectedDistrict == null ||
          _selectedCorregimiento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, complete todos los campos de ubicación.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CoordinarCitaScreen(
            selectedProducts: widget.selectedProducts,
            totalCost: widget.totalCost,
            subtotal: widget.subtotal,
            discountAmount: widget.discountAmount,
            province: _selectedProvince!,
            district: _selectedDistrict!,
            corregimiento: _selectedCorregimiento!,
            barrio: _barrioController.text.trim(),
            casa: _casaController.text.trim(),
            // Aquí podrías pasar lat/long también si tu backend lo soporta
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dirección de Domicilio',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.accent),
      ),
      body: Container(
        // Fondo degradado igual que RegisterScreen
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
              // TARJETA DE RESUMEN DE ORDEN
              Card(
                color: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: AppColors.white54, width: 0.5), // Borde sutil
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de la Orden',
                        style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.softWhite,
                            ),
                          ),
                          Text(
                            '\$${widget.subtotal.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.softWhite,
                            ),
                          ),
                        ],
                      ),
                      if (widget.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Descuento:',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                            Text(
                              '-\$${widget.discountAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(color: AppColors.white54, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total a Pagar:',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            '\$${widget.totalCost.toStringAsFixed(2)}',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // TÍTULO Y CARGADOR
              Row(
                children: [
                    Expanded(child: Text('Ubicación del Servicio', style: AppTextStyles.h4.copyWith(color: AppColors.accent))),
                    if (_isAutoFilling) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                ],
              ),
              const SizedBox(height: 16),

              // BOTÓN DEL MAPA INTEGRADO
              ElevatedButton.icon(
                onPressed: _isAutoFilling ? null : _pickLocation,
                icon: Icon(_latitude != null ? Icons.check_circle : Icons.map, color: AppColors.primary),
                label: Text(
                    _latitude != null ? 'Ubicación Seleccionada' : 'Seleccionar en Mapa', 
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _latitude != null ? Colors.greenAccent : AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 24),

              // CAMPOS DE DIRECCIÓN (Alto Contraste)
              _buildLocationDropdown(
                label: 'Provincia',
                items: _provinces,
                selectedItem: _selectedProvince,
                onChanged: (val) {
                  setState(() => _selectedProvince = val);
                  if (val != null) _fetchDistricts(val.id);
                },
                isEnabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              _buildLocationDropdown(
                label: 'Distrito',
                items: _districts,
                selectedItem: _selectedDistrict,
                onChanged: (val) {
                  setState(() => _selectedDistrict = val);
                  if (val != null) _fetchCorregimientos(val.id);
                },
                isEnabled: _selectedProvince != null && !_isLoading,
              ),
              const SizedBox(height: 16),
              _buildLocationDropdown(
                label: 'Corregimiento',
                items: _corregimientos,
                selectedItem: _selectedCorregimiento,
                onChanged: (val) => setState(() => _selectedCorregimiento = val),
                isEnabled: _selectedDistrict != null && !_isLoading,
              ),
              const SizedBox(height: 24),
              _buildTextField(_barrioController, 'Barrio / PH / Edificio'),
              const SizedBox(height: 16),
              _buildTextField(_casaController, 'Casa / Apartamento No.'),
              const SizedBox(height: 32),
              
              // BOTÓN CONTINUAR
              ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: Text(
                  'Continuar a Coordinar Cita',
                  style: AppTextStyles.button.copyWith(fontSize: 18, color: AppColors.primary),
                ),
              ),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS DE ALTO CONTRASTE (Reutilizados del RegisterScreen)

  Widget _buildLocationDropdown({
    required String label,
    required List<LocationModel> items,
    required LocationModel? selectedItem,
    required void Function(LocationModel?) onChanged,
    required bool isEnabled,
  }) {
    return Container(
      child: DropdownButtonFormField<LocationModel>(
        dropdownColor: AppColors.secondary,
        iconEnabledColor: AppColors.accent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.white54),
          floatingLabelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.accent),
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
        initialValue: selectedItem,
        style: AppTextStyles.bodyText.copyWith(color: Colors.white),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item.name,
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: isEnabled ? onChanged : null,
        validator: (value) => value == null ? 'Este campo es requerido' : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: AppTextStyles.bodyText.copyWith(color: Colors.white),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.white54),
        floatingLabelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.accent),
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
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }
}