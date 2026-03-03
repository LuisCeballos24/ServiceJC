import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/services/api_service.dart';
import 'package:servicejc/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ApiService {
  
  // ---------------------------------------------------------------------------
  // REGISTRO (🔴 AQUÍ ESTABA EL ERROR)
  // ---------------------------------------------------------------------------
  Future<String> registerUser(UserModel user) async {
    
    // ✅ CORRECCIÓN: Esperamos a obtener los headers antes de usarlos
    final headers = await getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers, // Ahora pasamos el Map ya listo
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return 'Usuario registrado exitosamente';
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN (Este ya estaba bien, lo dejamos igual)
  // ---------------------------------------------------------------------------
  Future<LoginResponseModel> loginUser(String email, String password) async {
    print("🔵 AuthService: Intentando login con $email");

    // Aquí usamos un Map manual, así que NO necesitamos await ni getHeaders()
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: { 'Content-Type': 'application/json' }, 
      body: jsonEncode({'correo': email, 'contrasena': password}),
    );

    print("🔵 AuthService Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Credenciales incorrectas: ${response.body}');
    }
  }

  // ---------------------------------------------------------------------------
  // CERRAR SESIÓN
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
    await prefs.remove('userId');
  }
}