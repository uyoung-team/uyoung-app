import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/attendance/data/attendance_models.dart';
import 'package:uyoung_app/features/attendance/presentation/pages/attendance_board_page.dart';
import 'package:uyoung_app/features/attendance/presentation/pages/attendance_result_page.dart';
import 'package:uyoung_app/features/attendance/presentation/viewmodels/attendance_view_model.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_entry_step.dart';
import 'package:uyoung_app/features/attendance/presentation/widgets/attendance_reveal_step.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late final AttendanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendanceViewModel();
    _viewModel.loadBoardData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      builder: (context, child) {
        final viewModel = context.watch<AttendanceViewModel>();
        final mediaQuery = MediaQuery.of(context);
        final size = mediaQuery.size;
        final safeTop = mediaQuery.padding.top;
        final safeBottom = mediaQuery.padding.bottom;
        const horizontalPadding = 16.0;
        const boxSpacing = 2.0;
        final boxWidth =
            ((size.width - (horizontalPadding * 2) - (boxSpacing * 6)) / 7)
                .clamp(39.0, 44.0);
        final boxHeight = (boxWidth * 1.52).clamp(58.0, 66.0);
        final iconSize = (boxWidth * 0.46).clamp(18.0, 22.0);
        final boardTop = safeTop + 50;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AssetPaths.images.attendance.background01,
                  fit: BoxFit.cover,
                ),
              ),
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
              Positioned(
                top: safeTop + 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '출석체크',
                    style: AppFont.h4_22.copyWith(color: AppColors.black),
                  ),
                ),
              ),
              if (viewModel.isRevealStep)
                AttendanceRevealStep(
                  onClamTap: () {
                    viewModel.showResult();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceResultPage(viewModel: _viewModel),
                      ),
                    );
                  },
                  top: boardTop,
                  safeBottom: safeBottom,
                )
              else
                AttendanceEntryStep(
                  onCheckTap: () => _handleCheckIn(context),
                  top: boardTop,
                  safeBottom: safeBottom,
                  horizontalPadding: horizontalPadding,
                  boxSpacing: boxSpacing,
                  boxWidth: boxWidth,
                  boxHeight: boxHeight,
                  iconSize: iconSize,
                  viewModel: viewModel,
                ),
              if (viewModel.errorMessage != null)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: safeBottom + 84,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
                    ),
                  ),
                ),
              if (viewModel.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final viewModel = context.read<AttendanceViewModel>();
    final nextStep = await viewModel.checkIn();

    if (!context.mounted) {
      return;
    }

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      return;
    }

    if (nextStep == AttendanceFlowStep.board && viewModel.isAlreadyChecked) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceBoardPage(viewModel: _viewModel),
        ),
      );
    }
  }
}
