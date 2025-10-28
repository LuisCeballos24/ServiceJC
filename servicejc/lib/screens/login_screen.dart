import 'package:flutter/material.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/register_screen.dart';

import 'package:servicejc/screens/admin_dashboard_screen.dart'; // (Ruta de Administrador)
import 'package:servicejc/screens/technician_panel_screen.dart'; // (Ruta de Técnico)
import 'package:servicejc/screens/welcome_client_screen.dart'; // (Ruta por defecto para el Cliente)

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  final String purpose;
  const LoginScreen({super.key, this.purpose = 'initial'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String email = _emailController.text;
        final String password = _passwordController.text;
        final response = await _authService.loginUser(email, password); //

        final prefs = await SharedPreferences.getInstance(); //
        await prefs.setString('authToken', response.token); //

        // 1. Obtener el rol del usuario
        final userRole = response.rol; //

        if (userRole != null) {
          await prefs.setString('userRole', userRole); //
        } else {
          await prefs.remove('userRole'); //
        }

        if (response.userId != null) {
          await prefs.setString('userId', response.userId!); //
        } else {
          await prefs.remove('userId'); //
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login exitoso. Bienvenido de nuevo.',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white), //
            ),
          ),
        );
        // 2. Definir la pantalla de destino según el rol
        Widget nextScreen;
        if (userRole == 'ADMINISTRATIVO') {
          //
          // Redirigir al panel de administración
          nextScreen = AdminDashboardScreen(); //
        } else if (userRole == 'TECNICO') {
          //
          // Redirigir al panel del técnico
          nextScreen = const TechnicianPanelScreen(); //
        } else {
          // Por defecto (USUARIO_FINAL) al home principal
          nextScreen = const WelcomeClientScreen(); //
        }

        // 3. Navegación definitiva, reemplazando todas las rutas anteriores
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => nextScreen),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error de login: ${e.toString()}',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white), //
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.lock_rounded,
                        size: 80,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.purpose == 'initial'
                            ? 'Iniciar Sesión'
                            : 'Confirmar Solicitud',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: AppTextStyles.body.copyWith(
                            color: AppColors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: AppColors.secondary,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.white54,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su correo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: AppTextStyles.body.copyWith(
                            color: AppColors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: AppColors.secondary,
                          suffixIcon: const Icon(
                            Icons.visibility,
                            color: AppColors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.white54,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su contraseña.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (widget.purpose == 'initial')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.elevatedButton,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.purpose == 'initial'
                              ? 'Ingresar'
                              : 'Continuar con el Pago',
                          style: AppTextStyles.elevatedButton,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "¿No tienes una cuenta? ",
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Regístrate aquí',
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.elevatedButton,
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
        ),
      ),
    );
  }
}
