// lib/models/cita_model.dart
import 'package:servicejc/models/product_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:intl/intl.dart';

class CitaModel {
  final String id;
  final String userId;
  final String? tecnicoId;
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
    this.tecnicoId,
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
  Map<String, dynamic> toJson() {
    // 1. Combinar fecha y hora en formato ISO 8601 para que Java (Date) lo entienda:
    // Formato requerido: "yyyy-MM-ddTHH:mm:ss.sss" (Ej: 2025-10-24T10:00:00.000)
    final String fechaPart = DateFormat("yyyy-MM-dd").format(fecha);
    final String fechaHoraStr =
        '${fechaPart}T$hora:00.000'; // hora ya incluye minutos (HH:mm)

    return {
      'id': id,
      'usuarioId': userId, // Usamos 'usuarioId' que es el campo en Java
      'tecnicoId': tecnicoId,
      'estado': status, // Mapeo de 'status' (Dart) a 'estado' (Java/JSON)

      'fechaHora': fechaHoraStr, // Fecha y hora combinadas
      // Campos que deben enviarse para evitar que el backend los borre o de error:
      'costoTotal': costoTotal,
      'descripcion': descripcion,
      // Si el modelo Java Cita tiene 'productos', estos deben serializarse aquí.
      // Si 'productos' no se está modificando, confiamos en que el backend lo mantendrá.
    };
  }
}
