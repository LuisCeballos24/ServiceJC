import 'package:flutter/material.dart';
import 'package:servicejc/screens/loading_screen.dart';

class CoordinarCitaScreen extends StatefulWidget {
  const CoordinarCitaScreen({super.key});

  @override
  State<CoordinarCitaScreen> createState() => _CoordinarCitaScreenState();
}

class _CoordinarCitaScreenState extends State<CoordinarCitaScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(52, 152, 219, 1),
              onPrimary: Colors.white,
              onSurface: Color.fromRGBO(52, 73, 94, 1),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(52, 152, 219, 1),
              onPrimary: Colors.white,
              onSurface: Color.fromRGBO(52, 73, 94, 1),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Coordinar Cita',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Detalles de la cita',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(52, 73, 94, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiempo de mano de obra aproximado: 1 hora',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Selector de Fecha
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today, size: 24),
              label: Text(
                _selectedDate == null
                    ? 'Seleccionar Fecha'
                    : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(52, 152, 219, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Selector de Hora
            ElevatedButton.icon(
              onPressed: () => _selectTime(context),
              icon: const Icon(Icons.access_time_filled, size: 24),
              label: Text(
                _selectedTime == null
                    ? 'Seleccionar Hora'
                    : 'Hora: ${_selectedTime!.format(context)}',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(39, 174, 96, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const Spacer(),

            // Botón de Confirmación
            ElevatedButton(
              onPressed: _selectedDate != null && _selectedTime != null
                  ? () {
                      // Navega a la pantalla de carga para una transición más suave
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoadingScreen(),
                        ),
                      );
                    }
                  : null, // Deshabilitado si no se ha seleccionado fecha y hora
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(52, 73, 94, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Confirmar Cita',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
