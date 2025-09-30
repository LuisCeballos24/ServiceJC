import 'user_address_model.dart'; // Importar el nuevo modelo de dirección

class UserModel {
  final String? id; // Cambiado a nullable
  final String nombre;
  final String correo;
  final String telefono;
  final String? contrasena; // Añadido el campo de contraseña
  final UserAddressModel? direccion; // Nuevo: Información de dirección
  final String?
  rol; // NUEVO: Tipo de rol que se asigna desde el Front (ej. "USUARIO", "ADMIN")

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.contrasena, // Añadido al constructor
    this.direccion, // Nuevo: Dirección
    this.rol, // NUEVO: Rol añadido al constructor
  });

  // Constructor para crear un objeto a partir de un mapa JSON (usado típicamente en login/perfil)
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
      // No incluimos la contraseña aquí por seguridad
      direccion: address,
      rol: json['rol'], // NUEVO: Parsear el rol
    );
  }

  // Método para convertir un objeto a un mapa JSON (usado típicamente en registro)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Campos básicos
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
    };

    // Añade la contraseña solo si está presente (necesario solo para el registro)
    if (contrasena != null) {
      data['contrasena'] = contrasena;
    }

    // Añadir el objeto de dirección serializado
    if (direccion != null) {
      data['direccion'] = direccion!.toJson();
    }

    // SOLUCIÓN: Añadir el rol si está presente
    if (rol != null) {
      data['rol'] = rol;
    }

    return data;
  }
}
