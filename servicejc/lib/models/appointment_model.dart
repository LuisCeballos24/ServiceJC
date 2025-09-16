class AppointmentModel {
  final String? id;
  final String? usuarioId;
  final List<String> serviciosSeleccionados;
  final DateTime? fechaHora;
  final String? estado;

  AppointmentModel({
    this.id,
    this.usuarioId,
    required this.serviciosSeleccionados,
    this.fechaHora,
    this.estado,
  });

  // Constructor para crear un objeto a partir de un mapa JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      usuarioId: json['usuarioId'],
      serviciosSeleccionados: List<String>.from(json['serviciosSeleccionados']),
      fechaHora: json['fechaHora'] != null ? DateTime.parse(json['fechaHora']) : null,
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'serviciosSeleccionados': serviciosSeleccionados,
      'fechaHora': fechaHora?.toIso8601String(),
      'estado': estado,
    };
  }
}