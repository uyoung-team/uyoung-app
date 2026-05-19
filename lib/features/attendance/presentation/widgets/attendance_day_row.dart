import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/attendance/presentation/viewmodels/attendance_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class AttendanceDayRow extends StatelessWidget {
  const AttendanceDayRow({
    super.key,
    required this.horizontalPadding,
    required this.boxSpacing,
    required this.boxWidth,
    required this.boxHeight,
    required this.iconSize,
    required this.viewModel,
    required this.onCheckTap,
  });

  final double horizontalPadding;
  final double boxSpacing;
  final double boxWidth;
  final double boxHeight;
  final double iconSize;
  final AttendanceViewModel viewModel;
  final VoidCallback onCheckTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          final day = index + 1;
          final isReceived = day <= viewModel.checkedDays;
          final isToday = day == viewModel.currentDay;
          final isFuture =
              day >
              (viewModel.hasCheckedToday
                  ? viewModel.checkedDays
                  : viewModel.currentDay);
          final imagePath = isReceived
              ? viewModel.entryBoardItemPath(day)
              : AssetPaths.images.attendance.itemSecret;

          return Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : boxSpacing),
            child: GestureDetector(
              onTap: isToday && !viewModel.isLoading ? onCheckTap : null,
              child: Opacity(
                opacity: isFuture ? 0.45 : 1.0,
                child: Container(
                  width: boxWidth,
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday ? AppColors.subYellow01 : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isToday
                        ? const [
                            BoxShadow(
                              color: AppColors.subYellow04,
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePath,
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: boxHeight < 62 ? 2 : 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$day일차',
                          style: AppFont.b10_10.copyWith(color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
