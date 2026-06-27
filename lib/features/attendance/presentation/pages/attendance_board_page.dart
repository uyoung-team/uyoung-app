import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/attendance/presentation/viewmodels/attendance_view_model.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_board_layout.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_primary_button.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

class AttendanceBoardPage extends StatelessWidget {
  const AttendanceBoardPage({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _AttendanceBoardView(),
    );
  }
}

class _AttendanceBoardView extends StatelessWidget {
  const _AttendanceBoardView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            top: safeTop + 8,
            left: 16,
            child: AppTopBarIconButton(
              onTap: () => Navigator.pop(context),
              child: SvgPicture.asset(
                  AssetPaths.icons.common.previous,
                  width: kAppTopBarIconVisualSize,
                  height: kAppTopBarIconVisualSize,
                ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                    child: Center(
                    child: Text(
                      '출석체크',
                      style: AppFont.h4_22.copyWith(color: AppColors.black),
                    ),
                  ),
                ),
                _AttendanceBoardHeader(viewModel: viewModel),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 230,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                    decoration: BoxDecoration(
                      color: AppColors.b03,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: AttendanceBoardLayout(viewModel: viewModel),
                  ),
                ),
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: safeBottom + 2,
                  child: AttendancePrimaryButton(
                    text: '홈으로 가기',
                    height: 58,
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBoardHeader extends StatelessWidget {
  const _AttendanceBoardHeader({required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 36,
      left: 20,
      right: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.boardItemSummary,
                    style: AppFont.h3_24.copyWith(
                      color: AppColors.black,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.boardSubSummary,
                    style: AppFont.h6_18.copyWith(color: AppColors.g02),
                  ),
                ],
              ),
            ),
          ),
          Image.asset(
            AssetPaths.images.attendance.itemTrashBundle,
            width: 156,
            height: 156,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
