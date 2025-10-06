import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';
import 'package:servicejc/screens/login_screen.dart';
import '../theme/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null && token.isNotEmpty) {
      // Si hay un token, el usuario está logueado.
      // Se redirige a la pantalla principal sin permitir regresar.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeClientScreen()),
      );
    } else {
      // Si no hay token, no hay sesión activa.
      // Se redirige a la pantalla de inicio de sesión.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}
