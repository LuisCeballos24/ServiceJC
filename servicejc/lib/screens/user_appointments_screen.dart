import 'package:flutter/material.dart';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  _UserAppointmentsScreenState createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  late Future<List<AppointmentModel>> _appointmentsFuture;
  final UserApiService _apiService = UserApiService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchAppointments();
  }

  Future<void> _loadUserIdAndFetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
    if (_userId != null) {
      _appointmentsFuture = _apiService.fetchAppointmentsByUserId(_userId!);
    } else {
      _appointmentsFuture = Future.value(
        [],
      ); // Retorna una lista vacía si no hay ID
    }
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      color: AppColors.secondary,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text('Cita #${appointment.id}', style: AppTextStyles.listTitle),
        subtitle: Text(
          'Estado: ${appointment.status}\nFecha: ${appointment.fechaHora}',
          style: AppTextStyles.listSubtitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: FutureBuilder<List<AppointmentModel>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tienes citas activas.', style: AppTextStyles.h3),
            );
          } else {
            final appointments = snapshot.data!;
            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _buildAppointmentCard(appointment);
              },
            );
          }
        },
      ),
    );
  }
}
