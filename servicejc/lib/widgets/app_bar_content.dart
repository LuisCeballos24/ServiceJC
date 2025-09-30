import 'package:flutter/material.dart';
import 'package:servicejc/screens/admin_dashboard_screen.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estilos centralizados
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';


class AppBarContent extends StatelessWidget {
  final bool isLargeScreen;
  const AppBarContent({super.key, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeClientScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8), // opcional
          ),
          child: Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: AppColors.accent, size: 40),
              const SizedBox(width: 8),
              Text('ServiceJC', style: AppTextStyles.h1),
            ],
          ),
        ),
        if (isLargeScreen)
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
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');
                  if (token != null && token.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                    );
                  } else {
                    // Lógica para navegar a la pantalla de login si el usuario no tiene token
                    AuthService().signOut(); // o navega a una pantalla de login
                  }
                },
                icon: const Icon(Icons.account_circle),
                label: const Text('Mi Cuenta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical:4, horizontal: 6),
                  backgroundColor: AppColors.elevatedButtonForeground,
                  foregroundColor: AppColors.elevatedButton,
                ),
              ),
            ],
          )
        else
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.elevatedButtonForeground, size: 30),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token != null && token.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                );
              } else {
                AuthService().signOut();
              }
            },
          ),
      ],
    );
  }
}