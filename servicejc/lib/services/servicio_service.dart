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
    
    // ✅ CORRECCIÓN 1: Esperamos los headers
    final headers = await getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/categorias_principales'), // ✅ ESTE ES EL ENDPOINT CON EL ORDEN
      headers: headers, 
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
    
    // ✅ CORRECCIÓN 2: Esperamos los headers
    final headers = await getHeaders();

    // Nota: Tu URL corregida está perfecta aquí abajo
    final response = await http.get(
      Uri.parse('$baseUrl/servicios/$servicioId/productos'), 
      headers: headers, // Pasamos la variable ya lista
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode} - ${response.body}');
    }
  }
}