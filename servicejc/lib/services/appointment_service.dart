import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/api_service.dart';

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

  Future<void> createAppointment(AppointmentModel appointment, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/citas'),
      headers: getHeaders(token: token),
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la cita: ${response.body}');
    }
  }
}