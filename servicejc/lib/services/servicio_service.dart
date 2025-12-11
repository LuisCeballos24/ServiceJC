import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:servicejc/models/service_model.dart'; // Modelo para los servicios (sub-categorías)
import 'package:servicejc/models/product_model.dart'; // Modelo para los productos
import 'package:servicejc/models/categoria_principal_model.dart'; // 💡 NUEVO MODELO para la Pantalla Principal
import 'package:servicejc/services/api_service.dart';

class ServicioService extends ApiService {
  
  // ----------------------------------------------------
  // 💡 NIVEL 1: Obtener las Categorías Principales (Nueva Pantalla Principal)
  // ----------------------------------------------------
  Future<List<CategoriaPrincipalModel>> fetchCategoriasPrincipales() async {
    // Asume que el endpoint es /categorias_principales
    final response = await http.get(
      Uri.parse('$baseUrl/categorias_principales'), 
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => CategoriaPrincipalModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar las categorías principales: ${response.statusCode}');
    }
  }

  // ----------------------------------------------------
  // 💡 NIVEL 2: Obtener Servicios filtrados (Nueva Pantalla Secundaria)
  // ESTE MÉTODO RESUELVE EL ERROR 'undefined_method'
  // ----------------------------------------------------
  Future<List<ServiceModel>> fetchServiciosByCategoriaId(String categoriaPrincipalId) async {
    // Llama al endpoint que su backend usa para filtrar servicios por el ID de la Categoría Principal
    // Ejemplo de endpoint: /servicios?categoriaPrincipalId=MANT_REP
    final response = await http.get(
      Uri.parse('$baseUrl/servicios?categoriaPrincipalId=$categoriaPrincipalId'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ServiceModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar los sub-servicios: ${response.statusCode}');
    }
  }
  
  // ----------------------------------------------------
  // Nivel 3: Obtener los Productos (Actividades/Inspección)
  // ----------------------------------------------------
  // Método para obtener la lista de productos de un servicio específico
  Future<List<ProductModel>> fetchProductos(String servicioId) async {
    // Mantenemos la estructura de su endpoint original: /servicios/{id}/productos
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

  // Mantenemos el método antiguo por si aún es referenciado en la app
  Future<List<ServiceModel>> fetchServicios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/servicios'),
      headers: getHeaders(),
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ServiceModel.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar los servicios (antiguo): ${response.statusCode}');
    }
  }
}