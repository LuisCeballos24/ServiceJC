// Este modelo representa una entidad geográfica (Provincia, Distrito o Corregimiento)
// y se utiliza para deserializar los datos JSON provenientes del backend de Java/Spring.
class LocationModel {
  // El ID que se utiliza para filtrar jerárquicamente.
  // Ejemplos: "08" (Provincia), "08-01" (Distrito), "08-01-01" (Corregimiento)
  final String id;

  // Nombre de la ubicación (Ej: "Panamá", "Ancón")
  final String name;

  LocationModel({required this.id, required this.name});

  // Constructor de fábrica para crear una instancia desde JSON.
  // Esto es crucial para que el 'LocationService' de Flutter pueda procesar la respuesta REST.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String? ?? '', // Aseguramos que el ID no sea nulo
      name:
          json['name'] as String? ?? '', // Aseguramos que el nombre no sea nulo
    );
  }

  // Método opcional para convertir el modelo a JSON (útil si se envía de vuelta al backend)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
