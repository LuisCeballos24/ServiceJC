import 'package:flutter/material.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_address_model.dart';
import 'package:servicejc/services/admin_api_service.dart';
import 'package:intl/intl.dart';

// Extensión auxiliar para encontrar el primer elemento que cumple una condición
extension ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class TechnicianPanelScreen extends StatefulWidget {
  final String technicianId;

  const TechnicianPanelScreen({super.key, required this.technicianId});

  @override
  State<TechnicianPanelScreen> createState() => _TechnicianPanelScreenState();
}

class _TechnicianPanelScreenState extends State<TechnicianPanelScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<CitaModel> _citas = [];
  bool _isLoading = true;

  // Estados relevantes que un técnico puede asignar
  final List<String> _estadosDisponibles = [
    'PENDIENTE',
    'ASIGNADA',
    'CONFIRMADA',
    'EN PROGRESO',
    'COMPLETADA',
    'CANCELADA',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCitas();
  }

  Future<void> _fetchCitas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Carga de citas filtrada por el ID del técnico logueado
      final citas = await _apiService.fetchCitasByTechnicianId(
        widget.technicianId,
      );

      setState(() {
        _citas = citas.cast<CitaModel>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando citas del técnico: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar citas: $e',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // FUNCIÓN AUXILIAR: Formato de fecha largo (ej: 9 de octubre de 2025, 4:00:00 a.m. UTC-5)
  String _formatDateTime(DateTime date, String timeString) {
    final dateFormatter = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es');
    final formattedDate = dateFormatter.format(date);

    DateTime parsedTime;
    try {
      // Manejar la hora que viene en formato HH:mm
      parsedTime = DateFormat('HH:mm').parse(timeString);
    } catch (_) {
      parsedTime = DateTime(0, 1, 1, 0, 0);
    }

    final timeFormatter = DateFormat('h:mm:ss a', 'es');
    final formattedTime = timeFormatter
        .format(parsedTime)
        .toLowerCase()
        .replaceAll('.', '');

    const timezone = 'UTC-5';

    return '$formattedDate, $formattedTime $timezone';
  }

  // FUNCIÓN AUXILIAR: Formatear lista de servicios
  String _formatServices(CitaModel cita) {
    if (cita.productosSeleccionados == null ||
        cita.productosSeleccionados!.isEmpty) {
      return 'Servicios no especificados.';
    }
    // CLAVE: Mapea cada ProductoModel a su nombre y los une con comas
    final names = cita.productosSeleccionados!
        .map((p) => p.nombre ?? 'Producto Desconocido')
        .toList();

    // Si la lista de nombres está vacía después del mapeo, muestra un mensaje por defecto
    if (names.isEmpty) {
      return 'Servicios no especificados.';
    }

    return names.join(', ');
  }

  // DIÁLOGO SIMPLIFICADO PARA EL TÉCNICO (solo fecha/hora y estado)
  void _showEditCitaDialog(CitaModel cita) {
    String? nuevoEstado = cita.status.toUpperCase();

    DateTime mutableSelectedDate = cita.fecha;

    final timeParts = cita.hora.split(':');
    final hour = int.tryParse(timeParts.isNotEmpty ? timeParts[0] : '0') ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    TimeOfDay mutableSelectedTime = TimeOfDay(hour: hour, minute: minute);

    final servicesStr = _formatServices(cita);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PA',
      symbol: '\$',
      decimalDigits: 2,
    );
    final formattedCost = currencyFormat.format(cita.costoTotal);

    Future<void> selectDateTime(
      BuildContext context,
      StateSetter setStateInterno,
    ) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: mutableSelectedDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime(2028),
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.accent,
                onPrimary: AppColors.white,
                onSurface: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: mutableSelectedTime,
        );

        if (pickedTime != null) {
          setStateInterno(() {
            mutableSelectedDate = pickedDate;
            mutableSelectedTime = pickedTime;
          });
        }
      }
    }

    String displayDateTime(DateTime date, TimeOfDay time) {
      final DateTime combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      return DateFormat('dd/MM/yyyy h:mm a').format(combined);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Estado de Cita'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateInterno) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cita ID: ${cita.id}',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Servicios: $servicesStr',
                      style: AppTextStyles.listSubtitle,
                    ),
                    const SizedBox(height: 20),

                    // BOTÓN DE EDICIÓN DE FECHA/HORA
                    ElevatedButton.icon(
                      onPressed: () =>
                          selectDateTime(context, setStateInterno),
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Nueva Fecha/Hora: ${displayDateTime(mutableSelectedDate, mutableSelectedTime)}',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector de Estado
                    DropdownButtonFormField<String>(
                      initialValue: nuevoEstado,
                      decoration: const InputDecoration(
                        labelText: 'Cambiar Estado',
                        border: OutlineInputBorder(),
                      ),
                      items: _estadosDisponibles.map((String estado) {
                        return DropdownMenuItem<String>(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateInterno(() {
                          nuevoEstado = newValue;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String formattedTime =
                    '${mutableSelectedTime.hour.toString().padLeft(2, '0')}:${mutableSelectedTime.minute.toString().padLeft(2, '0')}';

                final CitaModel updatedCita = CitaModel(
                  id: cita.id,
                  userId: cita.userId,
                  tecnicoId: cita.tecnicoId,
                  status: nuevoEstado!,
                  fecha: mutableSelectedDate,
                  hora: formattedTime,
                  costoTotal: cita.costoTotal,
                  descripcion: cita.descripcion,
                );

                try {
                  await _apiService.updateCita(updatedCita);
                  _fetchCitas();
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita actualizada con éxito.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar: $e'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  // Widget auxiliar para mejorar la legibilidad del Card
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    TextStyle style, {
    Color? color,
    bool isExpanded = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: isExpanded
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: AppTextStyles.listSubtitle.copyWith(
              color: AppColors.softWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          isExpanded
              ? Expanded(
                  child: Text(
                    value,
                    style: style.copyWith(color: color),
                    overflow: TextOverflow.visible,
                    maxLines: 5,
                  ),
                )
              : Text(value, style: style.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildCitaCard(CitaModel cita) {
    final UserAddressModel? address = cita.cliente?.direccion;
    final formattedDateTime = _formatDateTime(cita.fecha, cita.hora);
    final clientDisplay = cita.cliente?.nombre ?? cita.userId;
    final currencyFormat = NumberFormat.currency(
      locale: 'es_PA',
      symbol: '\$',
      decimalDigits: 2,
    );
    final formattedCost = currencyFormat.format(cita.costoTotal);
    final servicesStr = _formatServices(cita); // Usa la función corregida

    // Determinar color de estatus
    Color statusColor;
    switch (cita.status.toUpperCase()) {
      case 'PENDIENTE':
        statusColor = AppColors.danger;
        break;
      case 'ASIGNADA':
        statusColor = AppColors.iconButton;
        break;
      case 'EN PROGRESO':
        statusColor = AppColors.accent;
        break;
      case 'COMPLETADA':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.white70;
    }

    return Card(
      elevation: 4,
      color: AppColors.secondary,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y estatus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cita ID: ${cita.id}',
                  style: AppTextStyles.h4.copyWith(color: AppColors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    cita.status.toUpperCase(),
                    style: AppTextStyles.bodyText.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.white54, height: 20),

            // Información General
            _buildInfoRow(
              Icons.person,
              'Cliente:',
              clientDisplay,
              AppTextStyles.bodyText,
              color: AppColors.white,
            ),
            _buildInfoRow(
              Icons.schedule,
              'Horario:',
              formattedDateTime,
              AppTextStyles.bodyText,
              color: AppColors.white,
            ),

            const SizedBox(height: 10),

            // Servicios y Descripción (Usando servicesStr que viene de _formatServices)
            _buildInfoRow(
              Icons.build,
              'Servicios:',
              servicesStr,
              AppTextStyles.listSubtitle,
              isExpanded: true,
              color: AppColors.white70,
            ),
            _buildInfoRow(
              Icons.description,
              'Detalle:',
              cita.descripcion.isNotEmpty
                  ? cita.descripcion
                  : 'No proporcionada.',
              AppTextStyles.listSubtitle,
              isExpanded: true,
              color: AppColors.white70,
            ),

            const SizedBox(height: 10),

            // Dirección
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ubicación: ${address?.house ?? 'N/A'}, ${address?.barrio ?? 'N/A'} (${address?.corregimiento ?? 'N/A'}, ${address?.district ?? 'N/A'})',
                    style: AppTextStyles.listSubtitle.copyWith(
                      color: AppColors.white70,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                  ),
                ),
                // Botón de Mapa (Simulado)
                IconButton(
                  icon: const Icon(Icons.map, color: AppColors.iconButton),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navegación a la ubicación (Simulado).'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón de Edición
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showEditCitaDialog(cita),
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.elevatedButtonForeground,
                ),
                label: Text(
                  'Actualizar Estado/Fecha',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Citas Asignadas',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCitas),
        ],
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
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : _citas.isEmpty
              ? Center(
                  child: Text(
                    'No tienes citas asignadas.',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _citas.length,
                  itemBuilder: (context, index) {
                    final cita = _citas[index];
                    return _buildCitaCard(cita);
                  },
                ),
        ),
      ),
    );
  }
}
