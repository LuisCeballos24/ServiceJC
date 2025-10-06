// en models/login_response_model.dart

class LoginResponseModel {
  final String token;
  final String userId;
  final String email;
  final String? rol; // <-- AGREGAR ESTA LÍNEA

  LoginResponseModel({
    required this.token,
    required this.userId,
    required this.email,
    this.rol, // <-- AGREGAR ESTE PARÁMETRO AL CONSTRUCTOR
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String?, // <-- PARSEAR EL CAMPO 'rol' DEL JSON
    );
  }
}
