import 'package:flutter/material.dart';
import 'package:servicejc/models/categoria_principal_model.dart'; // 💡 IMPORTAR MODELO DE CATEGORÍA PRINCIPAL
// El import de service_model.dart ya no es necesario aquí
// import 'package:servicejc/models/service_model.dart'; 

// Colores basados en el logo
const Color _secondaryColor = Color(0xFF2C2C2C);
const Color _accentColor = Color(0xFFFFD700);
const Color _primaryColor = Color(0xFF1976D2); // Asumiendo un color primario

// 💡 Nuevo mapa simplificado para las 6 categorías de alto nivel
const Map<String, dynamic> _highLevelServiceData = {
  'mantenimiento y reparaciones técnicas': {'icon': Icons.build_rounded, 'color': _primaryColor},
  'remodelación y construcción': {'icon': Icons.home_work_rounded, 'color': Color(0xFF37474F)},
  'acabados y revestimientos': {'icon': Icons.format_paint_rounded, 'color': Color(0xFFD32F2F)},
  'limpieza especializada y general': {'icon': Icons.cleaning_services_rounded, 'color': Color(0xFF4CAF50)},
  'servicios técnicos especializados': {'icon': Icons.airplanemode_on_rounded, 'color': Color(0xFF757575)},
  'servicios para eventos y logística': {'icon': Icons.celebration_rounded, 'color': Color(0xFFFFB300)},
};

// 💡 CLASE MODIFICADA: Ahora espera List<CategoriaPrincipalModel> y un callback
class ServicesGrid extends StatelessWidget {
  // 💡 YA NO ES UN FUTURE, ES LA LISTA YA CARGADA
  final List<CategoriaPrincipalModel> items; 
  
  // 💡 CALLBACK DE NAVEGACIÓN
  final void Function(CategoriaPrincipalModel) onItemSelected;
  
  final bool isLargeScreen;

  const ServicesGrid({
    super.key,
    required this.items, // 💡 Nuevo parámetro requerido
    required this.onItemSelected, // 💡 Nuevo parámetro requerido
    required this.isLargeScreen,
  });

  Map<String, dynamic> _getCategoryData(String categoryName) {
    return _highLevelServiceData[categoryName.toLowerCase()] ?? 
           {'icon': Icons.construction_rounded, 'color': Colors.grey};
  }

  @override
  Widget build(BuildContext context) {
    // Ya no usamos FutureBuilder porque la data viene en 'items'
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 4 : 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final categoria = items[index];
        // 💡 Usamos el nombre de la categoría para obtener los datos
        final data = _getCategoryData(categoria.nombre);

        return InkWell(
          onTap: () => onItemSelected(categoria), // 💡 Llama al callback de navegación
          child: Container(
            decoration: BoxDecoration(
              color: _secondaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data['icon'], color: data['color'], size: 40),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    categoria.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}