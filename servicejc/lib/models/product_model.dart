// En lib/models/producto_model.dart

class ProductModel {
  final String id;
  final String nombre;
  final double costo;
  final String servicioId;
  bool isSelected;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.costo,
    required this.servicioId,
    this.isSelected = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nombre: json['nombre'],
      costo: (json['costo'] as num?)?.toDouble() ?? 0.0, // Manejo seguro de valores nulos
      servicioId: json['servicioId'],
    );
  }
}