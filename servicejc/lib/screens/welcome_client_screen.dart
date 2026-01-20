import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
// Importamos ServiceModel si lo necesitas, pero aquí nos basamos en CategoriaPrincipalModel
import 'package:servicejc/services/servicio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pantallas
import 'package:servicejc/screens/my_account_screen.dart';
import 'package:servicejc/screens/servicios_screen.dart'; // Ahora esta pantalla muestra los PRODUCTOS

// Widgets
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/hero_banner.dart';
import 'package:servicejc/widgets/promotions_section.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';

// Estilos
import '../theme/app_colors.dart';

final GlobalKey servicesKey = GlobalKey();
final GlobalKey promotionsKey = GlobalKey();

class WelcomeScreenData {
  // Seguimos usando este modelo porque el backend lo devuelve mapeado así
  final List<CategoriaPrincipalModel> categorias; 
  final bool isLoggedIn;
  WelcomeScreenData(this.categorias, this.isLoggedIn);
}

class WelcomeClientScreen extends StatefulWidget {
  const WelcomeClientScreen({super.key});

  @override
  State<WelcomeClientScreen> createState() => _WelcomeClientScreenState();
}

class _WelcomeClientScreenState extends State<WelcomeClientScreen> {
  late Future<WelcomeScreenData> _futureData;
  final ServicioService _servicioService = ServicioService();

  @override
  void initState() {
    super.initState();
    _futureData = _loadAllData();
  }

  Future<WelcomeScreenData> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final isLoggedIn = token != null && token.isNotEmpty;
    
    // Llamada al backend (que ahora devuelve Servicios camuflados como Categorías)
    final categorias = await _servicioService.fetchCategoriasPrincipales(); 
    
    return WelcomeScreenData(categorias, isLoggedIn);
  }
  
  // 💡 CAMBIO CLAVE EN NAVEGACIÓN
  // Al tocar un ítem del Home, vamos directo a ver sus PRODUCTOS
  void _navigateToServicios(CategoriaPrincipalModel itemSeleccionado) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // 'ServiciosScreen' ahora recibe este ítem como si fuera una "Categoría"
        // Asegúrate de que ServiciosScreen use itemSeleccionado.id para buscar productos
        builder: (context) => ServiciosScreen(categoria: itemSeleccionado),
      ),
    );
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
            icon: const Icon(Icons.person, color: AppColors.white),
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
          
          if (snapshot.data == null || snapshot.data!.categorias.isEmpty) {
             return const Center(child: Text('No se encontraron servicios disponibles.'));
          }

          final categorias = snapshot.data!.categorias;

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
                        
                        // GRID DE SERVICIOS
                        ServicesGrid( 
                          key: servicesKey,
                          items: categorias, 
                          onItemSelected: _navigateToServicios, 
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