import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/api_service.dart';

class UserApiService extends ApiService {
  
  Future<List<AppointmentModel>> fetchAppointmentsByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/citas/usuario/$userId');
    
    // 🔴 ESTO ESTABA MAL: final headers = getHeaders();
    // (Daba error porque getHeaders devuelve un Future, no el Map directo)

    // ✅ CORRECCIÓN: Agregamos 'await' para esperar a que SharedPreferences lea el token
    final headers = await getHeaders(); 

    print("🚀 Enviando petición a: $url");
    print("📦 Headers reales: $headers"); 

    final response = await http.get(
      url, 
      headers: headers, // Ahora sí le pasamos el Map<String, String>
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar citas: ${response.statusCode}');
    }
  }

  // 2. ACTUALIZAR CITA
  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/citas/$appointmentId');
    
    // 🔴 CAMBIO CLAVE: 'await' aquí también
    final headers = await getHeaders();

    // DEBUG
    print("Intentando actualizar cita: $appointmentId");
    print("Token enviado: ${headers['Authorization'] != null ? 'SÍ' : 'NO'}");

    final response = await http.put(
      url,
      headers: headers, 
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return; // Éxito
    } else {
      print("Error Update: ${response.body}");
      throw Exception('Error al actualizar (${response.statusCode}): ${response.body}');
    }
  }

  // 3. CREAR CITA (Admin)
  Future<void> createAppointment(Map<String, dynamic> citaData) async {
    // 🔴 CAMBIO CLAVE: 'await'
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/citas'),
      headers: headers,
      body: jsonEncode(citaData),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear la cita: ${response.body}');
    }
  }

  // 4. OBTENER TODAS LAS CITAS (Admin)
  Future<List<AppointmentModel>> fetchAllAppointments() async {
    try {
      // 🔴 CAMBIO CLAVE: 'await'
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/citas'),
        headers: headers,
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