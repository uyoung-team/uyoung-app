import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/attendance/presentation/pages/attendance_board_page.dart';
import 'package:uyoung_app/features/attendance/presentation/viewmodels/attendance_view_model.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_primary_button.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_stage_layout.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class AttendanceResultPage extends StatelessWidget {
  const AttendanceResultPage({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _AttendanceResultView(),
    );
  }
}

class _AttendanceResultView extends StatelessWidget {
  const _AttendanceResultView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final safeBottom = mediaQuery.padding.bottom;
    final objectTop = mediaQuery.padding.top + size.height * 0.15;

    return Scaffold(
      body: AttendanceStageLayout(
        top: objectTop,
        safeBottom: safeBottom,
        backgroundAssetPath: AssetPaths.images.attendance.background02,
        textTopSpacing: 330,
        actionHorizontalPadding: 28,
        object: Column(
          children: [
            Image.asset(
              viewModel.rewardImagePath,
              width: 320,
              height: 320,
              fit: BoxFit.contain,
            ),
          ],
        ),
        text: Column(
          children: [
            AppHeadlineText(
              viewModel.resultTitle,
              style: AppFont.h3_24,
              color: AppColors.white,
            ),
            const SizedBox(height: 14),
            Text(
              viewModel.resultBody,
              style: AppFont.h8_14.copyWith(
                color: AppColors.white,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        action: Row(
          children: [
            Expanded(
              child: AttendancePrimaryButton(
                text: '출석 확인하기',
                backgroundColor: AppColors.white,
                textColor: AppColors.b02,
                height: 54,
                onTap: () {
                  viewModel.showBoard();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceBoardPage(viewModel: viewModel),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AttendancePrimaryButton(
                text: '홈으로 가기',
                backgroundColor: AppColors.white,
                textColor: AppColors.b02,
                height: 54,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
