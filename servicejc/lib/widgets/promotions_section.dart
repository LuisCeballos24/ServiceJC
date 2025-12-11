import 'package:flutter/material.dart';

class PromotionsSection extends StatelessWidget {
  const PromotionsSection({super.key});

  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFFFD700);

  final List<Map<String, dynamic>> promotions = const [
    {
      'title': 'Reparación de Electricidad',
      'price': 'desde \$10',
      'icon': Icons.electrical_services_rounded,
    },
    {
      'title': 'Inspección con Dron',
      'price': 'desde \$15',
      'icon': Icons.airplanemode_active_rounded,
    },
    {
      'title': 'Instalaciones Menores',
      'price': 'desde \$20',
      'icon': Icons.build_rounded,
    },
    {
      'title': 'Limpieza de Hogar',
      'price': 'desde \$25',
      'icon': Icons.clean_hands_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Promociones Especiales',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promotions.length,
            itemBuilder: (context, index) {
              final promo = promotions[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(promo['icon'], color: accentColor, size: 50),
                    const SizedBox(height: 12),
                    Text(
                      promo['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      promo['price'],
                      style: const TextStyle(
                        color: accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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