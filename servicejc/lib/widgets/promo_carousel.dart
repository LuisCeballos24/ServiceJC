import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PromoCarousel extends StatelessWidget {
  const PromoCarousel({super.key});

  final List<String> imgList = const [
    'https://picsum.photos/600/250?random=1',
    'https://picsum.photos/600/250?random=2',
    'https://picsum.photos/600/250?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: false, // Se ha deshabilitado la reproducción automática
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
                  image: NetworkImage(item),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
