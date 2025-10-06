// lib/models/appointment_model.dart

class AppointmentModel {
  final String id;
  final String fechaHora;
  final String servicioId;
  final String clienteId;
  final String? tecnicoId;
  final String status;

  AppointmentModel({
    required this.id,
    required this.fechaHora,
    required this.servicioId,
    required this.clienteId,
    this.tecnicoId,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      fechaHora: json['fechaHora'] as String,
      servicioId: json['servicioId'] as String,
      clienteId: json['clienteId'] as String,
      tecnicoId: json['tecnicoId'] as String?,
      status: json['status'] as String,
    );
  }

  // <--- AÑADIR ESTE MÉTODO
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaHora': fechaHora,
      'servicioId': servicioId,
      'clienteId': clienteId,
      'tecnicoId': tecnicoId,
      'status': status,
    };
  }
}
