import 'package:flutter/material.dart';
import 'package:servicejc/models/location_model.dart';
import 'package:servicejc/services/location_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/screens/coordinar_cita_screen.dart'; // ¡NUEVA PANTALLA DE DESTINO!

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
      _districts = await _locationService.fetchDistrictsByProvinceId(
        provinceId,
      );
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
      _corregimientos = await _locationService.fetchCorregimientosByDistrictId(
        districtId,
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error al cargar los corregimientos.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      // Asegurarse de que las ubicaciones jerárquicas están seleccionadas
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
            // *** CORRECCIÓN APLICADA AQUÍ ***
            subtotal: widget.subtotal,
            discountAmount: widget.discountAmount,
            // ******************************
            province: _selectedProvince!,
            district: _selectedDistrict!,
            corregimiento: _selectedCorregimiento!,
            barrio: _barrioController.text.trim(),
            casa: _casaController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dirección de Domicilio'),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppColors.accent),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: <Widget>[
            // Resumen de la orden
            Card(
              color: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
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
                            color: AppColors.white,
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

            // Dropdowns de Ubicación
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
            ElevatedButton(
              onPressed: _onContinue,
              child: const Text('Continuar a Coordinar Cita'),
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
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required List<LocationModel> items,
    required LocationModel? selectedItem,
    required void Function(LocationModel?) onChanged,
    required bool isEnabled,
  }) {
    return DropdownButtonFormField<LocationModel>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: isEnabled
            ? AppColors.secondary
            : AppColors.softWhite.withOpacity(0.1),
      ),
      value: selectedItem,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
          .toList(),
      onChanged: isEnabled ? onChanged : null,
      validator: (value) => value == null ? 'Seleccione una opción' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: AppColors.secondary,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Este campo es requerido' : null,
    );
  }
}
