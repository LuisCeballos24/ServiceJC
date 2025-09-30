// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.elevatedButtonForeground,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.cardTitle,
      ),
      iconTheme: IconThemeData(color: AppColors.cardTitle),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.elevatedButton,
        foregroundColor: AppColors.elevatedButtonForeground,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: AppTextStyles.elevatedButton,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.floatingButton,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.secondary,
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: AppColors.softWhite,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.h1,
      bodyMedium: AppTextStyles.h2,
    ),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: AppColors.secondary,
    ),
    snackBarTheme: lightTheme.snackBarTheme.copyWith(
      contentTextStyle: lightTheme.snackBarTheme.contentTextStyle!.copyWith(
        color: AppColors.secondary,
      ),
    )
  );
}
