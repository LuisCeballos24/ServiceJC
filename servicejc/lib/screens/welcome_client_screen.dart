import 'package:flutter/material.dart';
import 'package:servicejc/models/service_model.dart';
import 'package:servicejc/services/servicio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/admin_dashboard_screen.dart';

// Importar la nueva pantalla de 'Mi Cuenta'
import 'package:servicejc/screens/my_account_screen.dart';

// Widgets importados
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/hero_banner.dart';
import 'package:servicejc/widgets/promotions_section.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';

// Estilos centralizados
import '../theme/app_colors.dart';

// 🔹 Define una GlobalKey accesible
final GlobalKey servicesKey = GlobalKey();
final GlobalKey promotionsKey = GlobalKey();

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
  late Future<WelcomeScreenData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _loadAllData();
  }

  Future<WelcomeScreenData> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      });
      return WelcomeScreenData([], true);
    }

    final servicios = await ServicioService().fetchServicios();
    return WelcomeScreenData(servicios, isLoggedIn);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: AppBarContent(isLargeScreen: isLargeScreen),
        toolbarHeight: isLargeScreen ? 100 : 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyAccountScreen(),
                ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<WelcomeScreenData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }

          final servicios = snapshot.data!.servicios;

          return Stack(
            children: [
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
                        HeroBanner(
                          servicesKey: servicesKey,
                          promotionsKey: promotionsKey,
                        ),
                        const SizedBox(height: 32),
                        PromotionsSection(key: promotionsKey),
                        const SizedBox(height: 32),
                        const PromoCarousel(),
                        const SizedBox(height: 32),
                        ServicesGrid(
                          key: servicesKey,
                          futureServicios: Future.value(servicios),
                          isLargeScreen: isLargeScreen,
                        ),
                        const SizedBox(height: 32),
                        const TestimonialsSection(),
                        const SizedBox(height: 32),
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
