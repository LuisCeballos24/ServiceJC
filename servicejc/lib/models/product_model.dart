// En lib/models/product_model.dart

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
      // FIX CLAVE: Asegurar Null Safety para todos los campos requeridos
      id: (json['id'] as String?) ?? 'unknown_prod_id',
      nombre: (json['nombre'] as String?) ?? 'Nombre Desconocido',
      costo: (json['costo'] as num?)?.toDouble() ?? 0.0,
      servicioId: (json['servicioId'] as String?) ?? 'unknown_service_id',
    );
  }
}
