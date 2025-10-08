import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/api_service.dart';

class UserApiService extends ApiService {
  // Método para obtener citas de un usuario específico
  Future<List<AppointmentModel>> fetchAppointmentsByUserId(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/citas/usuario/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar las citas del usuario: ${response.body}',
      );
    }
  }

  // NUEVO MÉTODO: Crear una cita (usado por el administrador)
  Future<void> createAppointment(Map<String, dynamic> citaData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/citas'),
      headers: getHeaders(),
      body: jsonEncode(citaData),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la cita: ${response.body}');
    }
  }

  // NUEVO MÉTODO: Obtener todas las citas para el panel de administración
  Future<List<AppointmentModel>> fetchAllAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/citas'),
        headers: getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => AppointmentModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Error al cargar todas las citas: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo la conexion con el servidor: $e');
    }
  }
}
