import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL de producción
  final String _baseUrl = 'https://servicejc-api-469322066501.us-central1.run.app/api';

  String get baseUrl => _baseUrl;

  // Obtenemos los headers siempre frescos desde SharedPreferences
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Dejamos el método vacío por si alguna otra pantalla lo estaba llamando, para que no de error
  static void clearToken() {
    // Ya no es necesario hacer nada aquí
  }
}