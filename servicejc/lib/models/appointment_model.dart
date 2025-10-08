// lib/models/appointment_model.dart

class AppointmentModel {
  final String id;
  final String fechaHora;
  final String servicioId;
  final String clienteId;
  final String? tecnicoId;
  final String status;
  final String? descripcion; // <--- Se agregó este campo
  final double? costoTotal; // <--- Se agregó este campo

  AppointmentModel({
    required this.id,
    required this.fechaHora,
    required this.servicioId,
    required this.clienteId,
    this.tecnicoId,
    required this.status,
    this.descripcion, // <--- Se agregó este campo
    this.costoTotal, // <--- Se agregó este campo
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      fechaHora: json['fechaHora'] as String? ?? '',
      servicioId: json['servicioId'] as String? ?? '',
      clienteId: json['clienteId'] as String? ?? '',
      tecnicoId: json['tecnicoId'] as String?,
      status: json['status'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      costoTotal: (json['costoTotal'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaHora': fechaHora,
      'servicioId': servicioId,
      'clienteId': clienteId,
      'tecnicoId': tecnicoId,
      'status': status,
      'descripcion': descripcion,
      'costoTotal': costoTotal,
    };
  }
}
