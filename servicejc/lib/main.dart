import 'package:flutter/material.dart';
// Pantallas
import 'package:servicejc/screens/login_screen.dart';
import 'package:servicejc/screens/register_screen.dart';
import 'package:servicejc/screens/welcome_client_screen.dart';
import 'package:servicejc/screens/admin_management_screen.dart';
import 'package:servicejc/screens/loading_screen.dart';

// Paquetes necesarios para internacionalización
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // CLAVE para inicializar intl

// Tema global
import 'package:servicejc/theme/app_theme.dart';

// Función principal asíncrona para inicializar los datos de localización
void main() async {
  // Asegurarse de que Flutter esté inicializado para las llamadas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // CLAVE: Inicializar los datos de formato de fecha para español ('es')
  // Esto soluciona el error LocaleDataException.
  await initializeDateFormatting('es', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceJC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // CONFIGURACIÓN DE LOCALIZACIÓN
      localizationsDelegates: const [
        // Delega la localización de widgets y material design
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español (Necesario para el formato de fecha)
      ],

      // Usar LoadingScreen como pantalla inicial para determinar el estado de autenticación
      home: const WelcomeClientScreen(),
      routes: {
        // Rutas definidas:
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin/management': (context) => const AdminManagementScreen(),
      },
    );
  }
}
