import 'package:flutter/material.dart';
import '../models/tecnico.dart';
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
  late Future<List<Tecnico>> _tecnicosFuture;

  @override
  void initState() {
    super.initState();
    _fetchTecnicos();
  }

  void _fetchTecnicos() {
    setState(() {
      _tecnicosFuture = _apiService.getDashboardMetrics().then((metrics) {
        final List<dynamic> tecnicosData = metrics['tecnicosMasDestacados'];
        return tecnicosData.map((data) => Tecnico.fromJson(data)).toList();
      });
    });
  }

  void _eliminarTecnico(String tecnicoId) async {
    try {
      await _apiService.eliminarTecnico(tecnicoId);
      _fetchTecnicos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Técnico eliminado'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void _agregarTecnico() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lógica para agregar técnico...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Técnicos'),
      ),
      body: FutureBuilder<List<Tecnico>>(
        future: _tecnicosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tecnico = snapshot.data![index];
                return Card(
                  color: AppColors.secondary,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(
                      tecnico.nombre,
                      style: AppTextStyles.listTitle,
                    ),
                    subtitle: Text(
                      tecnico.correo,
                      style: AppTextStyles.listSubtitle,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.error,
                      onPressed: () => _eliminarTecnico(tecnico.correo),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No hay técnicos registrados.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarTecnico,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
