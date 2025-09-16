import 'package:flutter/material.dart';
import 'package:servicejc/screens/login_screen.dart'; // Asegúrate de importar tu pantalla de login

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Simula una breve espera de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Navega a la pantalla de login con el propósito de 'payment'
          builder: (context) => const LoginScreen(purpose: 'payment'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(230, 240, 250, 1),
              Color.fromRGBO(255, 255, 255, 1),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                color: Color.fromRGBO(52, 152, 219, 1),
              ),
              SizedBox(height: 24),
              Text(
                'Validando tu solicitud...',
                style: TextStyle(fontSize: 18, color: Color.fromRGBO(52, 73, 94, 1)),
              ),
              SizedBox(height: 8),
              Text(
                'Para continuar, inicia sesión o regístrate.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}