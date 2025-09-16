// En lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';
import 'package:servicejc/screens/register_screen.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:servicejc/screens/payment_method_screen.dart'; // ¡Importa la nueva pantalla!

class LoginScreen extends StatefulWidget {
  final String purpose;
  const LoginScreen({super.key, this.purpose = 'initial'});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      // Asume que la autenticación es exitosa y devuelve un token
      final response = await _authService.loginUser(email, password);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login exitoso. Token: ${response.token}')),
      );

      // Lógica de navegación basada en el propósito
      if (widget.purpose == 'initial') {
        // Si el propósito es "initial", navega a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeClientScreen(),
          ),
        );
      } else {
        // Si el propósito no es "initial", navega a la pasarela de pago
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentMethodScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de login: ${e.toString()}')),
      );
    }
  }

  // ... El resto del código `build` sigue siendo el mismo.
  // ... No necesitas cambiar nada en `build` a menos que quieras ajustar el texto de los botones.
  
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
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(
                    Icons.lock_rounded,
                    size: 80,
                    color: Color.fromRGBO(52, 73, 94, 1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.purpose == 'initial' ? 'Iniciar Sesión' : 'Confirmar Solicitud',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(52, 73, 94, 1),
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      suffixIcon: const Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.purpose == 'initial')
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Color.fromRGBO(52, 152, 219, 1),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(39, 174, 96, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.purpose == 'initial' ? 'Ingresar' : 'Continuar con el Pago',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("¿No tienes una cuenta? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: Color.fromRGBO(52, 152, 219, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}