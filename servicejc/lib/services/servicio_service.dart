import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/service_model.dart'; // Modelo para las categorías
import 'package:servicejc/models/product_model.dart'; // Modelo para los productos
import 'package:servicejc/services/api_service.dart';

class ServicioService extends ApiService {
  // Método para obtener la lista de servicios (categorías)
  Future<List<ServiceModel>> fetchServicios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicios'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ServiceModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar los servicios: ${response.statusCode}');
    }
  }

  // Nuevo método para obtener la lista de productos de un servicio específico
  Future<List<ProductModel>> fetchProductos(String servicioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicios/$servicioId/productos'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ProductModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar los productos: ${response.statusCode}');
    }
  }
}