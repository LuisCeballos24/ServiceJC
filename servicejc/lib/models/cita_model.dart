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

  // CORRECCIÓN CLAVE 1: Ahora es List<String> para enviar IDs al backend
  final List<String>? serviciosSeleccionados;

  // Este campo es para recibir datos enriquecidos (lectura)
  final List<ProductModel>? productosSeleccionados;

  // CORRECCIÓN CLAVE 2: Nuevo campo para el URL de la imagen
  final String? imageUrl;

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
    this.productosSeleccionados,
    // CORRECCIÓN CLAVE 1: Aceptar List<String>
    this.serviciosSeleccionados,
    // CORRECCIÓN CLAVE 2: Añadido al constructor
    this.imageUrl,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    final String safeId = (json['id'] as String?) ?? 'unknown_id';
    final String safeUserId = (json['usuarioId'] as String?) ?? 'unknown_user';
    final String safeStatus = ((json['estado'] as String?) ?? 'PENDIENTE')
        .toUpperCase();
    final String safeDescripcion = (json['descripcion'] as String?) ?? '';

    // NUEVO: Para recibir el URL de la imagen del backend
    final String? safeImageUrl = json['imageUrl'] as String?;

    final List<ProductModel> safeProductosSeleccionados =
        (json['productosSeleccionados'] as List<dynamic>?)
            ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    // Manejar la lista de IDs de servicios al leer
    final List<String>? safeServiciosSeleccionados =
        (json['serviciosSeleccionados'] as List<dynamic>?)
            ?.map((item) => item.toString()) // Asegura que sean Strings
            .toList();

    final double safeCostoTotal =
        (json['costoTotal'] as num?)?.toDouble() ?? 0.0;

    DateTime safeFecha = DateTime.now();
    String safeHora = '00:00';

    try {
      final fechaHoraStr = json['fechaHora'] as String?;
      if (fechaHoraStr != null) {
        safeFecha = DateTime.parse(fechaHoraStr);
        safeHora = DateFormat('HH:mm').format(safeFecha);
      }
    } catch (_) {
      print('Warning: Failed to parse fechaHora. Using current time.');
    }

    return CitaModel(
      id: safeId,
      userId: safeUserId,
      tecnicoId: json['tecnicoId'] as String?,
      fecha: safeFecha,
      hora: safeHora,
      status: safeStatus,
      costoTotal: safeCostoTotal,
      descripcion: safeDescripcion,
      productosSeleccionados: safeProductosSeleccionados,
      // Asigna la lista de IDs de String
      serviciosSeleccionados: safeServiciosSeleccionados,
      // Asigna el URL de la imagen
      imageUrl: safeImageUrl,
    );
  }

  // El método toJson() es lo que el cliente envía al backend
  Map<String, dynamic> toJson() {
    final String fechaPart = DateFormat("yyyy-MM-dd").format(fecha);
    final String fechaHoraStr = '${fechaPart}T$hora:00.000';

    return {
      'id': id,
      'usuarioId': userId,
      'tecnicoId': tecnicoId,
      'estado': status,
      'fechaHora': fechaHoraStr,
      'costoTotal': costoTotal,
      'descripcion': descripcion,
      // Se envía List<String> si está disponible (IDs)
      'serviciosSeleccionados': serviciosSeleccionados,
      // Se envía el imageUrl (será null al crear la cita, ya que el backend lo manejará)
      'imageUrl': imageUrl,
    };
  }
}
