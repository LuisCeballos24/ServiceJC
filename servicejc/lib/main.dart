import 'package:flutter/material.dart';
import 'package:servicejc/screens/login_screen.dart';
import 'package:servicejc/screens/register_screen.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';
import 'package:servicejc/screens/admin_management_screen.dart';

// Tema global
import 'package:servicejc/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceJC',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const WelcomeClientScreen(),
      routes: {
        // RUTA DE LOGIN: Pantalla de inicio de sesión
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin/management': (context) => const AdminManagementScreen(),
      },
    );
  }
}
