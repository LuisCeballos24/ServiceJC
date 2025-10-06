// lib/models/cita_model.dart
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/models/location_model.dart';

class CitaModel {
  final String id;
  final String userId;
  final String tecnicoId;
  final DateTime fecha;
  final String hora;
  final String status;
  final double costoTotal;
  final String descripcion;
  final UserModel? cliente;
  final Map<ProductModel, int>? productos;

  CitaModel({
    required this.id,
    required this.userId,
    required this.tecnicoId,
    required this.fecha,
    required this.hora,
    required this.status,
    required this.costoTotal,
    required this.descripcion,
    this.cliente,
    this.productos,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'],
      userId: json['userId'],
      tecnicoId: json['tecnicoId'],
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'],
      status: json['status'],
      costoTotal: json['costoTotal'],
      descripcion: json['descripcion'],
      // ... (lógica para parsear cliente, productos, etc.)
    );
  }
}
