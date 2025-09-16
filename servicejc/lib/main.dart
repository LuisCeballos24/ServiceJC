import 'package:flutter/material.dart'; // Importamos la pantalla de bienvenida
import 'package:servicejc/screens/login_screen.dart'; // Importamos la pantalla de login
import 'package:servicejc/screens/welcome_client_screen.dart'; // Importamos la pantalla del cliente

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceJC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // La ruta inicial es ahora la pantalla de bienvenida
      routes: {
        '/': (context) => const WelcomeClientScreen(),
        '/login': (context) => const LoginScreen(),
        // Agrega aquí más rutas para el registro de usuario y técnico
      },
    );
  }
}