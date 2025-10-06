import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Estilos centralizados
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFooterBarContent extends StatelessWidget {
  const AppFooterBarContent({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Título centrado con icono
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Mantiene centrado el contenido del botón
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.build_circle_rounded,
                  color: AppColors.accent,
                  size: 40,
                ),
                const SizedBox(width: 8),
                Text('ServiceJC', style: AppTextStyles.h1),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔹 Información general (en filas adaptables)
          Wrap(
            spacing: 60,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _infoSection(
                icon: Icons.email_outlined,
                title: 'Envíanos un correo',
                detail: 'contacto@servicejc.com',
                onTap: () {
                  launchUrl(Uri.parse('mailto:contacto@servicejc.com'));
                },
              ),
              _infoSection(
                icon: Icons.phone,
                title: 'Llámanos',
                detail: '+507 6586-7788',
                onTap: () {
                  launchUrl(Uri.parse('tel:+50765867788'));
                },
              ),
              _infoSection(
                icon: Icons.location_on_outlined,
                title: 'Visítanos',
                detail: 'Calle 50, Panamá, Panamá',
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🔹 Redes sociales
          Column(
            children: [
              Text(
                'Síguenos en nuestras redes',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(FontAwesomeIcons.facebook, 'https://facebook.com/servicejc'),
                  _socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com/servicejc'),
                  _socialIcon(FontAwesomeIcons.twitter, 'https://x.com/servicejc'),
                  _socialIcon(FontAwesomeIcons.linkedin, 'https://linkedin.com/company/servicejc'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 🔹 Derechos reservados
          Text(
            '© ${DateTime.now().year} ServiceJC. Todos los derechos reservados.',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔸 Sección de información de contacto
  Widget _infoSection({
    required IconData icon,
    required String title,
    required String detail,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.h2.copyWith(color: Colors.white)
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔸 Íconos sociales
  Widget _socialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
      cursor: SystemMouseCursors.click, // 👈 cursor tipo pointer
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: FaIcon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    ),
    );
  }
}
