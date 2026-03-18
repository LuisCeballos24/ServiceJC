import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/widgets/service_style_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServicesGrid extends StatelessWidget {
  final List<CategoriaPrincipalModel> items;
  final Function(CategoriaPrincipalModel) onItemSelected;
  final bool isLargeScreen;

  const ServicesGrid({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Definir cuántas columnas queremos dependiendo del ancho.
    // En pantallas grandes 4, en móviles 2 suele ser el estándar cómodo.
    int crossAxisCount = isLargeScreen ? 4 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20.0,
            10.0,
            20.0,
            16.0,
          ), // Más margen arriba/abajo
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Nuestros Servicios",
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.cardTitle,
                  fontWeight: FontWeight.bold,
                  fontSize: 24, // Un poco más grande para destacar
                ),
              ),
              // Botón "Ver todos" más discreto y elegante
              if (items.length > 8) // Ejemplo: mostrar solo si hay muchos
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/all-services',
                      arguments: items,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "Ver todos",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ), // Alineado con el título
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.9, // Ligeramente más alto que ancho para acomodar texto e ícono
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildCard(context, item);
          },
        ),
        const SizedBox(height: 40), // Espacio final
      ],
    );
  }

  // --- MÉTODO CONSTRUCTOR DE TARJETA MEJORADO ---
  Widget _buildCard(BuildContext context, CategoriaPrincipalModel item) {
    // Ya no necesitamos ServiceStyleHelper
    // final style = ServiceStyleHelper.getStyle(item.nombre);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onItemSelected(item),
          splashColor: AppColors.accent.withOpacity(0.3),
          highlightColor: AppColors.accent.withOpacity(0.1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🔥 1. IMAGEN DESDE FIREBASE STORAGE CON CACHÉ
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.secondary,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.secondary,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                )
              else
                Container(
                  color: AppColors.secondary,
                ), // Fondo por defecto si no hay URL
              // 2. Degradado (Gradient overlay)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // 3. Contenido (Texto)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del Servicio
                    Text(
                      item.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.7),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
