import 'package:flutter/material.dart';
import 'package:servicejc/theme/app_colors.dart';

class HeroBanner extends StatelessWidget {
  final GlobalKey servicesKey;
  final GlobalKey promotionsKey;

  const HeroBanner({
    super.key,
    required this.servicesKey,
    required this.promotionsKey,
  });

  // 🔹 Desplaza suavemente hasta la sección de servicios
  void scrollToServices() {
    final context = servicesKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  // 🔹 Desplaza suavemente hasta la sección de promociones
  void scrollToPromotions() {
    final context = promotionsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height * 0.9,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/banner-bg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Descubre la mejor solución para tu hogar y oficina",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width < 600 ? 26 : 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Expertos en todas las áreas. ¡Haz que tu espacio funcione como siempre soñaste!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width < 600 ? 16 : 20,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    // 🔹 Botón que baja a Promociones
                    OutlinedButton(
                      onPressed: scrollToPromotions,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ver Promociones",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 🔹 Botón que baja a Servicios
                    OutlinedButton(
                      onPressed: scrollToServices,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ver Servicios",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
