import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicejc/screens/user_appointments_screen.dart';
import 'package:servicejc/screens/admin_dashboard_screen.dart';
import 'package:servicejc/screens/technician_panel_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  String? _userRole;
  String? _userId; // Necesitamos esto para el técnico

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    final id = prefs.getString('userId');

    print("🔍 DEBUG CUENTA: Rol cargado: '$role', ID: '$id'");

    setState(() {
      _userRole = role;
      _userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Estado de Carga (Si aún no lee las preferencias)
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Cuenta',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------
              // TARJETA DE ADMINISTRADOR
              // ---------------------------------------------------------
              if (_userRole == 'ADMINISTRATIVO' || _userRole == 'admin')
                _buildOptionCard(
                  context,
                  title: 'Panel de Administración',
                  icon: Icons.dashboard,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminDashboardScreen()),
                    );
                  },
                ),

              // ---------------------------------------------------------
              // TARJETA DE TÉCNICO
              // ---------------------------------------------------------
              if (_userRole == 'TECNICO' || _userRole == 'tecnico')
                _buildOptionCard(
                  context,
                  title: 'Panel de Técnico',
                  icon: Icons.engineering,
                  onTap: () {
                    // Corrección: Usamos el ID real, no el texto 'userId'
                    if (_userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TechnicianPanelScreen(technicianId: _userId!),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error: ID no encontrado")));
                    }
                  },
                ),

              // ---------------------------------------------------------
              // TARJETA DE USUARIO (CLIENTE)
              // ---------------------------------------------------------
              // Aceptamos 'USUARIO_FINAL' O 'user' (lo que manda el backend)
              if (_userRole == 'USUARIO_FINAL' || _userRole == 'user')
                _buildOptionCard(
                  context,
                  title: 'Mis Citas Activas',
                  icon: Icons.calendar_today,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserAppointmentsScreen(),
                      ),
                    );
                  },
                ),

              // ---------------------------------------------------------
              // DEBUG: MENSAJE SI NO COINCIDE NINGÚN ROL
              // ---------------------------------------------------------
              if (!['ADMINISTRATIVO', 'admin', 'TECNICO', 'tecnico', 'USUARIO_FINAL', 'user']
                  .contains(_userRole))
                Card(
                  color: Colors.red.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error: Rol desconocido '$_userRole'.\nRevisa el backend.",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}