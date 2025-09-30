import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Ya no necesitamos importar las pantallas aquí, solo el navigation
// import 'package:servicejc/screens/welcome_client_screen.dart';
// import 'package:servicejc/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Función que verifica si el token existe en el almacenamiento local
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Verifica si la clave 'authToken' existe y si el valor no está vacío.
    final token = prefs.getString('authToken');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Al inicio, simplemente mostramos la pantalla de carga.
    // El FutureBuilder se encarga de la navegación inmediatamente después.
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        // Muestra una pantalla de carga mientras se verifica el token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700), // Usando tu color dorado de acento
              ),
            ),
          );
        }

        // Ejecutamos la navegación inmediatamente después de tener los datos.
        // Usamos addPostFrameCallback para asegurar que la navegación ocurra
        // después de que el widget se haya construido por completo.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.data == true) {
            // Si está logueado, navega al dashboard principal
            Navigator.of(context).pushReplacementNamed('/home_client');
          } else {
            // Si no está logueado, navega al login
            // Usamos 'pushReplacementNamed' para evitar que el usuario vuelva atrás.
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });

        // Retorna un contenedor vacío (o la pantalla de carga) ya que la navegación
        // real ocurrirá en addPostFrameCallback.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          ),
        );
      },
    );
  }
}
