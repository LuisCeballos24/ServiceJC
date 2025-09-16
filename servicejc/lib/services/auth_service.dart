import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/services/api_service.dart';
import 'package:servicejc/models/login_response_model.dart'; // Importa este nuevo modelo

class AuthService extends ApiService {

  Future<String> registerUser(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: getHeaders(),
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return 'Usuario registrado exitosamente';
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  // Se ha cambiado el tipo de retorno de String a LoginResponseModel
  Future<LoginResponseModel> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: getHeaders(),
      body: jsonEncode({
        'correo': email,
        'contrasena': password,
      }),
    );

    if (response.statusCode == 200) {
      // Analiza la respuesta JSON y la convierte en un objeto LoginResponseModel
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Credenciales incorrectas: ${response.body}');
    }
  }
}