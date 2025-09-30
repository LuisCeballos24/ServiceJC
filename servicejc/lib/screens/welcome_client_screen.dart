import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/services/servicio_service.dart';

// Widgets
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/promotions_section.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/contact_info.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';

// Estilos centralizados
import '../theme/app_colors.dart';

class WelcomeClientScreen extends StatefulWidget {
  const WelcomeClientScreen({super.key});

  @override
  State<WelcomeClientScreen> createState() => _WelcomeClientScreenState();
}

class _WelcomeClientScreenState extends State<WelcomeClientScreen> {
  late Future<List<ServiceModel>> _futureServicios;

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
      appBar: AppBar(
        title: AppBarContent(isLargeScreen: isLargeScreen),
        toolbarHeight: isLargeScreen ? 100 : 80,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
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
                    const SizedBox(height: 30), // Espacio para el AppBar
                    Text(
                      '¡Bienvenido!',
                      style: Theme.of(context).textTheme.titleLarge, // 👈 ahora viene del tema
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre la mejor solución para tu hogar y oficina.',
                      style: Theme.of(context).textTheme.bodyMedium, // 👈 también del tema
                    ),
                    const SizedBox(height: 32),
                    const PromotionsSection(),
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
                    const AppFooterBarContent(),
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
