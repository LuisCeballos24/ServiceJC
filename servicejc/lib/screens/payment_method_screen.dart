// En lib/screens/payment_method_screen.dart

import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona un método para pagar:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Opción para Yappy
            ElevatedButton(
              onPressed: () {
                // Lógica para la pasarela de Yappy
                // Aquí iría el código para iniciar el proceso de pago con la API de Yappy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirigiendo a Yappy...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF285C9F), // Color de Yappy
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Pagar con Yappy', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            // Opción para BAC Credomatic
            ElevatedButton(
              onPressed: () {
                // Lógica para la pasarela de BAC Credomatic
                // Aquí iría el código para iniciar el proceso de pago con la pasarela de BAC
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Redirigiendo a BAC Credomatic...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31B23), // Color de BAC
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Pagar con Tarjeta (BAC)', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}