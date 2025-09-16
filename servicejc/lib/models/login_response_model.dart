// En models/login_response_model.dart

class LoginResponseModel {
  final String token;
  final String userId;
  final String email;

  LoginResponseModel({
    required this.token,
    required this.userId,
    required this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
    );
  }
}