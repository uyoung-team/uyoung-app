import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

class CalendarMemoryIslandSettingsPage extends StatelessWidget {
  const CalendarMemoryIslandSettingsPage({
    super.key,
    required this.islandId,
  });

  final String islandId;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();
    final island = viewModel.islandFilters.firstWhere(
      (item) => item.id == islandId,
      orElse: () => const CalendarIslandFilter(
        id: '',
        name: '기억섬',
        color: AppColors.b02,
        isSelected: true,
        alertEnabled: true,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kAppTopBarHorizontalPadding,
                8,
                kAppTopBarHorizontalPadding,
                5,
              ),
              child: Row(
                children: [
                  AppTopBarIconButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      size: kAppTopBarIconVisualSize,
                      color: AppColors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '기억섬 관리',
                    style: AppFont.b5_20.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: kAppTopBarIconButtonSize,
                    height: kAppTopBarIconButtonSize,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.g04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      island.name,
                      style: AppFont.b6_18.copyWith(color: AppColors.g01),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: island.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.rotate(
                    angle: 3.141592,
                    child: SvgPicture.asset(
                      AssetPaths.icons.common.previous,
                      width: 14,
                      height: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 10, color: AppColors.g05),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                '알림 설정',
                style: AppFont.b9_12.copyWith(color: const Color(0xFF707070)),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Text(
                    '알림',
                    style: AppFont.b7_16.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: island.alertEnabled,
                      onChanged: (value) {
                        context.read<CalendarViewModel>().toggleAlert(
                              island.id,
                              value,
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
