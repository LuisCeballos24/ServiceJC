import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; 
// 1. IMPORTANTE: Necesario para actualizar estado tras el pago
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../models/cita_model.dart';
import '../models/service_model.dart';
import 'api_service.dart';

class AppointmentService extends ApiService {
  
  // ---------------------------------------------------------------------------
  // 1. OBTENER SERVICIOS (IGUAL QUE EL TUYO)
  // ---------------------------------------------------------------------------
  Future<List<ServiceModel>> fetchServices() async {
    final headers = await getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/servicios'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los servicios: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // 2. OBTENER CITAS (IGUAL QUE EL TUYO)
  // ---------------------------------------------------------------------------
  Future<List<CitaModel>> fetchCitas() async {
    final headers = await getHeaders(); 
    final response = await http.get(Uri.parse('$baseUrl/citas'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CitaModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las citas: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // 3. CREAR CITA (IGUAL PERO DEVUELVE EL ID)
  // ---------------------------------------------------------------------------
  // ⚠️ CAMBIO: Devolvemos Future<String?> en vez de Future<void>
  Future<String?> createCita(CitaModel cita, {File? photoFile}) async {
    final uri = Uri.parse('$baseUrl/citas'); // O '$baseUrl/citas/crear' según tu backend
    final request = http.MultipartRequest('POST', uri);

    final authHeaders = await getHeaders();
    authHeaders.remove('Content-Type'); 
    request.headers.addAll(authHeaders);

    if (photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', photoFile.path),
      );
    }

    final citaJsonString = jsonEncode(cita.toJson());
    request.fields['cita'] = citaJsonString;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // ✅ CAMBIO: Retornamos el cuerpo de la respuesta (El ID)
      // Usamos replaceAll para limpiar comillas si el backend las manda
      return response.body.replaceAll('"', ''); 
    } else {
      print('Error en la respuesta del servidor: ${response.body}');
      throw Exception('Error al crear la cita (${response.statusCode}): ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // 4. ACTUALIZAR ESTADO (NUEVO - REQUERIDO PARA PAGOS)
  // ---------------------------------------------------------------------------
  Future<void> updateCitaStatus(String citaId, String nuevoStatus) async {
    try {
      // Actualizamos directo en Firestore para no complicar el backend ahora mismo
      await FirebaseFirestore.instance
          .collection('citas')
          .doc(citaId)
          .update({'status': nuevoStatus});
    } catch (e) {
      print("Error actualizando status: $e");
      // No lanzamos excepción para no bloquear al usuario si el pago ya pasó
    }
  }
}