import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/services/servicio_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Necesario para la persistencia
import 'package:servicejc/screens/admin_dashboard_screen.dart'; // Necesario para la redirección

// Widgets importados
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/promotions_section.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/contact_info.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';

// Estilos centralizados
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Definimos un tipo para manejar los futuros en paralelo
class WelcomeScreenData {
  final List<ServiceModel> servicios;
  final bool isLoggedIn;
  WelcomeScreenData(this.servicios, this.isLoggedIn);
}

class WelcomeClientScreen extends StatefulWidget {
  const WelcomeClientScreen({super.key});

  @override
  State<WelcomeClientScreen> createState() => _WelcomeClientScreenState();
}

class _WelcomeClientScreenState extends State<WelcomeClientScreen> {
  // Combinamos la carga de servicios y la verificación de sesión en un solo Future
  late Future<WelcomeScreenData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadAllData();
  }

  Future<WelcomeScreenData> _loadAllData() async {
    // 1. Verificar el estado de la sesión
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final isLoggedIn = token != null && token.isNotEmpty;

    // Si está logueado, redirigimos inmediatamente (antes de cargar servicios)
    if (isLoggedIn) {
      // Usamos addPostFrameCallback para asegurar que la navegación ocurra
      // después de que el widget se haya construido por completo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      });
      // Devolvemos datos ficticios o una lista vacía para no bloquear el Future
      return WelcomeScreenData([], true);
    }

    // 2. Si NO está logueado, procedemos a cargar los servicios
    final servicios = await ServicioService().fetchServicios();
    return WelcomeScreenData(servicios, false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        // NOTA: El AppBarContent ahora debe manejar la actualización de su estado
        // cuando un usuario inicia/cierra sesión.
        title: AppBarContent(isLargeScreen: isLargeScreen),
        toolbarHeight: isLargeScreen ? 100 : 80,
        backgroundColor:
            Colors.transparent, // Fondo transparente para ver el Stack
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<WelcomeScreenData>(
        future: _futureData,
        builder: (context, snapshot) {
          // Si el Future sigue cargando, o si ya redirigimos (isLoggedIn = true)
          // mostramos un indicador de carga para evitar un flash.
          if (snapshot.connectionState == ConnectionState.waiting ||
              (snapshot.hasData && snapshot.data!.isLoggedIn)) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }

          // Manejo de errores
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }

          // Si el Future tiene datos y no hubo redirección, mostramos el contenido
          final servicios = snapshot.data!.servicios;

          return Stack(
            children: [
              // Fondo degradado
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
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
                        const SizedBox(
                          height: 30,
                        ), // Espacio adicional debajo del AppBar transparente
                        Text(
                          '¡Bienvenido!',
                          style: AppTextStyles.heroTitle.copyWith(
                            color: Colors.white,
                          ), // Usamos heroTitle del Canvas
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Descubre la mejor solución para tu hogar y oficina.',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white70,
                          ), // Usamos body del Canvas
                        ),
                        const SizedBox(height: 32),
                        const PromotionsSection(),
                        const SizedBox(height: 32),
                        const PromoCarousel(),
                        const SizedBox(height: 32),
                        ServicesGrid(
                          futureServicios: Future.value(
                            servicios,
                          ), // Pasamos la lista ya cargada
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
          );
        },
      ),
    );
  }
}
