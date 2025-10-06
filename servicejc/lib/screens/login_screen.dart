import 'package:flutter/material.dart';
import 'package:servicejc/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  // Aseguramos que 'purpose' esté aquí, aunque ya no lo usemos para la navegación principal.
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
    // 1. Validar el formulario
    if (_formKey.currentState!.validate()) {
      try {
        final String email = _emailController.text;
        final String password = _passwordController.text;

        // 2. Intentar autenticar y obtener la respuesta (token, rol, userId)
        final response = await _authService.loginUser(email, password);

        // 3. GUARDAR LA SESIÓN (Token, Rol y ID)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', response.token);
        if (response.rol != null) {
          await prefs.setString('userRole', response.rol!);
        }
        if (response.userId != null) {
          await prefs.setString('userId', response.userId!);
        }

        // 4. Feedback al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso. Bienvenido de nuevo.')),
        );

        // 5. Redirección a la pantalla principal
        // Utilizamos pushReplacement para limpiar la pila y que no pueda regresar al login.
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Redirige a la ruta raíz (WelcomeClientScreen, si está configurada así)
          (Route<dynamic> route) => false, // Elimina todas las rutas de la pila
        );
      } catch (e) {
        // Manejo de errores de autenticación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de login: ${e.toString()}')),
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
              child: SingleChildScrollView(
                // Usamos SingleChildScrollView para evitar overflow
                child: Form(
                  // Contenedor del formulario para validación
                  key: _formKey,
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
                        widget.purpose == 'initial'
                            ? 'Iniciar Sesión'
                            : 'Confirmar Solicitud',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(52, 73, 94, 1),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Campo de Correo Electrónico
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese su correo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de Contraseña
                      TextFormField(
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
                            onPressed: () {
                              // Lógica para recuperar contraseña
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Color.fromRGBO(52, 152, 219, 1),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Botón de Ingreso
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
                          widget.purpose == 'initial'
                              ? 'Ingresar'
                              : 'Continuar con el Pago',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón de Registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("¿No tienes una cuenta? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
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
        ),
      ),
    );
  }
}
