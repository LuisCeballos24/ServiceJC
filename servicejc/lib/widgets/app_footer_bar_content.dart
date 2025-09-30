import 'package:flutter/material.dart';

// Estilos centralizados
import '../theme/app_text_styles.dart';

class AppFooterBarContent extends StatelessWidget {
  const AppFooterBarContent({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text('© 2024 ServiceJC. Todos los derechos reservados.',
        style: AppTextStyles.h3,
        textAlign: TextAlign.center
      )
    );
  }
}