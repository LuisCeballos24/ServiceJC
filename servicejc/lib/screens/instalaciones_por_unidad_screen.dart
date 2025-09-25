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
    {'title': 'Electricidad', 'price': 25.00, 'isSelected': false},
    {'title': 'Plomeria', 'price': 25.00, 'isSelected': false},
    {'title': 'Instalaciones menores', 'price': 25.00, 'isSelected': false},
    {'title': 'Aire acondicionado (instalación y mantenimiento)', 'price': 25.00, 'isSelected': false},
    {'title': 'Pintores', 'price': 25.00, 'isSelected': false},
    {'title': 'Ebanistas', 'price': 25.00, 'isSelected': false},
    {'title': 'Soldadura', 'price': 25.00, 'isSelected': false},
    {'title': 'Aluminio y vidrio', 'price': 25.00, 'isSelected': false},
    {'title': 'Cielo raso', 'price': 25.00, 'isSelected': false},
    {'title': 'Instalaciones decorativas', 'price': 25.00, 'isSelected': false},
    {'title': 'Revestimientos de piso y paredes', 'price': 25.00, 'isSelected': false},
    {'title': 'Remodelaciones', 'price': 25.00, 'isSelected': false},
    {'title': 'Construcción', 'price': 25.00, 'isSelected': false},
    {'title': 'Mantenimientos preventivos', 'price': 25.00, 'isSelected': false},
    {'title': 'Limpieza de sillones', 'price': 25.00, 'isSelected': false},
    {'title': 'Limpieza de áreas', 'price': 25.00, 'isSelected': false},
    {'title': 'Chefs', 'price': 25.00, 'isSelected': false},
    {'title': 'Salonerros', 'price': 25.00, 'isSelected': false},
    {'title': 'Bartender', 'price': 25.00, 'isSelected': false},
    {'title': 'Decoraciones', 'price': 25.00, 'isSelected': false},
    {'title': 'Otros', 'price': 25.00, 'isSelected': false},
  ];

  final Map<String, Map<String, dynamic>> _iconosPorServicio = {
    'Electricidad': {'icon': Icons.power, 'color': Colors.amber[700]},
    'Plomeria': {'icon': Icons.plumbing, 'color': Colors.blue[600]},
    'Instalaciones menores': {'icon': Icons.handyman, 'color': Colors.brown[400]},
    'Aire acondicionado (instalación y mantenimiento)': {'icon': Icons.ac_unit, 'color': Colors.cyan[400]},
    'Pintores': {'icon': Icons.format_paint, 'color': Colors.pink[400]},
    'Ebanistas': {'icon': Icons.chair, 'color': Colors.brown[700]},
    'Soldadura': {'icon': Icons.engineering, 'color': Colors.grey[700]},
    'Aluminio y vidrio': {'icon': Icons.window, 'color': Colors.blueGrey[400]},
    'Cielo raso': {'icon': Icons.roofing, 'color': Colors.orange[400]},
    'Instalaciones decorativas': {'icon': Icons.design_services, 'color': Colors.purple[400]},
    'Revestimientos de piso y paredes': {'icon': Icons.layers, 'color': Colors.teal[400]},
    'Remodelaciones': {'icon': Icons.construction, 'color': Colors.red[400]},
    'Construcción': {'icon': Icons.apartment, 'color': Colors.green[400]},
    'Mantenimientos preventivos': {'icon': Icons.build_circle, 'color': Colors.lime[600]},
    'Limpieza de sillones': {'icon': Icons.cleaning_services, 'color': Colors.indigo[400]},
    'Limpieza de áreas': {'icon': Icons.wash, 'color': Colors.lightBlue[400]},
    'Chefs': {'icon': Icons.restaurant_menu, 'color': Colors.orange[700]},
    'Salonerros': {'icon': Icons.room_service, 'color': Colors.deepOrange[400]},
    'Bartender': {'icon': Icons.local_bar, 'color': Colors.lightGreen[600]},
    'Decoraciones': {'icon': Icons.cake, 'color': Colors.pink[300]},
    'Otros': {'icon': Icons.more_horiz, 'color': Colors.grey[500]},
  };

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
    final String titulo = servicio['title'];
    final Map<String, dynamic>? iconoData = _iconosPorServicio[titulo];

    final IconData? icon = iconoData != null ? iconoData['icon'] as IconData : Icons.help_outline;
    final Color? color = iconoData != null ? iconoData['color'] as Color : Colors.black;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: CheckboxListTile(
        title: Text(
          titulo,
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
          if (titulo == 'Otros' && newValue == true) {
            _showOtherServiceModal(servicio);
          }
          setState(() {
            servicio['isSelected'] = newValue!;
          });
        },
        secondary: Icon(
          icon,
          color: color,
          size: 30,
        ),
        activeColor: const Color.fromRGBO(39, 174, 96, 1),
      ),
    );
  }

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
                setState(() {
                  servicio['isSelected'] = false;
                });
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Servicio "Otros" especificado: ${controller.text}');
                Navigator.of(context).pop();
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