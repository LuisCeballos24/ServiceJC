import 'user_address_model.dart';

class UserModel {
  final String? id; 
  final String nombre;
  final String correo;
  final String telefono;
  final String? contrasena; 
  final UserAddressModel? direccion; 
  final String? rol; 

  // 👇 NUEVOS CAMPOS
  final bool isPremium;
  final double walletBalance;
  final String? codigoReferido;

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.contrasena, 
    this.direccion, 
    this.rol, 
    // Inicializamos con valores por defecto seguros
    this.isPremium = false,
    this.walletBalance = 0.0,
    this.codigoReferido,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final addressJson = json['direccion'] as Map<String, dynamic>?;
    final UserAddressModel? address = addressJson != null
        ? UserAddressModel.fromJson(addressJson)
        : null;

    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      direccion: address,
      rol: json['rol'], 
      // 👇 LEEMOS LOS NUEVOS DATOS DESDE JSON
      isPremium: json['isPremium'] ?? false,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      codigoReferido: json['codigoReferido'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      // 👇 ENVIAMOS LOS DATOS SI EXISTEN
      'isPremium': isPremium,
      'walletBalance': walletBalance,
    };

    if (contrasena != null) data['contrasena'] = contrasena;
    if (direccion != null) data['direccion'] = direccion!.toJson();
    if (rol != null) data['rol'] = rol;
    if (codigoReferido != null) data['codigoReferido'] = codigoReferido;

    return data;
  }
}