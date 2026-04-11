import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';

class AppFont {
  const AppFont._();

  static const String fontFamily = 'OwnglyphKonghae';

  static TextStyle get b1_28 => _regular(28);
  static TextStyle get b1_28_120 => _regular(28, height: 1.2);
  static TextStyle get b2_26 => _regular(26);
  static TextStyle get b2_26_120 => _regular(26, height: 1.2);
  static TextStyle get b3_24 => _regular(24);
  static TextStyle get b4_22 => _regular(22);
  static TextStyle get b5_20 => _regular(20);
  static TextStyle get b5_20_120 => _regular(20, height: 1.2);
  static TextStyle get b6_18 => _regular(18);
  static TextStyle get b7_16 => _regular(16);
  static TextStyle get b8_14 => _regular(14);
  static TextStyle get b9_12 => _regular(12);
  static TextStyle get b10_10 => _regular(10);

  // Headline tokens define size/line-height only.
  // Actual bold appearance is rendered with AppHeadlineText.
  static TextStyle get h0_34 => _headline(34);
  static TextStyle get h1_28 => _headline(28);
  static TextStyle get h2_26 => _headline(26);
  static TextStyle get h3_24 => _headline(24);
  static TextStyle get h4_22 => _headline(22);
  static TextStyle get h5_20 => _headline(20);
  static TextStyle get h6_18 => _headline(18);
  static TextStyle get h6_18_130 => _headline(18, height: 1.3);
  static TextStyle get h7_16 => _headline(16);
  static TextStyle get h8_14 => _headline(14);
  static TextStyle get h9_12 => _headline(12);
  static TextStyle get h10_10 => _headline(10);

  static TextTheme get textTheme => TextTheme(
        displayLarge: h0_34,
        displayMedium: h1_28,
        displaySmall: h2_26,
        headlineLarge: h3_24,
        headlineMedium: h4_22,
        headlineSmall: h5_20,
        titleLarge: h6_18,
        titleMedium: h7_16,
        titleSmall: h8_14,
        bodyLarge: b7_16,
        bodyMedium: b8_14.copyWith(color: AppColors.textSecondary),
        bodySmall: b9_12.copyWith(color: AppColors.textSecondary),
        labelLarge: b8_14,
        labelMedium: b9_12,
        labelSmall: b10_10,
      );

  static TextStyle _regular(double size, {double? height}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: height,
    );
  }

  static TextStyle _headline(double size, {double? height}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: height,
    );
  }
}
