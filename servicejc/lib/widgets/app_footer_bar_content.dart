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
          // 🔹 Título centrado con imagen/icono
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                const Icon(
                  Icons.build_circle_rounded,
                  color: AppColors.accent,
                  size: 40,
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/logojcservicios.png', 
                  cacheWidth: 300,
                  height: 40, 
                  fit: BoxFit.contain, 
                ),
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
                detail: 'Jcpublicaciones2829@hotmail.com ',
                onTap: () {
                  launchUrl(
                    Uri.parse('mailto:Jcpublicaciones2829@hotmail.com'),
                  );
                },
              ),
              _infoSection(
                icon: Icons.phone,
                title: 'Llámanos',
                detail: '+507 6742-3563',
                onTap: () {
                  launchUrl(Uri.parse('tel:+50767423563'));
                },
              ),
              
              // --- AQUÍ ESTÁ EL CAMBIO PARA EL MAPA ---
              _infoSection(
                icon: Icons.location_on_outlined,
                title: 'Visítanos',
                detail: 'Panamá, Panamá, Caimitillo, Praderas de San Lorenzo',
                onTap: () async {
                  // Codificamos la dirección para URL
                  final String googleMapsUrl = 
                      'https://maps.app.goo.gl/mtFGT87tMFa9BaV98';
                  
                  final Uri url = Uri.parse(googleMapsUrl);
                  
                  // Intentamos abrir en modo aplicación externa (App de Mapas)
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                     // Si falla, intentamos abrir en navegador
                     await launchUrl(url);
                  }
                },
              ),
              // ----------------------------------------
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
                  _socialIcon(
                    FontAwesomeIcons.facebook,
                    'https://facebook.com/servicejc',
                  ),
                  _socialIcon(
                    FontAwesomeIcons.instagram,
                    'https://instagram.com/servicejc',
                  ),
                  _socialIcon(
                    FontAwesomeIcons.twitter,
                    'https://x.com/servicejc',
                  ),
                  _socialIcon(
                    FontAwesomeIcons.linkedin,
                    'https://linkedin.com/company/servicejc',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 🔹 Derechos reservados
          Text(
            '© ${DateTime.now().year} ServiciosJC. Todos los derechos reservados.',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔸 Sección de información de contacto
  // Agregamos un MouseRegion para que el cursor cambie a "manito" al pasar por encima
  Widget _infoSection({
    required IconData icon,
    required String title,
    required String detail,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.h2.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Íconos sociales
  Widget _socialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click, 
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(url)),
          child: FaIcon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}