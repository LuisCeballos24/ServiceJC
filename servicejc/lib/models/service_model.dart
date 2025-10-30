// En lib/models/servicio_model.dart

class ServiceModel {
  final String id;
  final String nombre;

  ServiceModel({required this.id, required this.nombre});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(id: json['id'], nombre: json['nombre']);
  }
}
