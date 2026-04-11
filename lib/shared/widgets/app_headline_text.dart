import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_typography.dart';

class AppHeadlineText extends StatelessWidget {
  const AppHeadlineText(
    this.text, {
    super.key,
    required this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.strokeWidth = 0.2,
  });

  final String text;
  final TextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double strokeWidth;

  factory AppHeadlineText.h0(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h0_34,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h1(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h1_28,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h2(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h2_26,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h3(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h3_24,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h4(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h4_22,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h5(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h5_20,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h6(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool height130 = false,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: height130 ? AppTypography.h6_18_130 : AppTypography.h6_18,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h7(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h7_16,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppHeadlineText.h8(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppHeadlineText(
      text,
      key: key,
      style: AppTypography.h8_14,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? style.color ?? AppColors.textPrimary;
    final fillStyle = style.copyWith(
      color: resolvedColor,
      fontWeight: FontWeight.w400,
    );

    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: fillStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = resolvedColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: fillStyle,
        ),
      ],
    );
  }
}
