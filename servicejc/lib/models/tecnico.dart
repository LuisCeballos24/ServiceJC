class Tecnico {
  final String correo;
  final String nombre;
  // Agrega otros campos si los necesitas, como el rol
  final String rol;

  Tecnico({required this.correo, required this.nombre, required this.rol});

  factory Tecnico.fromJson(Map<String, dynamic> json) {
    return Tecnico(
      correo: json['correo'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
    );
  }
}