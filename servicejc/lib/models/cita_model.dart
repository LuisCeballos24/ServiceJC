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
  final String descripcion; // Sigue siendo requerido en el constructor
  final UserModel? cliente;
  final Map<ProductModel, int>? productos;
  final List<ProductModel>? serviciosSeleccionados;
  final List<ProductModel>? productosSeleccionados; // <--- NUEVO CAMPO LISTA

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
    this.serviciosSeleccionados, // Añadir a constructor
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    // 1. Manejo seguro para String (incluye corrección de clav  es)
    final String safeId = (json['id'] as String?) ?? 'unknown_id';
    // Backend usa 'usuarioId', Dart usa 'userId'
    final String safeUserId = (json['usuarioId'] as String?) ?? 'unknown_user';
    // Backend usa 'estado', Dart usa 'status'
    final String safeStatus = ((json['estado'] as String?) ?? 'PENDIENTE')
        .toUpperCase();
    // FIX CLAVE: Si la descripción es null (como en tu backend), usa ''
    final String safeDescripcion = (json['descripcion'] as String?) ?? '';

    final List<ProductModel> safeProductosSeleccionados =
        (json['productosSeleccionados'] as List<dynamic>?)
            ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    // 2. Parseo seguro para double: usa el valor o 0.0
    // 2. Manejo seguro para double
    final double safeCostoTotal =
        (json['costoTotal'] as num?)?.toDouble() ?? 0.0;

    // 3. Parseo seguro para DateTime
    // 3. FIX CLAVE: Manejo de fechaHora (tu backend no envía 'fecha' y 'hora' separadas)
    DateTime safeFecha = DateTime.now();
    String safeHora = '00:00';

    try {
      final fechaHoraStr = json['fechaHora'] as String?;
      if (fechaHoraStr != null) {
        safeFecha = DateTime.parse(fechaHoraStr);
        // Extraer solo la hora (HH:mm) del objeto DateTime
        safeHora = DateFormat('HH:mm').format(safeFecha);
      }
    } catch (_) {
      // Fallback si el string es inválido, mantiene los valores por defecto
      print('Warning: Failed to parse fechaHora. Using current time.');
    }

    return CitaModel(
      id: safeId,
      userId: safeUserId,
      tecnicoId: json['tecnicoId'] as String?, // Nullable, no necesita ??
      fecha: safeFecha,
      hora: safeHora,
      status: safeStatus,
      costoTotal: safeCostoTotal,
      descripcion: safeDescripcion,
      productosSeleccionados:
          safeProductosSeleccionados, // Asignar la lista enriquecida // Usar el valor seguro
      // ... (lógica para parsear cliente, productos, etc.)
    );
  }

  // El método toJson() se mantiene igual
  Map<String, dynamic> toJson() {
    // 1. Combinar fecha y hora en formato ISO 8601 para que Java (Date) lo entienda:
    // Formato requerido: "yyyy-MM-ddTHH:mm:ss.sss" (Ej: 2025-10-24T10:00:00.000)
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
      'serviciosSeleccionados': serviciosSeleccionados, // Solo IDs
      // NO incluir productosSeleccionados en toJson()
    };
  }
}
