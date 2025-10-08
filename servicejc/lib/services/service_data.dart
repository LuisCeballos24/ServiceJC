import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ServiceData {
  static final Map<String, Map<String, dynamic>> _serviceData = {
    'Electricidad': {'icon': Icons.power_rounded, 'color': AppColors.accent},
    'Plomeria': {
      'icon': Icons.plumbing_rounded,
      'color': AppColors.elevatedButton,
    },
    'Instalaciones menores': {
      'icon': Icons.handyman_rounded,
      'color': Colors.brown,
    },
    'Aire acondicionado (instalación y mantenimiento)': {
      'icon': Icons.ac_unit_rounded,
      'color': Colors.cyan,
    },
    'Pintores': {'icon': Icons.format_paint_rounded, 'color': Colors.pink},
    'Ebanistas': {'icon': Icons.chair_rounded, 'color': Colors.brown[700]},
    'Soldadura': {'icon': Icons.engineering_rounded, 'color': Colors.grey},
    'Aluminio y vidrio': {
      'icon': Icons.window_rounded,
      'color': Colors.blueGrey,
    },
    'Cielo raso': {'icon': Icons.roofing_rounded, 'color': Colors.orange},
    'Instalaciones decorativas': {
      'icon': Icons.design_services_rounded,
      'color': Colors.purple,
    },
    'Revestimientos de piso y paredes': {
      'icon': Icons.layers_rounded,
      'color': Colors.teal,
    },
    'Remodelaciones': {'icon': Icons.construction_rounded, 'color': Colors.red},
    'Construcción': {'icon': Icons.apartment_rounded, 'color': Colors.green},
    'Mantenimientos preventivos': {
      'icon': Icons.build_circle_rounded,
      'color': Colors.lime,
    },
    'Limpieza de sillones': {
      'icon': Icons.cleaning_services_rounded,
      'color': Colors.indigo,
    },
    'Limpieza de áreas': {
      'icon': Icons.wash_rounded,
      'color': Colors.lightBlue,
    },
    'Chefs': {'icon': Icons.restaurant_menu_rounded, 'color': Colors.orange},
    'Salonerros': {
      'icon': Icons.room_service_rounded,
      'color': Colors.deepOrange,
    },
    'Bartender': {'icon': Icons.local_bar_rounded, 'color': Colors.lightGreen},
    'Decoraciones': {'icon': Icons.cake_rounded, 'color': Colors.pink},
    'Otros': {'icon': Icons.more_horiz_rounded, 'color': Colors.grey},
  };

  static Map<String, dynamic> getServiceData(String serviceName) {
    return _serviceData[serviceName] ??
        {'icon': Icons.help_outline, 'color': Colors.grey};
  }
}
