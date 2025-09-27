import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatelessWidget {
  final List<String> images = [
    "https://lh3.googleusercontent.com/pw/AP1GczMX-uJoBacGJDRcQNei0Nywj9MlfX-vftkv3ja8qqE5XITBeTfz5MSpHio8scU2WJW8EPplvqSP1NHE1EZ5kkCtgfGVxwD4fvBMaEXe3QS0k9glxXXYZpqChbPyzNXuG1d6QywIBmOcTOnnw3INL_ew5g=w1248-h832-s-no-gm?authuser=0",
    "https://picsum.photos/600/400?random=2",
    "https://picsum.photos/600/400?random=3",
    "https://picsum.photos/600/400?random=4",
  ];

  CustomCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            aspectRatio: 16 / 9,
            scrollDirection: Axis.horizontal,
          ),
          items: images.map((item) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
