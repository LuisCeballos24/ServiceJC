import 'package:flutter/material.dart';
import 'package:servicejc/theme/app_colors.dart';
import 'package:servicejc/theme/app_text_styles.dart';
import 'package:servicejc/screens/my_account_screen.dart';

class VipPromoCard extends StatelessWidget {
  const VipPromoCard({super.key});

  void _showVipDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '💎 Club ServiceJC VIP',
                style: AppTextStyles.h1.copyWith(fontSize: 26, color: AppColors.accent),
              ),
              const SizedBox(height: 10),
              Text(
                'Elige cómo quieres ganar y ahorrar con nosotros:',
                style: AppTextStyles.bodyText.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              // BENEFICIO 1: MEMBRESÍA
              _buildBenefitRow(
                icon: Icons.workspace_premium,
                title: 'Membresía Prime (\$14.99/mes)',
                description: 'Obtén 15% de descuento FIJO en todos los servicios, inspecciones ilimitadas y 2 mantenimientos de A/A gratis al año.',
              ),
              const SizedBox(height: 20),

              // BENEFICIO 2: AFILIADOS
              _buildBenefitRow(
                icon: Icons.people_alt,
                title: 'Gana \$15 por cada amigo',
                description: 'Comparte tu código único. Tu amigo recibe \$10 de descuento y tú ganas \$15 de saldo real para tus futuras reparaciones.',
              ),
              const SizedBox(height: 32),

              // BOTÓN DE ACCIÓN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyAccountScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Activar en Mi Cuenta',
                    style: AppTextStyles.button.copyWith(color: AppColors.primary, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.accent.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.accent, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyText.copyWith(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVipDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFF39C12)], // Dorado a Naranja
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NUEVO',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "¿Quieres reparaciones GRATIS?",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, height: 1.2),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Descubre nuestro plan Prime o gana \$15 por cada amigo que invites.",
                    style: TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.workspace_premium, size: 70, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}