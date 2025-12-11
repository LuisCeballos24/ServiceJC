import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Necesario para File
import '../models/cita_model.dart';
import '../models/service_model.dart';
// Mantenido por compatibilidad
import 'api_service.dart';

class AppointmentService extends ApiService {
  Future<List<ServiceModel>> fetchServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicios'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los servicios: ${response.body}');
    }
  }

  Future<List<CitaModel>> fetchCitas() async {
    final response = await http.get(
      // Usar /api/citas, que es donde responde tu CitaController
      Uri.parse('$baseUrl/citas'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // El mapeo aquí funcionará gracias a los cambios de Null Safety en CitaModel.
      return data.map((json) => CitaModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las citas: ${response.body}');
    }
  }

  /// Envía los datos de la cita y la foto (opcional) usando multipart/form-data.
  /// El backend (Java) procesa la imagen y almacena su URL en Firestore.
  ///
  /// @param cita Los datos de la cita.
  /// @param photoFile El archivo de imagen (máximo uno, o null).
  Future<void> createCita(CitaModel cita, {File? photoFile}) async {
    // Usamos MultipartRequest para enviar el JSON de la cita y la imagen
    final uri = Uri.parse('$baseUrl/citas');
    final request = http.MultipartRequest('POST', uri);

    // 1. Añadir Headers de autenticación (Asumimos que getHeaders() maneja esto)
    request.headers.addAll(getHeaders());

    // 2. Añadir el archivo de imagen (si existe)
    if (photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          // Nombre del campo esperado en Java: @RequestPart(value = "file")
          'file',
          photoFile.path,
        ),
      );
    }

    // 3. Añadir el JSON de la Cita
    // El nombre del campo debe coincidir con @RequestPart("cita") en Java
    final citaJsonString = jsonEncode(cita.toJson());
    request.fields['cita'] = citaJsonString;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      print('Error en la respuesta del servidor: ${response.body}');
      throw Exception(
        'Error al crear la cita (${response.statusCode}): ${response.body}',
      );
    }
  }
}
