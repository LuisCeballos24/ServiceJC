class UserAddressModel {
  final String province;
  final String district;
  final String corregimiento;
  final String barrio; // Se enviará como 'callePrincipal'
  final String house;  // Se enviará como 'referencias'
  
  // 1. AGREGAR PROPIEDADES AQUÍ
  final double? latitude;
  final double? longitude;

  UserAddressModel({
    required this.province,
    required this.district,
    required this.corregimiento,
    required this.barrio,
    required this.house,
    // 2. INICIALIZARLAS CON 'this.'
    this.latitude,
    this.longitude,
  });

  // Método toJson corregido para incluir coordenadas
  Map<String, dynamic> toJson() {
    return {
      'provincia': province,
      'distrito': district,
      'corregimiento': corregimiento,
      'callePrincipal': barrio,
      'referencias': house,
      // 3. AGREGAR AL MAPA JSON
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      province: json['provincia'] as String? ?? '',
      district: json['distrito'] as String? ?? '',
      corregimiento: json['corregimiento'] as String? ?? '',
      barrio: json['callePrincipal'] as String? ?? '',
      house: json['referencias'] as String? ?? '',
      // 4. LEER DEL MAPA (Manejo seguro de tipos numéricos)
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}