import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
// Importación necesaria para el modelo de la cita
import '../models/cita_model.dart';

class TecnicosScreen extends StatefulWidget {
  const TecnicosScreen({super.key});

  @override
  _TecnicosScreenState createState() => _TecnicosScreenState();
}

class _TecnicosScreenState extends State<TecnicosScreen> {
  final AdminApiService _apiService = AdminApiService();
  late Future<List<UserModel>> _tecnicosFuture;

  @override
  void initState() {
    super.initState();
    _fetchTecnicos();
  }

  void _fetchTecnicos() {
    setState(() {
      _tecnicosFuture = _apiService.fetchTechnicians();
    });
  }

  // 1. Método para la edición (Diálogo) - Sin cambios
  void _showEditTecnicoDialog(UserModel tecnico) {
    final TextEditingController nombreController = TextEditingController(
      text: tecnico.nombre,
    );
    final TextEditingController emailController = TextEditingController(
      text: tecnico.correo,
    );
    final TextEditingController telefonoController = TextEditingController(
      text: tecnico.telefono,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Técnico: ${tecnico.nombre}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    !value!.contains('@') ? 'Email inválido' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _apiService.updateTecnico(
                  UserModel(
                    id: tecnico.id!,
                    nombre: nombreController.text,
                    correo: emailController.text,
                    telefono: telefonoController.text,
                    rol: tecnico.rol ?? 'TECNICO',
                  ),
                );
                _fetchTecnicos();
                if (mounted) Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Técnico editado exitosamente.'),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // MÉTODO CORREGIDO: 3. Método para la Asignación de Cita (Simulada)
  void _showAssignCitaDialog(UserModel tecnico) {
    const String dummyCitaId = 'Cita-Pendiente-7890';
    final DateTime oneHourLater = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asignar Cita (Demo) a ${tecnico.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignar cita $dummyCitaId al técnico ${tecnico.nombre} con el estado "ASIGNADA" para la hora simulada:',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha/Hora: ${oneHourLater.toString().substring(0, 16)}',
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '\nEsto simula la llamada al endpoint de actualización de cita (PUT /api/citas/{id})',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Se han añadido los campos obligatorios que faltaban: userId, costoTotal y descripcion.
                // También se corrige el tipo de fecha (DateTime) y hora (String) según el modelo.
                final CitaModel updatedCita = CitaModel(
                  id: dummyCitaId,
                  tecnicoId: tecnico.id,

                  // CAMPOS REQUERIDOS AÑADIDOS
                  userId: 'ADMIN_ASIGNACION',
                  status:
                      'ASIGNADA', // Usar 'status' (el modelo usa 'status', el backend espera 'estado')
                  costoTotal: 0.0, // Valor dummy
                  descripcion:
                      'Cita reasignada por el administrador', // Valor dummy
                  // TIPOS CORREGIDOS
                  fecha: oneHourLater, // Se requiere DateTime
                  hora:
                      '${oneHourLater.hour.toString().padLeft(2, '0')}:${oneHourLater.minute.toString().padLeft(2, '0')}', // Se requiere String (HH:mm)
                );

                // Llamada al API que usa PUT /api/citas/{id}
                await _apiService.updateCita(updatedCita);

                if (mounted) Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cita $dummyCitaId asignada a ${tecnico.nombre} con éxito.',
                    ),
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al asignar la cita: $e',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  // 2. Método para la eliminación - Sin cambios
  void _confirmDeleteTecnico(String tecnicoId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarTecnico(tecnicoId, nombre);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _eliminarTecnico(String tecnicoId, String nombre) async {
    try {
      await _apiService.eliminarTecnico(tecnicoId);
      _fetchTecnicos(); // Recargar la lista
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$nombre eliminado con éxito.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al eliminar a $nombre: $e',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Técnicos',
          style: AppTextStyles.h2.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.accent),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTecnicos,
          ),
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
        // CAMBIO CLAVE: Cambiar el tipo de Future a List<UserModel>
        child: FutureBuilder<List<UserModel>>(
          future: _tecnicosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar técnicos: ${snapshot.error}',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.softWhite,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final tecnicos = snapshot.data!;
              if (tecnicos.isEmpty) {
                return Center(
                  child: Text(
                    'No hay técnicos registrados.',
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.softWhite,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: tecnicos.length,
                itemBuilder: (context, index) {
                  final tecnico = tecnicos[index];
                  // Aseguramos que nombre, email e id se manejen de forma segura para la UI
                  final safeNombre = tecnico.nombre ?? 'Nombre Desconocido';
                  final safeId =
                      tecnico.id ?? 'ERROR_ID'; // El ID debería existir
                  return Card(
                    color: AppColors.secondary,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Text(
                          tecnico.nombre[0].toUpperCase(),
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        tecnico.nombre,
                        style: AppTextStyles.listTitle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      subtitle: Text(
                        tecnico.correo ??
                            'email@desconocido.com', // Usar el campo email de UserModel
                        style: AppTextStyles.listSubtitle.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      // MODIFICADO: Añadir el botón de asignar cita
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // NUEVO: Botón para asignar cita
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: AppColors.success,
                            ),
                            onPressed: () => _showAssignCitaDialog(tecnico),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.iconButton,
                            ),
                            onPressed: () => _showEditTecnicoDialog(tecnico),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.danger,
                            ),
                            onPressed: () =>
                                _confirmDeleteTecnico(safeId, safeNombre),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'No hay técnicos registrados.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.softWhite,
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar diálogo para añadir nuevo técnico
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lógica para agregar técnico pendiente.'),
            ),
          );
        },
        backgroundColor: AppColors.floatingButton,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
