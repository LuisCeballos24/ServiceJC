import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/user_api_service.dart';
// Importamos la pantalla de detalle que acabamos de crear
import 'package:servicejc/screens/appointment_detail_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  late Future<List<AppointmentModel>> _appointmentsFuture;
  final UserApiService _apiService = UserApiService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga
    _loadUserIdAndFetchAppointments();
  }

  // Carga inicial del ID y la primera petición
  Future<void> _loadUserIdAndFetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (mounted) {
      setState(() {
        _userId = userId;
      });
      _refreshList(); // Llamamos al método que actualiza la lista
    }
  }

  // Método dedicado a recargar la lista (útil tras editar)
  void _refreshList() {
    if (_userId != null) {
      setState(() {
        _appointmentsFuture = _apiService.fetchAppointmentsByUserId(_userId!);
      });
    } else {
      setState(() {
        _appointmentsFuture = Future.value([]);
      });
    }
  }

  // --- CONSTRUCCIÓN DE LA TARJETA ---
  Widget _buildAppointmentCard(AppointmentModel appointment) {
    // Formateo de fecha legible (Ej: 24 Oct 2023, 10:30 AM)
    final dateString = DateFormat('dd MMM yyyy, hh:mm a').format(appointment.fechaHora);
    
    // Color según estado
    Color statusColor;
    switch (appointment.estado.toLowerCase()) {
      case 'confirmada': statusColor = Colors.green; break;
      case 'pendiente': statusColor = Colors.orange; break;
      case 'cancelada': statusColor = Colors.red; break;
      case 'completada': statusColor = Colors.blue; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      color: AppColors.secondary,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // 💡 LÓGICA DE NAVEGACIÓN Y REFRESCO
        onTap: () async {
          // Navegamos a la pantalla de detalle y esperamos un resultado
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailScreen(appointment: appointment),
            ),
          );

          // Si result es true (significa que el usuario guardó cambios), recargamos la lista
          if (result == true) {
            _refreshList();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cita', // O puedes poner el nombre del servicio principal si lo tienes
                    style: AppTextStyles.listTitle.copyWith(color: AppColors.accent),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      appointment.estado.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    dateString,
                    style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (appointment.descripcion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    appointment.descripcion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Citas',
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
        child: _userId == null 
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : FutureBuilder<List<AppointmentModel>>(
                future: _appointmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error al cargar citas: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, size: 60, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes citas activas.',
                            style: AppTextStyles.h3.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Ordenamos las citas (Más recientes primero)
                    final appointments = snapshot.data!;
                    appointments.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

                    return RefreshIndicator(
                      onRefresh: () async => _refreshList(),
                      color: AppColors.accent,
                      backgroundColor: AppColors.secondary,
                      child: ListView.builder(
                        itemCount: appointments.length,
                        physics: const AlwaysScrollableScrollPhysics(), // Permite pull-to-refresh incluso si hay pocos items
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}