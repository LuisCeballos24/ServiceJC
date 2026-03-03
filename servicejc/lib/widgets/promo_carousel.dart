import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/screens/servicios_screen.dart'; 

class PromoCarousel extends StatelessWidget {
  // ✅ Aceptamos la lista de servicios desde el padre
  final List<CategoriaPrincipalModel> servicios;

  const PromoCarousel({super.key, required this.servicios});

  // Lógica para asignar imágenes según el nombre del servicio
  String _getImagePath(CategoriaPrincipalModel categoria) {
    final String data = "${categoria.id} ${categoria.nombre}".toLowerCase();

    // BLOQUE DE MAPEO DE IMÁGENES
    if (data.contains('decor')) {
      return 'assets/images/services/decoracion.png';
    } else if (data.contains('eban') || data.contains('mader')) {
      return 'assets/images/services/ebanistas.png';
    } else if (data.contains('panel') || data.contains('solar')) {
      return 'assets/images/services/paneles.png';
    } else if (data.contains('ventan') || data.contains('vidrio')) {
      return 'assets/images/services/ventanas.png';
    } else if (data.contains('aire') || data.contains('acond')) {
      return 'assets/images/services/aire_acondicionado.png';
    } else if (data.contains('elect')) {
      return 'assets/images/services/electricidad.png';
    } else if (data.contains('limp')) {
      return 'assets/images/services/limpieza_general.png';
    } else if (data.contains('plom') || data.contains('agua')) {
      return 'assets/images/services/plomeria.png';
    } else if (data.contains('remodel')) {
      return 'assets/images/services/remodelaciones.png';
    } else if (data.contains('const')) {
      return 'assets/images/services/construccion.png';
    } else if (data.contains('pint')) {
      return 'assets/images/services/pintura.png';
    } else if (data.contains('tech')) {
      return 'assets/images/services/techos.png';
    } else if (data.contains('cielo')) {
      return 'assets/images/services/cieloraso.png';
    } else if (data.contains('sold')) {
      return 'assets/images/services/soldadura.png';
    } else if (data.contains('dron')) {
      return 'assets/images/services/dron.png';
    } else if (data.contains('mudan')) {
      return 'assets/images/services/mudanza.png';
    } else if (data.contains('insta') || data.contains('menor')) {
      return 'assets/images/services/instalaciones_menores.png';
    } else if (data.contains('bar') || data.contains('bebida')) {
      return 'assets/images/services/bartender.png';
    } else if (data.contains('chef') || data.contains('cocin')) {
      return 'assets/images/services/chef.png';
    } else if (data.contains('valet')) {
      return 'assets/images/services/valet.png';
    }

    // Imagen por defecto si no encuentra coincidencia
    return 'assets/images/services/mantenimiento.png';
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos los primeros 6 servicios para mostrar en el carrusel
    final carouselItems = servicios.take(6).toList();

    // Si no hay datos, no mostramos nada para evitar errores
    if (carouselItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true, // Movimiento automático activado
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        aspectRatio: 2.0,
        viewportFraction: 0.85,
        enableInfiniteScroll: true,
      ),
      items: carouselItems.map((servicio) {
        final imagePath = _getImagePath(servicio);
        
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                   // Evita que la app truene si falta una imagen
                   print("Error cargando imagen carrusel: $imagePath");
                },
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.6, 1.0],
                ),
              ),
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
          ),
        );
      }).toList(),
    );
  }
}