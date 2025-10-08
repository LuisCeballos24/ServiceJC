import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/user_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  late Future<List<AppointmentModel>> _appointmentsFuture;
  final UserApiService _apiService = UserApiService();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() {
    setState(() {
      _appointmentsFuture = _apiService.fetchAllAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Citas',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<AppointmentModel>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: AppTextStyles.h3.copyWith(color: AppColors.danger),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay citas registradas.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.softWhite,
                  ),
                ),
              );
            } else {
              final appointments = snapshot.data!;
              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    color: AppColors.secondary,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      title: Text(
                        'Cita #${appointment.id}',
                        style: AppTextStyles.listTitle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Estado: ${appointment.status}\nFecha: ${appointment.fechaHora}',
                        style: AppTextStyles.listSubtitle.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.white54,
                      ),
                      onTap: () {
                        // Implementar navegación a la pantalla de detalles de la cita
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navegar a detalles de la cita'),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
