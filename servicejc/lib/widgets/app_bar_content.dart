import 'package:flutter/material.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/my_account_screen.dart';

// Estilos centralizados
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// 💡 IMPORTACIÓN ACTUALIZADA (Si el archivo está en la carpeta widgets)
import 'package:servicejc/widgets/universal_search_delegate.dart'; 

class AppBarContent extends StatefulWidget {
  final bool isLargeScreen;
  const AppBarContent({super.key, required this.isLargeScreen});

  @override
  State<AppBarContent> createState() => _AppBarContentState();
}

class _AppBarContentState extends State<AppBarContent> {
  bool _isLoggedIn = false; 

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  void _logout() async {
    await AuthService().signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente.')),
      );
      setState(() {
        _isLoggedIn = false;
      });
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Widget _buildAccountButton(BuildContext context) {
    final List<PopupMenuItem<String>> menuItems;

    if (_isLoggedIn) {
      menuItems = [
        const PopupMenuItem<String>(
          value: 'account', 
          child: Text('Mi Cuenta'), 
        ),
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Configuración'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Cerrar Sesión'),
        ),
      ];
    } else {
      menuItems = [
        const PopupMenuItem<String>(
          value: 'login',
          child: Text('Iniciar Sesión'),
        ),
        const PopupMenuItem<String>(
          value: 'register',
          child: Text('Registrarse'),
        ),
      ];
    }

    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'login':
            Navigator.of(context).pushNamed('/login').then((_) => _checkLoginStatus());
            break;
          case 'register':
            Navigator.of(context).pushNamed('/register').then((_) => _checkLoginStatus());
            break;
          case 'account': 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyAccountScreen()),
            ).then((_) => _checkLoginStatus());
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      itemBuilder: (BuildContext context) => menuItems, 
      icon: widget.isLargeScreen
          ? null
          : const Icon(Icons.account_circle, color: AppColors.accent, size: 30),
      child: widget.isLargeScreen
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.accent, 
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Mi Cuenta',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: AppColors.accent,
                size: 30,
              ),
              onPressed: null, 
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- LOGO (IZQUIERDA) ---
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.build_circle_rounded,
                color: AppColors.accent,
                size: 40,
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/logojcservicios.png', 
                height: 40, 
                fit: BoxFit.contain, 
              ),
            ],
          ),
        ),

        // --- BARRA DERECHA ---
        if (widget.isLargeScreen)
          // MODO ESCRITORIO (PC)
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Servicios', style: AppTextStyles.h3),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Contacto', style: AppTextStyles.h3),
              ),
              const SizedBox(width: 16),
              
              // 💡 LUPA (PC)
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.accent),
                tooltip: 'Buscar',
                onPressed: () {
                  showSearch(
                    context: context, 
                    // Sin parámetros = búsqueda global (servicios)
                    delegate: UniversalSearchDelegate(), 
                  );
                },
              ),
              const SizedBox(width: 16),
              // -----------------------

              _buildAccountButton(context), 
            ],
          )
        else
          // MODO MÓVIL
          Row(
            children: [
               // 💡 LUPA (MÓVIL)
               IconButton(
                icon: const Icon(Icons.search, color: AppColors.accent, size: 28),
                onPressed: () {
                  showSearch(
                    context: context, 
                    // Sin parámetros = búsqueda global (servicios)
                    delegate: UniversalSearchDelegate(), 
                  );
                },
              ),
              const SizedBox(width: 8),
              // -----------------------

               _buildAccountButton(context), 
            ],
          )
      ],
    );
  }
}