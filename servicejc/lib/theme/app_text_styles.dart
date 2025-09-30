// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    color: AppColors.softWhite,
  );

  // ListTile / Cards
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

  // Botones
  static const TextStyle elevatedButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.elevatedButtonForeground,
  );

  // Modal / AlertDialog
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

  static const TextStyle body = TextStyle(
    fontSize: 16
  );
  static const TextStyle caption = TextStyle(
    fontSize: 14
  );
}
