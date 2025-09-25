import 'package:flutter/material.dart';
import '../services/admin_api_service.dart';
import '../models/tecnico.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminApiService _apiService = AdminApiService();
  late Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _apiService.getDashboardMetrics();
  }

  void _eliminarTecnico(String tecnicoId) async {
    try {
      await _apiService.eliminarTecnico(tecnicoId);
      // Actualiza el estado para reflejar el cambio
      setState(() {
        _metricsFuture = _apiService.getDashboardMetrics();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Técnico eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final metrics = snapshot.data!;
            final List<dynamic> tecnicosData = metrics['tecnicosMasDestacados'];
            final List<Tecnico> tecnicos = tecnicosData.map((data) => Tecnico.fromJson(data)).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Muestra las métricas
                  Card(
                    child: ListTile(
                      title: Text('Técnicos Activos'),
                      subtitle: Text('${metrics['tecnicosActivos']}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Citas Activas'),
                      subtitle: Text('${metrics['citasActivas']}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: Text('Ganancias Totales'),
                      subtitle: Text('P\u0024${metrics['totalGanancias']}'),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  Text('Técnicos Más Destacados', style: Theme.of(context).textTheme.headlineMedium),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tecnicos.length,
                    itemBuilder: (context, index) {
                      final tecnico = tecnicos[index];
                      return Card(
                        child: ListTile(
                          title: Text(tecnico.nombre),
                          subtitle: Text('Correo: ${tecnico.correo}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarTecnico(tecnico.correo),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}