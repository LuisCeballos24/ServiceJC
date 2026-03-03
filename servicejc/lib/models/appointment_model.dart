class AppointmentModel {
  final String id;
  final DateTime fechaHora; // 💡 Cambio: DateTime para poder usar DateFormat
  final String estado;      // 💡 Cambio: Renombrado de 'status' a 'estado'
  final String clienteId;
  final String? tecnicoId;
  final String? tecnicoNombre; // 💡 Nuevo: Para mostrar el nombre en el detalle
  final String descripcion;    // 💡 Cambio: No nulo (default '')
  final double costoTotal;     // 💡 Cambio: No nulo (default 0.0)
  
  // 💡 Nuevos campos para UI enriquecida
  final String direccionString; 
  final List<String> serviciosNombres; 

  AppointmentModel({
    required this.id,
    required this.fechaHora,
    required this.estado,
    required this.clienteId,
    this.tecnicoId,
    this.tecnicoNombre,
    this.descripcion = '',
    this.costoTotal = 0.0,
    this.direccionString = '',
    this.serviciosNombres = const [],
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      
      // 1. Convertir String ISO8601 a DateTime
      fechaHora: json['fechaHora'] != null 
          ? DateTime.parse(json['fechaHora']) 
          : DateTime.now(),
      
      // 2. Mapear 'estado' o 'status' para evitar errores
      estado: json['estado'] as String? ?? json['status'] as String? ?? 'pendiente',
      
      clienteId: json['usuarioId'] as String? ?? json['clienteId'] as String? ?? '',
      tecnicoId: json['tecnicoId'] as String?,
      tecnicoNombre: json['tecnicoNombre'] as String?, // El backend debe enviarlo o será null
      
      // 3. Manejo seguro de nulos para descripción
      descripcion: json['descripcion'] as String? ?? '',
      
      // 4. Convertir a double de forma segura
      costoTotal: (json['costoTotal'] as num?)?.toDouble() ?? 0.0,

      // 5. Mapeo de dirección (si el backend envía un objeto complejo, aquí lo simplificamos a String)
      // Si el backend envía "direccion" como objeto, intenta extraer la calle/barrio, sino usa un string vacío.
      direccionString: _parseDireccion(json['direccion']),

      // 6. Lista de servicios (Nombres)
      serviciosNombres: (json['serviciosNombres'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaHora': fechaHora.toIso8601String(), // Convertir de vuelta a String para enviar
      'estado': estado,
      'usuarioId': clienteId,
      'tecnicoId': tecnicoId,
      'descripcion': descripcion,
      'costoTotal': costoTotal,
      // No solemos enviar direccionString ni serviciosNombres al backend en un update simple
    };
  }

  // Helper para extraer una dirección legible si viene un objeto complejo
  static String _parseDireccion(dynamic direccionJson) {
    if (direccionJson == null) return 'Sin dirección registrada';
    if (direccionJson is String) return direccionJson;
    if (direccionJson is Map) {
      // Intenta construir un string legible del objeto UserAddressModel
      String barrio = direccionJson['barrio'] ?? '';
      String casa = direccionJson['house'] ?? '';
      String corregimiento = direccionJson['corregimiento'] ?? '';
      return "$barrio, Casa $casa, $corregimiento";
    }
    return 'Dirección no válida';
  }
}