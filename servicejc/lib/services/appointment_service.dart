import 'package:http/http.dart' as http;
import 'package:servicejc/models/cita_model.dart';
import 'dart:convert';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/api_service.dart';
import 'package:servicejc/models/product_model.dart'; // Importación necesaria

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

  // CORRECCIÓN CLAVE: Agregando /api/ a la ruta de citas
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

  Future<void> createAppointment(
    AppointmentModel appointment,
    String token,
  ) async {
    final response = await http.post(
      // Asumo que esta ruta también debe ser /api/citas
      Uri.parse('$baseUrl/citas'),
      headers: getHeaders(token: token),
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la cita: ${response.body}');
    }
  }
}
