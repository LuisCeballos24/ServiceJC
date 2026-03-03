import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/testimonio_model.dart';
import 'package:servicejc/services/api_service.dart'; 

class TestimonioService extends ApiService {
  
  // 1. Obtener testimonios
  Future<List<TestimonioModel>> getTestimoniosDestacados() async {
    try {
      final url = Uri.parse('$baseUrl/testimonios/destacados');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => TestimonioModel.fromJson(json)).toList();
      } else {
        print('Error ${response.statusCode}: No se pudieron cargar testimonios');
        return [];
      }
    } catch (e) {
      print('Error conectando con testimonios: $e');
      return [];
    }
  }

  // 2. ✅ NUEVO MÉTODO: Llamar al Seed (Poblar base de datos)
  Future<bool> seedTestimonios() async {
    try {
      // Llamamos al endpoint que creaste en Java: @GetMapping("/seed")
      final url = Uri.parse('$baseUrl/testimonios/seed');
      
      print("🌱 Intentando poblar base de datos (Seed)...");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("✅ Seed ejecutado correctamente: ${response.body}");
        return true;
      } else {
        print("❌ Error en seed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error conectando seed: $e");
      return false;
    }
  }
 Future<bool> enviarTestimonio(TestimonioModel testimonio) async {
    try {
      final url = Uri.parse('$baseUrl/testimonios/crear');
      
      final headers = await getHeaders(); 

      // Construimos el JSON
      final body = jsonEncode({
          // ⚠️ TRUCO: Enviamos string vacío o "Anónimo". 
          // El Backend usará el Token para buscar al usuario en la BD 
          // y pondrá el nombre correcto automáticamente.
          "nombreCliente": "Usuario Autenticado", 
          
          "comentario": testimonio.comentario,
          "calificacion": testimonio.calificacion,
          
          // Esto también lo fuerza el backend a true, pero lo mandamos por si acaso
          "destacado": true 
      });

      print("📤 Enviando comentario...");

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Error Backend: ${response.body}");
        return false;
      }

    } catch (e) {
      print("❌ Error App: $e");
      return false;
    }
  }
}