// Archivo: lib/models/categoria_principal_model.dart

class CategoriaPrincipalModel {
  // id: Será el identificador como 'MANT_REP', 'REMODEL_CONST', etc.
  final String id; 
  final String nombre;
  // Opcional: Se recomienda añadir un campo para el icono si lo tiene
  // final String iconPath; 

  CategoriaPrincipalModel({required this.id, required this.nombre});

  factory CategoriaPrincipalModel.fromJson(Map<String, dynamic> json) {
    return CategoriaPrincipalModel(
      id: json['id'] as String? ?? '', 
      nombre: json['nombre'] as String? ?? 'Sin Nombre',
      // iconPath: json['iconPath'] as String? ?? '', // Opcional
    );
  }
}