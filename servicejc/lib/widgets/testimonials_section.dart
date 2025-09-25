import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  // Colores basados en el logo
  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFFFD700);

  final List<Map<String, String>> testimonials = const [
    {
      'name': 'Ana García',
      'review': '¡Excelente servicio! Rápido, profesional y a un precio justo. Los recomiendo sin dudarlo.',
    },
    {
      'name': 'Carlos Pérez',
      'review': 'El técnico fue muy amable y resolvió mi problema de plomería en menos de una hora. ¡Muy satisfecho!',
    },
    {
      'name': 'María Rodríguez',
      'review': 'Contraté el servicio de pintura y el resultado superó mis expectativas. Mi casa luce fantástica.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: const Text(
            'Lo que nuestros clientes dicen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200, // Altura ajustada para el nuevo diseño
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final testimonial = testimonials[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: accentColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return const Icon(Icons.star, color: accentColor, size: 20);
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${testimonial['review']}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '- ${testimonial['name']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}