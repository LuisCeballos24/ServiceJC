// Este modelo se utiliza para encapsular la información de la dirección de un usuario
// antes de enviarla al backend (Spring Boot) para su almacenamiento en la base de datos.
class UserAddressModel {
  final String province;
  final String district;
  final String corregimiento;
  final String barrio; // Calle, PH, Edificio (Ahora será callePrincipal)
  final String house; // Número de casa o apartamento (Ahora será referencias)

  UserAddressModel({
    required this.province,
    required this.district,
    required this.corregimiento,
    required this.barrio,
    required this.house,
  });

  // Método para convertir el objeto de Dart a un Map.
  // CRÍTICO: Las claves se han ajustado para que coincidan EXACAMENTE con el modelo de Java
  // (provincia, distrito, callePrincipal, referencias).
  Map<String, dynamic> toJson() {
    return {
      'provincia': province,
      'distrito': district,
      'corregimiento': corregimiento,
      'callePrincipal':
          barrio, // Mapea 'barrio' (Dart) a 'callePrincipal' (Java/Firestore)
      'referencias':
          house, // Mapea 'house' (Dart) a 'referencias' (Java/Firestore)
    };
  }

  // Opcional: Constructor de fábrica para crear desde JSON si fuera necesario
  // recuperar la dirección desde el backend.
  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      // Usamos las claves en español para leer desde el JSON del backend
      province: json['provincia'] as String? ?? '',
      district: json['distrito'] as String? ?? '',
      corregimiento: json['corregimiento'] as String? ?? '',
      barrio:
          json['callePrincipal'] as String? ?? '', // Leer de 'callePrincipal'
      house: json['referencias'] as String? ?? '', // Leer de 'referencias'
    );
  }
}
