import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
// Asegúrate de que este path sea correcto si moviste el archivo de la carpeta 'backend'
// a la carpeta 'lib'.

class LocationService {
  // *** ACTUALIZA ESTA URL BASE CON LA DIRECCIÓN REAL DE TU BACKEND SPRING BOOT ***
  static const String _apiBaseUrl = 'http://localhost:8080/api/locations';
  // O si tienes una URL pública: 'https://tu-backend-servicejc.com/api/locations'
  // **************************************************************************

  // Cliente HTTP para realizar las peticiones
  final http.Client _client = http.Client();

  /// Función genérica para realizar llamadas GET a la API y manejar la deserialización.
  Future<List<LocationModel>> _fetchFromApi(String endpoint) async {
    final uri = Uri.parse('$_apiBaseUrl/$endpoint');
    print('Fetching data from: $uri'); // Log para depuración

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        // La respuesta del backend de Spring Boot debe ser una lista JSON.
        final List<dynamic> jsonList = json.decode(
          utf8.decode(response.bodyBytes),
        );

        // Mapeamos cada objeto JSON a una instancia de LocationModel
        return jsonList
            .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Manejo de errores HTTP (404, 500, etc.)
        print(
          'Error fetching $endpoint: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      // Manejo de errores de red o parsing
      print('Network or parsing error for $endpoint: $e');
      return [];
    }
  }

  // Obtiene todas las provincias (Ruta: GET /api/locations/provinces)
  Future<List<LocationModel>> fetchProvinces() async {
    return _fetchFromApi('provinces');
  }

  // Obtiene los distritos que pertenecen a una provincia (Ruta: GET /api/locations/districts/{provinceId})
  Future<List<LocationModel>> fetchDistrictsByProvinceId(
    String provinceId,
  ) async {
    return _fetchFromApi('districts/$provinceId');
  }

  // Obtiene los corregimientos que pertenecen a un distrito (Ruta: GET /api/locations/corregimientos/{districtId})
  Future<List<LocationModel>> fetchCorregimientosByDistrictId(
    String districtId,
  ) async {
    return _fetchFromApi('corregimientos/$districtId');
  }

  // Opcional: Cerrar el cliente HTTP cuando ya no se use (buena práctica).
  void dispose() {
    _client.close();
  }
}
