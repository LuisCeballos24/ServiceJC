class LoginResponseModel {
  final String token;
  final String? rol;
  final String? userId;

  LoginResponseModel({
    required this.token,
    this.rol,
    this.userId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    print("📦 Parseando JSON en Modelo: $json"); // Debug para ver qué llega

    // 🛡️ SOLUCIÓN: Buscamos 'accessToken' PRIMERO. Si no está, buscamos 'token'.
    // Si ninguno está, devolvemos cadena vacía (para evitar crash, aunque el login fallará luego).
    String extractedToken = json['accessToken'] ?? json['token'] ?? '';

    // 🛡️ SOLUCIÓN ID: Buscamos 'id', 'userId' o 'usuarioId'
    String? extractedId = json['id'] ?? json['userId'] ?? json['usuarioId'];

    // 🛡️ SOLUCIÓN ROL: Buscamos 'rol' o 'role'
    String? extractedRol = json['rol'] ?? json['role'];

    return LoginResponseModel(
      token: extractedToken,
      rol: extractedRol,
      userId: extractedId,
    );
  }
}