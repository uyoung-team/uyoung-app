import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.b01,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.black,
        outline: AppColors.bg02,
      ),
      scaffoldBackgroundColor: AppColors.back,
      dividerColor: AppColors.bg02,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      disabledColor: AppColors.g04,
      textTheme: AppFont.textTheme,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.bg02),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.back,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
    );
  }
}
