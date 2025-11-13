import 'package:flutter/material.dart';
import '../models/user_model.dart'; // Usar UserModel para los técnicos
import '../services/admin_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TecnicosScreen extends StatefulWidget {
  const TecnicosScreen({super.key});

  @override
  _TecnicosScreenState createState() => _TecnicosScreenState();
}

class _TecnicosScreenState extends State<TecnicosScreen> {
  final AdminApiService _apiService = AdminApiService();
  // Cambiamos el Future para esperar List<UserModel>
  late Future<List<UserModel>> _tecnicosFuture;

  @override
  void initState() {
    super.initState();
    _fetchTecnicos();
  }

  // Método actualizado para llamar directamente al endpoint de técnicos
  void _fetchTecnicos() {
    setState(() {
      _tecnicosFuture = _apiService.fetchTechnicians();
    });
  }

  // 1. Método para la edición (Diálogo)
  void _showEditTecnicoDialog(UserModel tecnico) {
    // Aquí puedes implementar campos para editar nombre, email, etc.
    final TextEditingController _nombreController = TextEditingController(
      text: tecnico.nombre,
    );
    final TextEditingController _emailController = TextEditingController(
      text: tecnico.correo,
    );
    final TextEditingController _telefonoController = TextEditingController(
      text: tecnico.telefono,
    );
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Técnico: ${tecnico.nombre}'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    !value!.contains('@') ? 'Email inválido' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value!.isEmpty ? 'El nombre no puede estar vacío' : null,
                keyboardType: TextInputType.phone,
              ),
              // NOTA: La edición del rol o contraseña debe ser manejada con cuidado
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
              if (_formKey.currentState!.validate()) {
                // Aquí deberías llamar al nuevo método _apiService.updateTecnico()
                // Asegúrate de que updateTecnico en Flutter acepte un UserModel

                // Usamos el ID original, que no debería ser nulo para un técnico existente (usamos !)
                await _apiService.updateTecnico(
                  UserModel(
                    id: tecnico.id!,
                    nombre: _nombreController.text,
                    correo: _emailController.text,
                    telefono: _telefonoController.text,

                    //     // Mantener el rol existente
                    rol: tecnico.rol ?? 'TECNICO',
                    //     // No actualizar contraseña a menos que se agregue un campo de contraseña aquí.
                  ),
                );
                _fetchTecnicos();
                if (mounted) Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Técnico editado (Simulado)')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // 2. Método para la eliminación
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
                  // Aseguramos que nombre y email se manejen de forma segura para la UI
                  final safeNombre = tecnico.nombre ?? 'Nombre Desconocido';
                  final safeEmail = tecnico.correo ?? 'email@desconocido.com';
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
                        tecnico.correo, // Usar el campo email de UserModel
                        style: AppTextStyles.listSubtitle.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
