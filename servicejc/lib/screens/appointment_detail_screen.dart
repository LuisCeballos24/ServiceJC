import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servicejc/models/appointment_model.dart';
import 'package:servicejc/services/user_api_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final UserApiService _apiService = UserApiService();
  
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Inicializamos con los datos actuales de la cita
    _descriptionController = TextEditingController(text: widget.appointment.descripcion);
    _selectedDate = widget.appointment.fechaHora;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.fechaHora);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // --- LOGICA DE GUARDADO ---
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // 1. Construir la nueva fecha combinada
      final newDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // 2. Crear el mapa de datos (Solo enviamos lo que el backend permite editar)
      final updateData = {
        'descripcion': _descriptionController.text,
        'fechaHora': newDateTime.toIso8601String(),
        // Nota: No enviamos 'usuarioId' ni 'servicios', esos no cambian.
      };

      // 3. Enviar al Backend
      await _apiService.updateAppointment(widget.appointment.id, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita actualizada correctamente'), backgroundColor: AppColors.success),
        );
        // Regresamos 'true' para indicar que se debe recargar la lista anterior
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateTime() async {
    if (!_isEditing) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // No permitir fechas pasadas
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.primary,
            surface: AppColors.secondary,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  // Helper visual para filas de información
  Widget _buildInfoRow(String label, String value, {IconData? icon, bool isEditable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.accent, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.white, 
                    fontSize: 16,
                    decoration: isEditable && _isEditing ? TextDecoration.underline : null,
                    decorationColor: AppColors.accent,
                  ),
                ),
              ),
              if (isEditable && _isEditing)
                const Icon(Icons.edit, color: AppColors.accent, size: 18),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Regla de negocio: Solo editar si no está completada ni cancelada
    final bool canEdit = widget.appointment.estado != 'completada' && widget.appointment.estado != 'cancelada';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cita' : 'Detalle de Cita', style: const TextStyle(color: AppColors.accent)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        actions: [
          if (canEdit && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge de Estado
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.appointment.estado).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(widget.appointment.estado)),
                  ),
                  child: Text(
                    widget.appointment.estado.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(widget.appointment.estado), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),

              // Fecha (Editable)
              InkWell(
                onTap: _pickDateTime,
                child: _buildInfoRow(
                  "Fecha y Hora",
                  DateFormat('dd/MM/yyyy hh:mm a').format(
                    _isEditing 
                      ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute) 
                      : widget.appointment.fechaHora
                  ),
                  icon: Icons.calendar_today,
                  isEditable: true,
                ),
              ),

              // Descripción (Editable)
              const Text("Descripción / Notas", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.white54)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent)),
                  ),
                )
              else
                Text(widget.appointment.descripcion, style: AppTextStyles.bodyText.copyWith(color: Colors.white)),
              
              const Divider(color: Colors.white24, height: 30),

              // Campos Solo Lectura
              _buildInfoRow("Servicios", widget.appointment.serviciosNombres.join(", "), icon: Icons.build),
              _buildInfoRow("Costo Total", "\$${widget.appointment.costoTotal.toStringAsFixed(2)}", icon: Icons.monetization_on),
              _buildInfoRow("Dirección", widget.appointment.direccionString, icon: Icons.location_on),
              if (widget.appointment.tecnicoNombre != null && widget.appointment.tecnicoNombre!.isNotEmpty)
                 _buildInfoRow("Técnico Asignado", widget.appointment.tecnicoNombre!, icon: Icons.person),

              const SizedBox(height: 40),

              // Botones de Acción
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditing = false), // Cancelar
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges, // Guardar
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text("Guardar"),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmada': return AppColors.success;
      case 'pendiente': return Colors.orange;
      case 'completada': return Colors.blue;
      case 'cancelada': return AppColors.danger;
      default: return Colors.grey;
    }
  }
}