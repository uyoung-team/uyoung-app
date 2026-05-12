import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
    this.dotColors = const [],
    this.thumbnailPath,
    this.isCompactMode = false,
    this.compactWeeks = 6,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final List<Color> dotColors;
  final String? thumbnailPath;
  final bool isCompactMode;
  final int compactWeeks;

  @override
  Widget build(BuildContext context) {
    final baseTextColor = isOutside ? AppColors.g04 : AppColors.g01;

    final backgroundColor = isSelected ? AppColors.b01 : Colors.transparent;
    final dayTextColor = isSelected ? AppColors.white : baseTextColor;

    Widget buildDotRow() {
      if (dotColors.isEmpty) {
        return const SizedBox(height: 6);
      }

      if (dotColors.length <= 4) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final color in dotColors)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        );
      }

      final visibleDots = dotColors.take(2).toList();
      final remainingCount = dotColors.length - 2;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final color in visibleDots)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 4),
          Text(
            '+$remainingCount',
            style: AppFont.b10_10.copyWith(color: AppColors.g03),
          ),
        ],
      );
    }

    final isSixWeeks = compactWeeks >= 6;
    final compactDateBoxHeight = isSixWeeks ? 22.0 : 24.0;
    final compactGap = isSixWeeks ? 6.0 : 8.0;
    final compactBottomPadding = isSixWeeks ? 4.0 : 6.0;

    if (isCompactMode) {
      return Padding(
        padding: EdgeInsets.only(bottom: compactBottomPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: compactDateBoxHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${date.day}',
                style: AppFont.b7_16.copyWith(color: dayTextColor, height: 1),
              ),
            ),
            SizedBox(height: compactGap),
            buildDotRow(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${date.day}',
              style: AppFont.b7_16.copyWith(color: dayTextColor, height: 1),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              children: [
                if (thumbnailPath != null)
                  Transform.rotate(
                    angle: 12 * 3.141592 / 180,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(thumbnailPath!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.15),
                            BlendMode.srcATop,
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: thumbnailPath != null
                        ? Border.all(
                            color: const Color(0xFFE5E5E5),
                            width: 0.8,
                          )
                        : null,
                    color: thumbnailPath == null ? AppColors.white : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      thumbnailPath ?? AssetPaths.images.calendar.character,
                      fit: thumbnailPath != null ? BoxFit.cover : BoxFit.contain,
                      errorBuilder: (_, _, _) => Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          AssetPaths.icons.common.calendar,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          buildDotRow(),
        ],
      ),
    );
  }
}
