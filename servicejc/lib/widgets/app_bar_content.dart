import 'package:flutter/material.dart';
import 'package:servicejc/screens/admin_dashboard_screen.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estilos centralizados
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Convertimos a StatefulWidget para manejar el estado del token
class AppBarContent extends StatefulWidget {
  final bool isLargeScreen;
  const AppBarContent({super.key, required this.isLargeScreen});

  @override
  State<AppBarContent> createState() => _AppBarContentState();
}

class _AppBarContentState extends State<AppBarContent> {
  bool _isLoggedIn =
      false; // Estado local para saber si el usuario está logueado

  @override
  void initState() {
    super.initState();
    // Verificamos el estado de la sesión al inicio
    _checkLoginStatus();
  }

  // Función para verificar si existe un token y actualizar el estado
  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Usamos 'authToken' ya que es la clave que usamos en WelcomeClientScreen
    final token = prefs.getString('authToken');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  // Función para cerrar sesión
  void _logout() async {
    // 1. Eliminar el token localmente (debe estar implementado en AuthService)
    await AuthService().signOut();

    // 2. Notificamos y actualizamos el estado
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada correctamente.')),
    );

    // 3. Actualizamos el estado de la barra (para mostrar 'Iniciar Sesión')
    setState(() {
      _isLoggedIn = false;
    });

    // 4. Redirigir a la pantalla principal y limpiar la pila
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  // Widget que crea el menú desplegable (Popup Menu)
  Widget _buildAccountButton(BuildContext context) {
    // Definimos las opciones que verá el usuario
    final List<PopupMenuItem<String>> menuItems;

    if (_isLoggedIn) {
      // Opciones para usuario LOGUEADO
      menuItems = [
        const PopupMenuItem<String>(
          value: 'dashboard',
          child: Text('Panel de Usuario'),
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
      // Opciones para usuario NO LOGUEADO
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

    // Usamos PopupMenuButton en lugar del botón simple
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'login':
            // Navegamos a /login y al regresar, verificamos el estado
            Navigator.of(
              context,
            ).pushNamed('/login').then((_) => _checkLoginStatus());
            break;
          case 'register':
            Navigator.of(
              context,
            ).pushNamed('/register').then((_) => _checkLoginStatus());
            break;
          case 'dashboard':
            // Navegación al dashboard
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            ).then((_) => _checkLoginStatus());
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          menuItems, // Ítems del menú (antes de 'child')
      // Aseguramos que el color del icono en la versión compacta sea el acento
      icon: widget.isLargeScreen
          ? null
          : const Icon(Icons.account_circle, color: AppColors.accent, size: 30),
      // El icono/botón que dispara el menú (AHORA AL FINAL)
      child: widget.isLargeScreen
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.accent, // Color de fondo del botón
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
              onPressed: null, // El PopupMenuButton gestiona el click
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // Regresar a la pantalla de bienvenida (limpiando la pila de navegación)
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
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
              Text('ServiceJC', style: AppTextStyles.h1),
            ],
          ),
        ),

        if (widget.isLargeScreen)
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
              _buildAccountButton(context), // Botón de cuenta dinámico
            ],
          )
        else
          _buildAccountButton(
            context,
          ), // Botón de cuenta dinámico (versión compacta)
      ],
    );
  }
}
