import 'package:flutter/material.dart';
import 'package:servicejc/screens/admin_dashboard_screen.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarContent extends StatelessWidget {
  final bool isLargeScreen;

  const AppBarContent({super.key, required this.isLargeScreen});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.build_circle_rounded, color: Colors.white, size: 40),
            const SizedBox(width: 8),
            const Text(
              'ServiceJC',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (isLargeScreen)
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Servicios', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Contacto', style: TextStyle(color: Colors.white)),
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
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade800,
                ),
              ),
            ],
          )
        else
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
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