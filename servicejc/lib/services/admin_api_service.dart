import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'api_service.dart'; 

class AdminApiService extends ApiService {
  
  // ---------------------------------------------------------------------------
  // 1. MÉTRICAS DEL DASHBOARD
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    // ✅ CORRECCIÓN: Esperamos el token
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/metrics'),
      headers: headers, // Usamos la variable
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar las métricas del dashboard');
    }
  }

  // ---------------------------------------------------------------------------
  // 2. ELIMINAR TÉCNICO
  // ---------------------------------------------------------------------------
  Future<void> eliminarTecnico(String tecnicoId) async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/tecnicos/$tecnicoId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el técnico');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. OBTENER LISTA DE TÉCNICOS
  // ---------------------------------------------------------------------------
  Future<List<UserModel>> fetchTechnicians() async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/tecnicos'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<UserModel>.from(
        data.map((model) => UserModel.fromJson(model)),
      );
    } else {
      throw Exception('Error al obtener la lista de técnicos: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // 4. OBTENER CITAS POR ID DE TÉCNICO
  // ---------------------------------------------------------------------------
  Future<List<CitaModel>> fetchCitasByTechnicianId(String technicianId) async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/citas/tecnico/$technicianId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CitaModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las citas asignadas: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 5. ACTUALIZAR CITA
  // ---------------------------------------------------------------------------
  Future<CitaModel> updateCita(CitaModel cita) async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();
    
    final citaJson = cita.toJson();

    final response = await http.put(
      Uri.parse('$baseUrl/citas/${cita.id}'),
      headers: headers,
      body: jsonEncode(citaJson),
    );

    if (response.statusCode == 200) {
      return CitaModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la cita: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 6. ACTUALIZAR TÉCNICO
  // ---------------------------------------------------------------------------
  Future<UserModel> updateTecnico(UserModel tecnico) async {
    if (tecnico.id == null || tecnico.id!.isEmpty) {
      throw Exception('El ID del técnico es requerido para la actualización.');
    }

    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.put(
      Uri.parse('$baseUrl/admin/tecnicos/${tecnico.id}'),
      headers: headers,
      body: jsonEncode(tecnico.toJson()),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el técnico: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // 7. REASIGNAR CITA
  // ---------------------------------------------------------------------------
  Future<void> reasignarCita(String citaId, String nuevoTecnicoId, DateTime nuevaFechaHora) async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.patch(
      Uri.parse('$baseUrl/admin/citas/$citaId/reasignar'),
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'nuevoTecnicoId': nuevoTecnicoId,
        'nuevaFechaHora': nuevaFechaHora.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al reasignar la cita');
    }
  }

  // ---------------------------------------------------------------------------
  // 8. OBTENER CLIENTES
  // ---------------------------------------------------------------------------
  Future<List<UserModel>> getClients() async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/admin/clients'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<UserModel>.from(
        data.map((model) => UserModel.fromJson(model)),
      );
    } else {
      throw Exception('Error al obtener la lista de clientes: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // 9. ELIMINAR USUARIO (CLIENTE)
  // ---------------------------------------------------------------------------
  Future<void> deleteUser(String userId) async {
    // ✅ CORRECCIÓN
    final headers = await getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/clients/$userId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el usuario: ${response.body}');
    }
  }
}