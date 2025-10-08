import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/admin_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final AdminApiService _apiService = AdminApiService();
  late Future<List<UserModel>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  void _fetchClients() {
    setState(() {
      _clientsFuture = _apiService.getClients();
    });
  }

  void _editClient(UserModel client) {
    // Lógica para editar el cliente
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Editar cliente: ${client.nombre}')));
  }

  void _deleteClient(UserModel client) async {
    try {
      await _apiService.deleteUser(client.id!);
      _fetchClients();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente ${client.nombre} eliminado.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Clientes',
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
        child: FutureBuilder<List<UserModel>>(
          future: _clientsFuture,
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
                  'No hay clientes registrados.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.softWhite,
                  ),
                ),
              );
            } else {
              final clients = snapshot.data!;
              return ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    color: AppColors.secondary,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      title: Text(
                        client.nombre,
                        style: AppTextStyles.listTitle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      subtitle: Text(
                        client.correo,
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
                              color: AppColors.elevatedButton,
                            ),
                            onPressed: () => _editClient(client),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.danger,
                            ),
                            onPressed: () => _deleteClient(client),
                          ),
                        ],
                      ),
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
