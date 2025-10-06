// lib/models/login_response_model.dart

class LoginResponseModel {
  final String token;
  final String? rol;
  final String? userId; // <-- NUEVO CAMPO

  LoginResponseModel({
    required this.token,
    this.rol,
    this.userId, // <-- AGREGAR AL CONSTRUCTOR
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      rol: json['rol'] as String?,
      userId: json['userId'] as String?, // <-- PARSEAR EL NUEVO CAMPO
    );
  }
}
