import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/api_service.dart';

class UserApiService extends ApiService {
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
}
