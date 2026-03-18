import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 👈 IMPORTANTE
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/screens/servicios_screen.dart';
import '../theme/app_colors.dart';

class PromoCarousel extends StatelessWidget {
  final List<CategoriaPrincipalModel> servicios;

  const PromoCarousel({super.key, required this.servicios});

  @override
  Widget build(BuildContext context) {
    // Tomamos los primeros 6 servicios para mostrar en el carrusel
    final carouselItems = servicios.take(6).toList();

    if (carouselItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        aspectRatio: 2.0,
        viewportFraction: 0.85,
        enableInfiniteScroll: true,
      ),
      items: carouselItems.map((servicio) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiciosScreen(categoria: servicio),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🔥 IMAGEN DESDE FIREBASE
                  if (servicio.imageUrl != null && servicio.imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: servicio.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.secondary),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.secondary,
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    )
                  else
                    Container(color: AppColors.secondary), // Fondo por defecto

                  // DEGRADADO OSCURO PARA QUE SE LEA EL TEXTO
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),

                  // TEXTO
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      servicio.nombre,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [
                          Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black)
                        ]
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}