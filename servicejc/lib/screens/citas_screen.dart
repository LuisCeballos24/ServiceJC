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

  void _showEditCitaDialog(CitaModel cita) {
    String? nuevoEstado = cita.status.toUpperCase();
    String? nuevoTecnicoId = cita.tecnicoId;

    final servicesStr =
        cita.productosSeleccionados?.map((p) => p.nombre).join(', ') ??
        'Servicios no listados: ${cita.descripcion}';

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
                // SOLUCIÓN: Crear el objeto completo con TODOS los campos originales
                // y solo modificar estado y técnico
                final CitaModel updatedCita = CitaModel(
                  id: cita.id,
                  userId: cita.userId,
                  tecnicoId: nuevoTecnicoId,
                  status: nuevoEstado!,
                  fecha: cita.fecha,
                  hora: cita.hora,
                  costoTotal: cita.costoTotal,
                  descripcion: cita.descripcion,
                  // INCLUIR solo los IDs (serviciosSeleccionados)
                  serviciosSeleccionados: cita.serviciosSeleccionados,
                  // CRÍTICO: Incluir productosSeleccionados si existe
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
