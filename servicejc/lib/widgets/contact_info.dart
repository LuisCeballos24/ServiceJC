import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactInfo extends StatelessWidget {
  const ContactInfo({super.key});

  // Colores basados en el logo
  static const Color secondaryColor = Color(0xFF2C2C2C);
  static const Color accentColor = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contáctanos',
            style: TextStyle(
              color: accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone, 'Llámanos', '+507 6586-7788', 'tel:+50765867788'),
          const SizedBox(height: 12),
          _buildContactRow(Icons.email, 'Envíanos un correo', 'contacto@servicejc.com', 'mailto:contacto@servicejc.com'),
          const SizedBox(height: 12),
          _buildContactRow(Icons.location_on, 'Visítanos', 'Calle 50, Panamá, Panamá', null),
          const SizedBox(height: 24),
          const Text(
            'Síguenos en nuestras redes',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.facebook, color: accentColor),
                onPressed: () => _launchURL('https://facebook.com/servicejc'),
              ),
              IconButton(
                icon: const Icon(Icons.tiktok, color: accentColor),
                onPressed: () => _launchURL('https://tiktok.com/servicejc'),
              ),
              // IconButton(
              //   icon: const Icon(Icons.meta, color: accentColor),
              //   onPressed: () => _launchURL('https://youtube.com/servicejc'),
              // ),
              IconButton(
                icon: const Icon(Icons.mail, color: accentColor),
                onPressed: () => _launchURL('mailto:contacto@servicejc.com'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String value, String? url) {
    return InkWell(
      onTap: url != null ? () => _launchURL(url) : null,
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'No se pudo abrir $url';
    }
  }
}