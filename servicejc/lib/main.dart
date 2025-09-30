import 'package:flutter/material.dart';
import 'package:servicejc/screens/login_screen.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';

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
      theme: AppTheme.lightTheme,     // Tema claro
      darkTheme: AppTheme.darkTheme,  // Tema oscuro
      themeMode: ThemeMode.dark,    // Sigue la configuración del sistema
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeClientScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
