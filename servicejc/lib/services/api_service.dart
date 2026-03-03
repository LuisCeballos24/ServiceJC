import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL de producción
  final String _baseUrl = 'https://servicejc-api-469322066501.us-central1.run.app/api';

  String get baseUrl => _baseUrl;

  // 🚀 TRUCO DE VELOCIDAD: Variable estática para guardar los headers en RAM
  // Al ser 'static', se mantiene viva mientras la app esté abierta.
  static Map<String, String>? _memoryHeaders;

  Future<Map<String, String>> getHeaders() async {
    // 1. ⚡ PRIMERO: Preguntamos si ya lo tenemos en memoria
    if (_memoryHeaders != null) {
      // Si ya existe, lo devolvemos INMEDIATAMENTE (0 milisegundos)
      return _memoryHeaders!;
    }

    // 2. 🐌 Si no está en memoria (solo pasa la primera vez), lo buscamos en el disco
    print("🔐 ApiService: Leyendo token del disco (solo primera vez)...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    // 3. Construimos el mapa
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print("   -> Token cargado en memoria ✅");
    } else {
      print("   -> ❌ No hay token");
    }

    // 4. 💾 GUARDAMOS EN MEMORIA para la próxima vez
    _memoryHeaders = headers;

    return headers;
  }

  // ⚠️ IMPORTANTE: Llamar a esto cuando el usuario cierra sesión (Logout)
  // Para que se borre el token de la memoria y no se quede pegado.
  static void clearToken() {
    print("🗑️ ApiService: Limpiando token de memoria");
    _memoryHeaders = null;
  }
}