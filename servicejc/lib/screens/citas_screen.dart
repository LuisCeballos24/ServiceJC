import 'package:flutter/material.dart';
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/services/admin_api_service.dart';
import 'package:servicejc/services/appointment_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final AdminApiService _adminApiService = AdminApiService();
  final AppointmentService _appointmentService = AppointmentService();

  List<CitaModel> _citas = [];
  List<CitaModel> _citasFiltradas = [];
  List<UserModel> _tecnicos = [];
  bool _isLoading = true;
  String _estadoSeleccionado = 'TODAS';
  String _tecnicoSeleccionadoId = 'TODOS';

  final List<String> _estadosDisponibles = [
    'TODAS',
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final citas = await _appointmentService.fetchCitas();
      final tecnicos = await _adminApiService.fetchTechnicians();

      setState(() {
        _citas = citas.cast<CitaModel>();
        _tecnicos = tecnicos;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando datos de Citas: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar datos: $e',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
            ),
          ),
        );
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _citasFiltradas = _citas.where((cita) {
        final matchEstado =
            _estadoSeleccionado == 'TODAS' ||
            cita.status == _estadoSeleccionado;

        final matchTecnico = _tecnicoSeleccionadoId == 'TODOS'
            ? true
            : cita.tecnicoId == _tecnicoSeleccionadoId;
        return matchEstado && matchTecnico;
      }).toList();
    });
  }

  // FUNCIÓN AUXILIAR: Formatear fecha y hora para el display (con AM/PM)
  String _formatDateTimeForDisplay(
    DateTime date,
    String time,
    BuildContext context,
  ) {
    // 1. Convertir la hora String (HH:mm) a DateTime
    final timeParts = time.split(':');
    final hour = int.tryParse(timeParts.length > 0 ? timeParts[0] : '0') ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

    final DateTime fullDate = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // 2. Usar formato 12 horas con AM/PM
    return DateFormat('dd/MM/yyyy h:mm a').format(fullDate);
  }

  void _showEditCitaDialog(CitaModel cita) {
    String? nuevoEstado = cita.status.toUpperCase();

    // 1. Inicialización del estado interno de fecha/hora
    DateTime _mutableSelectedDate = cita.fecha;

    // Robustez Hora: Convertir HH:mm a TimeOfDay de forma segura
    final timeParts = cita.hora.split(':');
    final hour = int.tryParse(timeParts.length > 0 ? timeParts[0] : '0') ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    TimeOfDay _mutableSelectedTime = TimeOfDay(hour: hour, minute: minute);

    // 2. Inicialización del técnico (manejar el placeholder 'admin_scheduled')
    String? initialTecnicoId =
        (cita.tecnicoId == 'admin_scheduled' || cita.tecnicoId == null)
        ? null
        : cita.tecnicoId;

    String? mutableNuevoTecnicoId = initialTecnicoId;

    final servicesStr =
        cita.productosSeleccionados?.map((p) => p.nombre).join(', ') ??
        'Servicios no listados: ${cita.descripcion}';

    // Función para seleccionar nueva fecha/hora (usa setStateInterno)
    Future<void> _selectDateTime(
      BuildContext context,
      StateSetter setStateInterno,
    ) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _mutableSelectedDate,
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
          initialTime: _mutableSelectedTime,
        );

        if (pickedTime != null) {
          setStateInterno(() {
            _mutableSelectedDate = pickedDate;
            _mutableSelectedTime = pickedTime;
          });
        }
      }
    }

    // Función auxiliar para el display de fecha/hora DENTRO del diálogo
    String _displayDateTime(
      DateTime date,
      TimeOfDay time,
      BuildContext context,
    ) {
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
          title: const Text('Editar Cita y Asignar Técnico'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateInterno) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Servicios: $servicesStr',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Costo: \$${cita.costoTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 20),

                    // BOTÓN DE EDICIÓN DE FECHA/HORA
                    ElevatedButton.icon(
                      onPressed: () =>
                          _selectDateTime(context, setStateInterno),
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Fecha/Hora: ${_displayDateTime(_mutableSelectedDate, _mutableSelectedTime, context)}', // Mostrar la hora actualizada
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
                      value: nuevoEstado,
                      decoration: const InputDecoration(
                        labelText: 'Estado Actual',
                      ),
                      items: _estadosDisponibles
                          .where((estado) => estado != 'TODAS')
                          .map((String estado) {
                            return DropdownMenuItem<String>(
                              value: estado,
                              child: Text(estado),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setStateInterno(() {
                          nuevoEstado = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Selector de Técnico
                    DropdownButtonFormField<String?>(
                      value: mutableNuevoTecnicoId,
                      decoration: const InputDecoration(
                        labelText: 'Asignar Técnico',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin Asignar'),
                        ),
                        ..._tecnicos.map((UserModel tecnico) {
                          return DropdownMenuItem<String>(
                            value: tecnico.id,
                            child: Text(tecnico.nombre),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        setStateInterno(() {
                          mutableNuevoTecnicoId = newValue;
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
                String? finalTecnicoId = mutableNuevoTecnicoId;
                if (finalTecnicoId == 'admin_scheduled') {
                  finalTecnicoId = null;
                }

                // Formato HH:mm con padding para el Backend
                final String formattedTime =
                    '${_mutableSelectedTime.hour.toString().padLeft(2, '0')}:${_mutableSelectedTime.minute.toString().padLeft(2, '0')}';

                // CREACIÓN DEL OBJETO DE ACTUALIZACIÓN
                final CitaModel updatedCita = CitaModel(
                  id: cita.id,
                  userId: cita.userId,
                  tecnicoId: finalTecnicoId, // Actualizado
                  status: nuevoEstado!, // Actualizado
                  // CAMPOS ACTUALIZADOS
                  fecha: _mutableSelectedDate, // <--- NUEVA FECHA
                  hora: formattedTime, // <--- NUEVA HORA (HH:mm)
                  // CAMPOS ORIGINALES
                  costoTotal: cita.costoTotal,
                  descripcion: cita.descripcion,
                  productosSeleccionados: cita.productosSeleccionados,
                );

                try {
                  await _adminApiService.updateCita(updatedCita);
                  _loadData();
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cita actualizada con éxito.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) Navigator.of(context).pop();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al actualizar: $e',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.white,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Citas',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _estadoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por Estado',
                    ),
                    items: _estadosDisponibles.map((String estado) {
                      return DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _estadoSeleccionado = newValue;
                          _applyFilter();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tecnicoSeleccionadoId,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por Técnico',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'TODOS',
                        child: Text('Todos los Técnicos'),
                      ),
                      ..._tecnicos.map((UserModel tecnico) {
                        return DropdownMenuItem(
                          value: tecnico.id,
                          child: Text(tecnico.nombre),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _tecnicoSeleccionadoId = newValue;
                          _applyFilter();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, color: AppColors.accent),
                  tooltip: 'Recargar Citas',
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _citasFiltradas.isEmpty
                ? Center(
                    child: Text(
                      'No hay citas que coincidan con los filtros.',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.white54,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _citasFiltradas.length,
                    itemBuilder: (context, index) {
                      final cita = _citasFiltradas[index];

                      final tecnico = _tecnicos.firstWhereOrNull(
                        (t) => t.id == cita.tecnicoId,
                      );
                      final tecnicoNombre = tecnico?.nombre ?? 'Sin Asignar';

                      final servicesStr =
                          cita.productosSeleccionados
                              ?.map((p) => p.nombre)
                              .join(', ') ??
                          'Servicios no listados: ${cita.descripcion}';

                      return Card(
                        color: AppColors.secondary,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 1,
                        child: ListTile(
                          title: Text(
                            servicesStr,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Muestra el estado y el costo en una sola línea
                              Text(
                                'Estado: ${cita.status} | Costo: \$${cita.costoTotal.toStringAsFixed(2)}',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              Text(
                                'Técnico: $tecnicoNombre',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.white70,
                                ),
                              ),
                              // CORRECCIÓN CLAVE: Usar la función de display para el listado (con AM/PM)
                              Text(
                                'Fecha: ${_formatDateTimeForDisplay(cita.fecha, cita.hora, context)}',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: AppColors.white54,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.iconButton,
                            ),
                            onPressed: () => _showEditCitaDialog(cita),
                            tooltip: 'Editar Cita y Asignar Técnico',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

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
