class UserModel {
  final String? id; // Cambiado a nullable
  final String nombre;
  final String correo;
  final String telefono;
  final String? contrasena; // Añadido el campo de contraseña

  UserModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.contrasena, // Añadido al constructor
  });

  // Constructor para crear un objeto a partir de un mapa JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      // No incluimos la contraseña aquí por seguridad
    );
  }

  // Método para convertir un objeto a un mapa JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
    };
    // Añade la contraseña solo si está presente
    if (contrasena != null) {
      data['contrasena'] = contrasena;
    }
    return data;
  }
}