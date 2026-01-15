
class ApiService {
  final String _baseUrl = 'https://servicejc-api-469322066501.us-central1.run.app/api'; // <--- Cambia esto a la IP de tu servidor
  
  // Método para obtener la URL base
  String get baseUrl => _baseUrl;

  // Método para manejar los headers de la petición
  Map<String, String> getHeaders({String? token}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}