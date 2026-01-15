import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Asegúrate de importar tus colores si usas AppColors

class ServiceStyleHelper {
  
  // Ruta base para no repetirla
  static const String basePath = 'assets/images/services/'; 
  // Imagen por defecto si alguna falta (créala también, ej: logo gris)
  static const String defaultImage = '${basePath}default.png'; 

  static Map<String, dynamic> getStyle(String serviceName) {
    // Normalizamos el texto (minúsculas) para comparar fácil
    final name = serviceName.toLowerCase();

    // --- MANTENIMIENTO ---
    if (name.contains("aire acondicionado")) {
      return {'icon': Icons.ac_unit, 'image': '${basePath}aire_acondicionado.png'};
    } 
    if (name.contains("plomería") || name.contains("plomeria")) {
      return {'icon': Icons.plumbing, 'image': '${basePath}plomeria.png'};
    }
    if (name.contains("electricidad")) {
      return {'icon': Icons.bolt, 'image': '${basePath}electricidad.png'};
    }
    if (name.contains("soldadura")) {
      return {'icon': Icons.whatshot, 'image': '${basePath}soldadura.png'};
    }
    if (name.contains("filtraciones")) {
      return {'icon': Icons.water_damage, 'image': '${basePath}filtraciones.png'};
    }
    if (name.contains("sillones")) {
      return {'icon': Icons.chair, 'image': '${basePath}sillones.png'};
    }
    if (name.contains("vidrio") || name.contains("ventanas")) {
      return {'icon': Icons.window, 'image': '${basePath}ventanas.png'};
    }
    if (name.contains("canales")) {
      return {'icon': Icons.roofing, 'image': '${basePath}canales.png'};
    }
    if (name.contains("menores")) {
      return {'icon': Icons.handyman, 'image': '${basePath}instalaciones_menores.png'};
    }
    if (name.contains("preventivos")) {
      return {'icon': Icons.security, 'image': '${basePath}preventivos.png'};
    }

    // --- CONSTRUCCIÓN Y ACABADOS ---
    if (name.contains("construcción")) {
      return {'icon': Icons.foundation, 'image': '${basePath}construccion.png'};
    }
    if (name.contains("remodelaciones")) {
      return {'icon': Icons.home_work, 'image': '${basePath}remodelaciones.png'};
    }
    if (name.contains("repello")) {
      return {'icon': Icons.format_paint, 'image': '${basePath}repello.png'};
    }
    if (name.contains("pintura") || name.contains("pintores")) {
      return {'icon': Icons.brush, 'image': '${basePath}pintura.png'};
    }
    if (name.contains("cielo raso")) {
      return {'icon': Icons.grid_view, 'image': '${basePath}cieloraso.png'};
    }
    if (name.contains("revestimientos") || name.contains("pisos")) {
      return {'icon': Icons.layers, 'image': '${basePath}revestimientos.png'};
    }
    if (name.contains("ebanistas")) {
      return {'icon': Icons.handyman, 'image': '${basePath}ebanistas.png'};
    }
    if (name.contains("decorativas") || name.contains("decoradores")) {
      return {'icon': Icons.filter_vintage, 'image': '${basePath}decoracion.png'};
    }
    if (name.contains("aluminio")) {
      return {'icon': Icons.door_sliding, 'image': '${basePath}aluminio.png'};
    }

    // --- LIMPIEZA ---
    if (name.contains("limpieza general") || name.contains("limpieza de cocinas")) {
      return {'icon': Icons.cleaning_services, 'image': '${basePath}limpieza_general.png'};
    }
    
    // --- TECNOLOGÍA ---
    if (name.contains("dron")) {
      return {'icon': Icons.flight_takeoff, 'image': '${basePath}dron.png'};
    }
    if (name.contains("solares")) {
      return {'icon': Icons.solar_power, 'image': '${basePath}paneles.png'};
    }

    // --- EVENTOS ---
    if (name.contains("chef") || name.contains("cocina")) {
      return {'icon': Icons.restaurant_menu, 'image': '${basePath}chef.png'};
    }
    if (name.contains("bartender")) {
      return {'icon': Icons.local_bar, 'image': '${basePath}bartender.png'};
    }
    if (name.contains("saloneros")) {
      return {'icon': Icons.room_service, 'image': '${basePath}saloneros.png'};
    }
    if (name.contains("valet") || name.contains("conductor")) {
      return {'icon': Icons.directions_car, 'image': '${basePath}valet.png'};
    }
    if (name.contains("movilizacion")) {
      return {'icon': Icons.local_shipping, 'image': '${basePath}mudanza.png'};
    }

    // Por defecto si no coincide
    return {'icon': Icons.build_circle, 'image': defaultImage};
  }
}