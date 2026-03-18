class CategoriaPrincipalModel {
  final String id; 
  final String nombre;
  final String? imageUrl; // 👇 NUEVO CAMPO

  CategoriaPrincipalModel({
    required this.id, 
    required this.nombre,
    this.imageUrl,
  });

  factory CategoriaPrincipalModel.fromJson(Map<String, dynamic> json) {
    return CategoriaPrincipalModel(
      id: json['id'] as String? ?? '', 
      nombre: json['nombre'] as String? ?? 'Sin Nombre',
      imageUrl: json['imageUrl'] as String?, // Mapeo seguro
    );
  }
}