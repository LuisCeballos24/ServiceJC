import 'package:flutter/material.dart';
import 'package:servicejc/models/cita_model.dart';
import 'package:servicejc/models/user_model.dart';
import 'package:servicejc/services/admin_api_service.dart';
import 'package:servicejc/services/appointment_service.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

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
    'EN PROGRESO',
    'COMPLETADA',
    'CANCELADA',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carga todas las citas y la lista de técnicos
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final citas = await _appointmentService.fetchServices();
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

  // Lógica de Filtrado por Estado y Técnico
  void _applyFilter() {
    setState(() {
      _citasFiltradas = _citas.where((cita) {
        // Filtro por Estado (usa cita.status de Dart)
        final matchEstado =
            _estadoSeleccionado == 'TODAS' ||
            cita.status.toUpperCase() == _estadoSeleccionado.toUpperCase();

        // Filtro por Técnico (usa cita.tecnicoId)
        final matchTecnico = _tecnicoSeleccionadoId == 'TODOS'
            ? true // Si es 'TODOS', se incluye
            : cita.tecnicoId == _tecnicoSeleccionadoId;
        return matchEstado && matchTecnico;
      }).toList();
    });
  }

  // Diálogo para Editar y Asignar Cita (Edición Compacta y Funcional)
  void _showEditCitaDialog(CitaModel cita) {
    String? nuevoEstado = cita.status;
    String? nuevoTecnicoId = cita.tecnicoId;

    // Concatenamos los nombres de los productos/servicios para la vista
    final servicesStr =
        cita.productos?.keys.map((p) => p.nombre).join(', ') ??
        'Servicios no listados';

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
                      'Fecha/Hora: ${cita.fecha.day}/${cita.fecha.month}/${cita.fecha.year} ${cita.hora}',
                      style: AppTextStyles.bodyText,
                    ),
                    Text(
                      'Costo: \$${cita.costoTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: 20),

                    // Selector de Estado
                    DropdownButtonFormField<String>(
                      value: nuevoEstado,
                      decoration: const InputDecoration(
                        labelText: 'Estado Actual',
                      ),
                      items: _estadosDisponibles.skip(1).map((String estado) {
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
                    const SizedBox(height: 20),

                    // Selector de Técnico
                    DropdownButtonFormField<String?>(
                      value: nuevoTecnicoId,
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
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setStateInterno(() {
                          nuevoTecnicoId = newValue;
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
                // Creamos una nueva instancia de CitaModel con los cambios
                final CitaModel updatedCita = CitaModel(
                  id: cita.id,
                  userId: cita.userId,
                  tecnicoId: nuevoTecnicoId, // Actualizado
                  status: nuevoEstado!, // Actualizado
                  // Mantenemos los campos originales (crucial para el Backend)
                  fecha: cita.fecha,
                  hora: cita.hora,
                  costoTotal: cita.costoTotal,
                  descripcion: cita.descripcion,
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
    final DateFormat listFormatter = DateFormat('dd/MM HH:mm');

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
          // 1. Sección de Filtros (Compacta y funcional)
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
                      }).toList(),
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

          // 2. Listado Compacto de Citas
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

                      // Buscamos el nombre del técnico
                      final tecnico = _tecnicos.firstWhereOrNull(
                        (t) => t.id == cita.tecnicoId,
                      );
                      final tecnicoNombre = tecnico?.nombre ?? 'Sin Asignar';

                      // Concatenamos los nombres de los productos/servicios
                      final servicesStr =
                          cita.productos?.keys
                              .map((p) => p.nombre)
                              .join(', ') ??
                          'Servicio(s) Desconocido(s)';

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
                              Text(
                                'Estado: ${cita.status}',
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
                              Text(
                                'Fecha: ${listFormatter.format(cita.fecha)} ${cita.hora}',
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

// Extensión de ayuda para buscar en listas (Necesaria para firstWhereOrNull)
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
