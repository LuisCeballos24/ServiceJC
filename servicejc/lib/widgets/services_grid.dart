import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart';
import 'package:servicejc/widgets/service_style_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 16.0), // Más margen arriba/abajo
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
                    Navigator.pushNamed(context, '/all-services', arguments: items);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                        Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.accent),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20), // Alineado con el título
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9, // Ligeramente más alto que ancho para acomodar texto e ícono
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
    final style = ServiceStyleHelper.getStyle(item.nombre);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Bordes más redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5), // Sombra suave hacia abajo
          ),
        ],
      ),
      child: Material( // Usamos Material para el efecto de splash (onda) al tocar
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias, // Recorta el contenido al borde redondeado
        child: InkWell(
          onTap: () => onItemSelected(item),
          splashColor: AppColors.accent.withOpacity(0.3), // Color del splash
          highlightColor: AppColors.accent.withOpacity(0.1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Imagen de Fondo
              Image.asset(
                style['image'],
                fit: BoxFit.cover,
                cacheWidth: 300,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.secondary); // Fondo si falla
                },
              ),

              // 2. Degradado (Gradient overlay) para legibilidad
              // Más oscuro abajo para que el texto resalte, más claro arriba para ver la foto
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

              // 3. Contenido (Icono y Texto)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Todo hacia abajo
                  crossAxisAlignment: CrossAxisAlignment.start, // Alineado a la izquierda
                  children: [
                    // Icono flotante (opcional: arriba a la derecha o centrado)
                    // Aquí lo pondremos en una posición destacada pero sutil
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), // Fondo semitransparente
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent.withOpacity(0.6), width: 1.5),
                        ),
                        child: Icon(
                          style['icon'],
                          size: 24,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    
                    const Spacer(), // Empuja el texto hacia abajo

                    // Nombre del Servicio
                    Text(
                      item.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15, // Letra un poco más grande
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
                    // Línea decorativa o subtítulo "Ver más"
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
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