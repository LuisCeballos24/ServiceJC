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
    // Definir cuántas columnas queremos dependiendo del ancho
    int crossAxisCount = isLargeScreen ? 4 : 2;
    
    // 🔴 CORRECCIÓN: Quitamos .take(8) para que muestre TODOS los servicios
    final displayItems = items; 

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nuestros Servicios",
                style: AppTextStyles.h2.copyWith(color: AppColors.cardTitle),
              ),
              // Ocultamos el botón "Ver todos" si ya estamos mostrando todos
              // o si prefieres dejarlo para navegar a otra vista, quita esta condición.
              if (items.length > displayItems.length) 
                TextButton(
                  onPressed: () {
                      Navigator.pushNamed(context, '/all-services', arguments: items);
                  },
                  child: const Text("Ver todos", style: TextStyle(color: AppColors.accent)),
                )
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Tarjetas cuadradas
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return _buildCard(context, item);
          },
        ),
      ],
    );
  }

  // --- MÉTODO CONSTRUCTOR DE TARJETA ---
  Widget _buildCard(BuildContext context, CategoriaPrincipalModel item) {
    
    final style = ServiceStyleHelper.getStyle(item.nombre);

    return InkWell(
      onTap: () => onItemSelected(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.secondary, 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(style['image']), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), 
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {
               // Esto evita que la app truene si falta una imagen, solo muestra el fondo oscuro
               debugPrint("⚠️ Imagen no encontrada: ${style['image']}");
            },
          ),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3), 
            width: 1
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: AppColors.accent.withOpacity(0.5)),
              ),
              child: Icon(
                style['icon'],
                size: 35,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w700, 
                  color: Colors.white,         
                  fontSize: 13,                
                  height: 1.1,
                  shadows: [
                    const Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}