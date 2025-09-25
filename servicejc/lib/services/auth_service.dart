import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/services/api_service.dart';
import 'package:servicejc/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa esta librería

class AuthService extends ApiService {
  
  // Método para registrar un nuevo usuario
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

  // Método para iniciar sesión de un usuario
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
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Credenciales incorrectas: ${response.body}');
    }
  }

  // NUEVO: Método para cerrar la sesión del usuario
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    // Elimina el token de autenticación del almacenamiento local
    await prefs.remove('token');
    // Si tienes otros datos de usuario, como su nombre o ID, también puedes eliminarlos
    // await prefs.remove('userId');
    // await prefs.remove('userName');
  }
}