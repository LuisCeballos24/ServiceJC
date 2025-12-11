import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:servicejc/theme/app_colors.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(8.9824, -79.5199); // Default: Panamá
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. Verificar si el servicio de ubicación está habilitado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('El GPS está desactivado. Actívalo para ver tu ubicación.')),
           );
        }
        // Si no hay GPS, mostramos el mapa en la posición por defecto
        setState(() => _isLoading = false);
        return;
      }

      // 2. Verificar permisos
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Permiso de ubicación denegado.')),
             );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Permisos denegados permanentemente.')),
             );
          }
        setState(() => _isLoading = false);
        return;
      }

      // 3. Obtener posición
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high 
      );
      
      // Actualizamos la posición ANTES de mostrar el mapa
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false; // ¡Ahora sí mostramos el mapa!
        });
      }

    } catch (e) {
      print("Error obteniendo ubicación: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
           IconButton(
             icon: const Icon(Icons.my_location),
             onPressed: () {
                // Re-centrar manualmente si el usuario se perdió
                _mapController?.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition)
                );
             },
             tooltip: 'Mi Ubicación',
           )
        ],
      ),
      // CAMBIO CLAVE: Si está cargando, mostramos SOLO el indicador.
      // El mapa no se construye hasta tener la ubicación real.
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition, // Aquí ya viene la ubicación real
                  zoom: 16, // Zoom más cercano para ver mejor la casa
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onCameraMove: (position) {
                  _currentPosition = position.target;
                },
              ),
              
              // Marcador central
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_pin, size: 50, color: AppColors.danger),
                ),
              ),

              // Botón Confirmar
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _currentPosition);
                  },
                  child: const Text(
                    'Confirmar esta Ubicación',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}