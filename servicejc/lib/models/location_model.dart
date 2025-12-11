class LocationModel {
  final String id;
  final String name;
  final String type;
  final String? provinceId; // <--- Cambiar a String? (Nullable)
  final String? districtId; // <--- Cambiar a String? (Nullable)

  LocationModel({
    required this.id,
    required this.name,
    required this.type,
    this.provinceId,
    this.districtId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      provinceId: json['provinceId'], // Ahora acepta null sin error
      districtId: json['districtId'], // Ahora acepta null sin error
    );
  }
  
  // Para que el Dropdown compare correctamente los objetos
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}