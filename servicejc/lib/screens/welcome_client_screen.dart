import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/services/servicio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pantallas
import 'package:servicejc/screens/my_account_screen.dart';
import 'package:servicejc/screens/servicios_screen.dart'; 
import 'package:servicejc/screens/login_screen.dart'; // ⚠️ Asegúrate de importar tu pantalla de Login

// Widgets
import 'package:servicejc/widgets/app_bar_content.dart';
import 'package:servicejc/widgets/hero_banner.dart';
import 'package:servicejc/widgets/promotions_section.dart';
import 'package:servicejc/widgets/promo_carousel.dart';
import 'package:servicejc/widgets/services_grid.dart';
import 'package:servicejc/widgets/testimonials_section.dart';
import 'package:servicejc/widgets/app_footer_bar_content.dart';
import 'package:servicejc/widgets/vip_promo_card.dart';

// Estilos
import '../theme/app_colors.dart';

// ✅ CLASE DE DATOS
class WelcomeScreenData {
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
  
  final GlobalKey servicesKey = GlobalKey();
  final GlobalKey promotionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // 🔥 Carga los datos sin importar si hay login o no
    _futureData = _loadAllData();
  }

  Future<WelcomeScreenData> _loadAllData() async {
    // 1. Verificamos el token silenciosamente
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    // Si hay token, es true. Si es null, es false.
    final isLoggedIn = token != null && token.isNotEmpty;
    
    // 2. Descargamos Servicios (El backend debe permitir esto sin token)
    final categorias = await _servicioService.fetchCategoriasPrincipales(); 
    
    return WelcomeScreenData(categorias, isLoggedIn);
  }
  
  // Lógica inteligente para el botón de perfil
  void _handleProfileClick() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // ✅ Si TIENE token, va a Mi Cuenta
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyAccountScreen()),
      );
    } else {
      // 👤 Si NO tiene token, lo mandamos al Login
      print("Usuario invitado: Redirigiendo a Login...");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Asegúrate que LoginScreen existe
      );
    }
  }

  void _navigateToServicios(CategoriaPrincipalModel itemSeleccionado) {
    Navigator.push(
      context,
      MaterialPageRoute(
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
          // 👇 BOTÓN INTELIGENTE DE PERFIL
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.white),
            onPressed: _handleProfileClick, // Usamos la nueva función
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
              child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            );
          }

          if (snapshot.hasError) {
            // Manejo elegante de errores (por si el backend falla)
            return Container(
               color: AppColors.primary,
               child: Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.error_outline, color: Colors.white, size: 48),
                     const SizedBox(height: 10),
                     Text('Error de conexión: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
                     ElevatedButton(onPressed: () => setState(() => _futureData = _loadAllData()), child: const Text("Reintentar"))
                   ],
                 ),
               ),
            );
          }
          
          // Si carga vacío (raro, pero posible)
          if (snapshot.data == null || snapshot.data!.categorias.isEmpty) {
             return const Center(child: Text('No hay servicios disponibles.'));
          }

          // ✅ DATOS LISTOS
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
                      children: [
                        HeroBanner(
                          servicesKey: servicesKey,
                          promotionsKey: promotionsKey,
                        ),
                        const SizedBox(height: 32),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: VipPromoCard(),
                        ),
                        
                        PromotionsSection(
                          key: promotionsKey, 
                          servicios: categorias 
                        ),
                        
                        const SizedBox(height: 32),
                        
                        PromoCarousel(
                          servicios: categorias 
                        ),
                        
                        const SizedBox(height: 32),
                        
                        ServicesGrid( 
                          key: servicesKey,
                          items: categorias, 
                          onItemSelected: _navigateToServicios, 
                          isLargeScreen: isLargeScreen,
                        ),
                        
                        const SizedBox(height: 32),
                        // Sección de Testimonios (con carga inteligente propia)
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