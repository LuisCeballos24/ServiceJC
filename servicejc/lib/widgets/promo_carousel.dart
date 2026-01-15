import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PromoCarousel extends StatelessWidget {
  const PromoCarousel({super.key});

  // Lista de rutas a tus imágenes locales
  final List<String> imgList = const [
    'assets/images/imagen1.png',
    'assets/images/imagen2.png',
    'assets/images/imagen3.png',
    'assets/images/imagen4.png',
    'assets/images/imagen5.png',
    'assets/images/imagen6.png',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: false, // Puedes poner true si quieres que se muevan solas
        enlargeCenterPage: true,
        aspectRatio: 2.0,
        enableInfiniteScroll: true,
      ),
      items: imgList
          .map(
            (item) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  // CAMBIO: Usamos AssetImage en lugar de NetworkImage
                  image: AssetImage(item),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}