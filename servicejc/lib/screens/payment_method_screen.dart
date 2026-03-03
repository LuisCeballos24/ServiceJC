import 'package:flutter/material.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:servicejc/screens/payment_screen.dart'; // Asegúrate de tener este archivo también

class PaymentMethodScreen extends StatelessWidget {
  final String citaId;
  final double totalAmount;

  const PaymentMethodScreen({
    super.key,
    required this.citaId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Método de Pago',
          style: AppTextStyles.h2.copyWith(color: AppColors.cardTitle),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cardTitle),
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
            Text(
              'Total a pagar: \$${totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Selecciona una opción:',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.cardTitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- BOTÓN YAPPY ---
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Integración de Yappy próximamente...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.elevatedButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Pagar con Yappy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 24),

            // --- BOTÓN TARJETA (CUBO) ---
            ElevatedButton(
              onPressed: () {
                // Navegamos a la pantalla de Cubo (PaymentScreen)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      citaId: citaId,
                      totalAmount: totalAmount,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Pagar con Tarjeta (Visa/MC)', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}