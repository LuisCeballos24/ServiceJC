import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart'; 

class PaymentBackendService extends ApiService {
  
  Future<void> procesarPagoBackend(Map<String, dynamic> solicitudPago) async {
    final url = Uri.parse('$baseUrl/pagos/procesar'); 
    
    // 1. Obtenemos los headers (Token)
    final headers = await getHeaders();

    // 2. VITAL: Asegurarnos de que el servidor sepa que es un JSON
    // (A veces getHeaders() no lo trae o se borró en otra pantalla)
    headers['Content-Type'] = 'application/json';

    print("=========================================");
    print("🚀 ENVIANDO PAGO AL BACKEND JAVA...");
    print("URL: $url");
    print("=========================================");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(solicitudPago),
    );

    print("=========================================");
    print("📡 RESPUESTA DEL BACKEND:");
    print("Status Code: ${response.statusCode}");
    print("Body: ${response.body}");
    print("=========================================");

    // Si el pago falla (Cualquier código que no sea 200 o 201)
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        // Intentamos leer el JSON de error que mandó tu PagoController
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        // Si entra aquí, es porque el body NO era JSON (era texto plano o vacío).
        // Esto evita el pantallazo rojo "Unexpected end of JSON input"
        if (e is FormatException) {
           throw Exception('Error del Servidor (${response.statusCode}): ${response.body.isEmpty ? "Respuesta vacía" : response.body}');
        } else {
           rethrow; // Lanza el error original de la línea 39
        }
      }
    }
  }
}