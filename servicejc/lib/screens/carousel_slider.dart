import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel({super.key});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  final List<String> images = [
    "https://picsum.photos/600/400?random=2",
    "https://picsum.photos/600/400?random=3",
    "https://picsum.photos/600/400?random=4",
  ];

  @override
  void dispose() {
    // Detener el autoplay antes de dispose para evitar errores
    _controller.stopAutoPlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: images.length,
          itemBuilder: (context, index, _) => ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(images[index], fit: BoxFit.cover),
          ),
          options: CarouselOptions(
            height: 200,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() => _current = index);
              }
            },
          ),
        ),
        const SizedBox(height: 10),
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
                color: _current == index
                    ? Colors.blueAccent
                    : Colors.blue.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
