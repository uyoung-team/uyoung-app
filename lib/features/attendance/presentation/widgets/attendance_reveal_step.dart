import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_primary_button.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_stage_layout.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class AttendanceRevealStep extends StatelessWidget {
  const AttendanceRevealStep({
    super.key,
    required this.onClamTap,
    required this.top,
    required this.safeBottom,
  });

  final VoidCallback onClamTap;
  final double top;
  final double safeBottom;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final objectTop = top + size.height * 0.2;

    return AttendanceStageLayout(
      top: objectTop,
      safeBottom: safeBottom,
      backgroundAssetPath: AssetPaths.images.attendance.background02,
      textTopSpacing: 230,
      object: Center(
        child: GestureDetector(
          onTap: onClamTap,
          child: Image.asset(
            AssetPaths.images.attendance.itemClam,
            width: 230,
            height: 230,
            fit: BoxFit.contain,
          ),
        ),
      ),
      text: Column(
        children: [
          AppHeadlineText(
            '어! 심해에서',
            style: AppFont.h3_24,
            color: AppColors.white,
          ),
          const SizedBox(height: 4),
          AppHeadlineText(
            '해달이 무언갈 주웠나봐요,',
            style: AppFont.h3_24,
            color: AppColors.white,
          ),
        ],
      ),
      action: AttendancePrimaryButton(
        text: '아이템 확인해보기',
        onTap: onClamTap,
      ),
    );
  }
}
