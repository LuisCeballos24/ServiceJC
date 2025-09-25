import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/services/servicio_service.dart';

// Importa los widgets actualizados y los nuevos
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/contact_info.dart';
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/promotions_section.dart';

class WelcomeClientScreen extends StatefulWidget {
  const WelcomeClientScreen({super.key});

  @override
  State<WelcomeClientScreen> createState() => _WelcomeClientScreenState();
}

class _WelcomeClientScreenState extends State<WelcomeClientScreen> {
  late Future<List<ServiceModel>> _futureServicios;

  // Nuevos colores basados en el logo
  static const Color primaryColor = Color(0xFF1A1A1A); // Un negro profundo
  static const Color secondaryColor = Color(0xFF2C2C2C); // Un gris oscuro para fondos de elementos
  static const Color accentColor = Color(0xFFFFD700); // El color dorado del logo

  @override
  void initState() {
    super.initState();
    _futureServicios = ServicioService().fetchServicios();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      backgroundColor: primaryColor, // Establece el fondo principal
      appBar: AppBar(
        title: AppBarContent(isLargeScreen: isLargeScreen),
        backgroundColor: Colors.transparent, // AppBar transparente sobre el fondo
        elevation: 0,
        toolbarHeight: isLargeScreen ? 140 : 120,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor, // Inicia con el negro del logo
                  secondaryColor, // Transición a gris oscuro
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: isLargeScreen ? 160 : 140,
                    ), // Espacio para el AppBar
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: accentColor, // Texto en dorado
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descubre la mejor solución para tu hogar y oficina.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70, // Texto en blanco suave
                      ),
                    ),
                    const SizedBox(height: 32),
                    const PromotionsSection(), // <--- CORREGIDO: Se añadió 'const'
                    const SizedBox(height: 32),
                    const PromoCarousel(),
                    const SizedBox(height: 32),
                    ServicesGrid(
                      futureServicios: _futureServicios,
                      isLargeScreen: isLargeScreen,
                    ),
                    const SizedBox(height: 32),
                    const TestimonialsSection(),
                    const SizedBox(height: 32),
                    const ContactInfo(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}