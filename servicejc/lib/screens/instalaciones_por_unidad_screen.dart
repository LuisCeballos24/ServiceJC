import 'package:flutter/material.dart';
import 'package:servicejc/screens/coordinar_cita_screen.dart';

class InstalacionesPorUnidadScreen extends StatefulWidget {
  const InstalacionesPorUnidadScreen({super.key});

  @override
  State<InstalacionesPorUnidadScreen> createState() =>
      _InstalacionesPorUnidadScreenState();
}

class _InstalacionesPorUnidadScreenState
    extends State<InstalacionesPorUnidadScreen> {
  final List<Map<String, dynamic>> _servicios = [
    {'title': 'Lámpara', 'price': 25.00, 'isSelected': false},
    {'title': 'Tomas', 'price': 25.00, 'isSelected': false},
    {'title': 'Interruptores', 'price': 25.00, 'isSelected': false},
    {'title': 'Breaker', 'price': 25.00, 'isSelected': false},
    {'title': 'Abanico', 'price': 25.00, 'isSelected': false},
    {'title': 'Otros', 'price': 25.00, 'isSelected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instalaciones por Unidad',
          style: TextStyle(
            color: Color.fromRGBO(52, 73, 94, 1),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(52, 73, 94, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _servicios.length,
              itemBuilder: (context, index) {
                return _buildServiceCheckbox(_servicios[index]);
              },
            ),
          ),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildServiceCheckbox(Map<String, dynamic> servicio) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(
          servicio['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'B/. ${servicio['price'].toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        value: servicio['isSelected'],
        onChanged: (bool? newValue) {
          if (servicio['title'] == 'Otros' && newValue == true) {
            // Si "Otros" se selecciona, mostramos el modal
            _showOtherServiceModal(servicio);
          }
          setState(() {
            servicio['isSelected'] = newValue!;
          });
        },
        activeColor: const Color.fromRGBO(39, 174, 96, 1), // Color verde
      ),
    );
  }

  // Nueva función para mostrar el modal
  void _showOtherServiceModal(Map<String, dynamic> servicio) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Especificar Servicio'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ej: instalación de una caja de fusibles',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Si el usuario cancela, deseleccionamos el checkbox
                setState(() {
                  servicio['isSelected'] = false;
                });
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes guardar el texto ingresado por el usuario
                // Por ahora, solo lo imprimimos en la consola
                print('Servicio "Otros" especificado: ${controller.text}');
                Navigator.of(context).pop();
                // El checkbox ya está seleccionado
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalSummary() {
    final selectedCount = _servicios.where((s) => s['isSelected']).length;
    final buttonText = selectedCount > 0
        ? 'Solicitar Servicio ($selectedCount)'
        : 'Solicitar Servicio';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: selectedCount > 0
            ? () {
                // Navegación a la pantalla de coordinación de cita
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoordinarCitaScreen(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(buttonText, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
