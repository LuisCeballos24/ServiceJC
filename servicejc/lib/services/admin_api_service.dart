import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tecnico.dart';

class AdminApiService {
  final String _baseUrl = 'http://localhost:8080/api/admin'; // Usa la URL de tu API

  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final response = await http.get(Uri.parse('$_baseUrl/metrics'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar las métricas del dashboard');
    }
  }

  Future<void> eliminarTecnico(String tecnicoId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/tecnicos/$tecnicoId'));

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el técnico');
    }
  }

  Future<void> reasignarCita(String citaId, String nuevoTecnicoId, DateTime nuevaFechaHora) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/citas/$citaId/reasignar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nuevoTecnicoId': nuevoTecnicoId,
        'nuevaFechaHora': nuevaFechaHora.toIso8601String(), // Formato ISO 8601 para la fecha y hora
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al reasignar la cita');
    }
  }
}