import 'package:flutter/material.dart';
import '../models/tecnico.dart';
import '../services/admin_api_service.dart';

class TecnicosScreen extends StatefulWidget {
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
    // Aquí puedes crear un nuevo endpoint en tu API para listar todos los técnicos,
    // o reutilizar el de 'tecnicosMasDestacados' si esa es la lista que necesitas.
    // Asumamos que creaste uno nuevo en tu servicio de Java.
    // Por ahora, usaremos el que ya tenemos del dashboard.
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
      _fetchTecnicos(); // Recarga la lista después de la eliminación
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Técnico eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _agregarTecnico() {
    // Aquí navegarías a una nueva pantalla o mostrarías un diálogo
    // con un formulario para agregar un técnico.
    // Ejemplo:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AgregarTecnicoScreen()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lógica para agregar técnico...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Técnicos'),
      ),
      body: FutureBuilder<List<Tecnico>>(
        future: _tecnicosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tecnico = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(tecnico.nombre),
                    subtitle: Text(tecnico.correo),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarTecnico(tecnico.correo),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No hay técnicos registrados.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarTecnico,
        child: Icon(Icons.person_add),
      ),
    );
  }
}