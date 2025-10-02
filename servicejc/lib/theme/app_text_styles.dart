import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Títulos de secciones principales (Ej: Logo)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  // Títulos de secciones secundarias (Ej: Servicios Destacados)
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors
        .primary, // Corregido el color a primary para buen contraste en el fondo blanco
  );

  // Subtítulos y enlaces de navegación (Ej: Contacto)
  static const TextStyle h3 = TextStyle(
    fontSize: 18, // Aumentado ligeramente para los enlaces de navegación
    color: AppColors.softWhite,
    fontWeight: FontWeight.w500,
  );

  // Títulos de tarjetas/servicios
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Título de la sección principal (Hero Section) - PROPIEDAD AGREGADA
  static const TextStyle heroTitle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // -- Componentes de Lista --
  static const TextStyle listTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.cardTitle,
  );

  static const TextStyle listSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.cardSubtitle,
  );

  // -- Botones --
  // Estilo base para el texto dentro de los botones
  static const TextStyle button = TextStyle(
    // PROPIEDAD AGREGADA
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.elevatedButtonForeground,
  );

  // Estilo específico de botón que ya tenías
  static const TextStyle elevatedButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.elevatedButtonForeground,
  );

  // -- Modal / AlertDialog --
  static const TextStyle modalTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.cardTitle,
  );

  static const TextStyle modalButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.elevatedButtonForeground,
  );

  // -- Texto General --
  // Estilo que faltaba
  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: AppColors.secondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.secondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.secondary,
  );
}
