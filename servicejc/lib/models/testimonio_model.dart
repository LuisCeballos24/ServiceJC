class TestimonioModel {
  final String id;
  final String nombreCliente;
  final String comentario;
  final int calificacion;
  final bool destacado;

  TestimonioModel({
    required this.id,
    required this.nombreCliente,
    required this.comentario,
    required this.calificacion,
    required this.destacado,
  });

  factory TestimonioModel.fromJson(Map<String, dynamic> json) {
    return TestimonioModel(
      id: json['id']?.toString() ?? '',
      nombreCliente: json['nombreCliente'] ?? 'Cliente',
      comentario: json['comentario'] ?? '',
      calificacion: json['calificacion'] is int ? json['calificacion'] : 5,
      destacado: json['destacado'] ?? false,
    );
  }
}