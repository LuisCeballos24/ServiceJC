import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'api_service.dart'; // Asegúrate de que este import sea correcto

class AdminApiService extends ApiService {
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/metrics'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar las métricas del dashboard');
    }
  }

  Future<void> eliminarTecnico(String tecnicoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/tecnicos/$tecnicoId'),
      headers: getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el técnico');
    }
  }

  Future<List<UserModel>> fetchTechnicians() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/tecnicos'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      // Mapear la respuesta del backend a List<UserModel>
      return List<UserModel>.from(
        data.map((model) => UserModel.fromJson(model)),
      );
    } else {
      throw Exception(
        'Error al obtener la lista de técnicos: ${response.body}',
      );
    }
  }

  /// Actualiza una cita (incluyendo status y tecnicoId).
  /// Endpoint: PUT /api/citas/{id} (asumiendo que está implementado en el backend)
  Future<CitaModel> updateCita(CitaModel cita) async {
    // Usamos el método toJson() de CitaModel que combina 'fecha' y 'hora'
    // en 'fechaHora' y mapea 'status' a 'estado' para el backend Java.
    final citaJson = cita.toJson();

    final response = await http.put(
      Uri.parse('$baseUrl/citas/${cita.id}'),
      headers: getHeaders(),
      body: jsonEncode(citaJson),
    );

    if (response.statusCode == 200) {
      return CitaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Error al actualizar la cita: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<UserModel> updateTecnico(UserModel tecnico) async {
    // 1. Validar ID
    if (tecnico.id == null || tecnico.id!.isEmpty) {
      throw Exception('El ID del técnico es requerido para la actualización.');
    }

    // 2. Envío de la solicitud PUT
    final response = await http.put(
      // La ruta debe coincidir con el endpoint de Java: /api/admin/tecnicos/{id}
      Uri.parse('$baseUrl/admin/tecnicos/${tecnico.id}'),
      headers: getHeaders(),
      // Envía el UserModel completo. El Backend (Java) usa solo los campos no nulos.
      body: jsonEncode(tecnico.toJson()),
    );

    if (response.statusCode == 200) {
      // Si es exitoso, mapea el objeto UserModel devuelto por el Backend
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Error al actualizar el técnico: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> reasignarCita(
    String citaId,
    String nuevoTecnicoId,
    DateTime nuevaFechaHora,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/citas/$citaId/reasignar'),
      headers: getHeaders(),
      body: jsonEncode(<String, dynamic>{
        'nuevoTecnicoId': nuevoTecnicoId,
        'nuevaFechaHora': nuevaFechaHora.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al reasignar la cita');
    }
  }

  Future<List<UserModel>> getClients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/clients'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<UserModel>.from(
        data.map((model) => UserModel.fromJson(model)),
      );
    } else {
      throw Exception(
        'Error al obtener la lista de clientes: ${response.body}',
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/clients/$userId'),
      headers: getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el usuario: ${response.body}');
    }
  }
}
