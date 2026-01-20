import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/models/categoria_principal_model.dart'; 
import 'package:servicejc/services/api_service.dart';

class ServicioService extends ApiService {
  
  // ----------------------------------------------------
  // NIVEL 1: PANTALLA PRINCIPAL (Home)
  // ----------------------------------------------------
  Future<List<CategoriaPrincipalModel>> fetchCategoriasPrincipales() async {
    // Llamamos a /servicios porque en tu Controller Java tienes @GetMapping("/servicios")
    // que devuelve la lista base.
    final response = await http.get(
      Uri.parse('$baseUrl/servicios'), 
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CategoriaPrincipalModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar servicios: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------
  // NIVEL 2: PRODUCTOS (Detalle del Servicio)
  // ----------------------------------------------------
  Future<List<ProductModel>> fetchProductos(String servicioId) async {
    
    // 🔴 CORRECCIÓN CRÍTICA AQUÍ:
    // Antes tenía: '$baseUrl/productos?servicioId=$servicioId' (ESTO ESTABA MAL)
    // Ahora debe ser: '$baseUrl/servicios/$servicioId/productos' (ESTO COINCIDE CON TU JAVA)
    
    final response = await http.get(
      Uri.parse('$baseUrl/servicios/$servicioId/productos'), 
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode} - ${response.body}');
    }
  }
}