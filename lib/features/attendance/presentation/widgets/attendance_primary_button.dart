import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';

class AttendancePrimaryButton extends StatelessWidget {
  const AttendancePrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = AppColors.b02,
    this.textColor = AppColors.white,
    this.height = 56,
    this.borderRadius = 18,
  });

  final String text;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          text,
          style: AppFont.h6_18.copyWith(color: textColor),
        ),
      ),
    );
  }
}
