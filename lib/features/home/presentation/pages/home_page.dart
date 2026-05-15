import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/app/routes/app_router.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/home/data/home_repository.dart';
import 'package:uyoung_app/features/home/data/home_service.dart';
import 'package:uyoung_app/features/home/presentation/pages/notification_page.dart';
import 'package:uyoung_app/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/pearl_charge_page.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(const HomeRepository(HomeService()))..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 390).clamp(0.92, 1.15);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AssetPaths.images.home.background,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned(
                left: 18 * scale,
                top: 57 * scale,
                child: _PearlBox(
                  scale: scale,
                  pearlCountLabel: viewModel.pearlCount.toString(),
                ),
              ),
              Positioned(
                top: 53 * scale,
                right: 20 * scale,
                child: _NotificationButton(
                  scale: scale,
                  hasUnread: viewModel.hasUnread,
                  onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationPage(),
                    ),
                  );
                    await viewModel.load();
                  },
                ),
              ),
              Positioned(
                left: 18 * scale,
                top: 106 * scale,
                child: _AttendanceShortcut(
                  scale: scale,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRouter.attendance);
                    await viewModel.load();
                  },
                ),
              ),
              Positioned(
                left: ((width - (199 * scale)) / 2).clamp(0.0, width),
                top: 326 * scale,
                child: Image.asset(
                  AssetPaths.images.home.character,
                  width: 199 * scale,
                  height: 218 * scale,
                  fit: BoxFit.contain,
                ),
              ),
              if (viewModel.errorText != null)
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      viewModel.errorText!,
                      style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PearlBox extends StatelessWidget {
  const _PearlBox({required this.scale, required this.pearlCountLabel});

  final double scale;
  final String pearlCountLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const PearlChargePage(),
          ),
        );
      },
      child: SizedBox(
        width: 82 * scale,
        height: 36 * scale,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetPaths.images.home.myPearl,
                fit: BoxFit.fill,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 14 * scale),
                  child: Text(
                    pearlCountLabel,
                    style: AppFont.h4_22.copyWith(
                      color: AppColors.black,
                      fontSize: 22 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.scale,
    required this.hasUnread,
    required this.onTap,
  });

  final double scale;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            AssetPaths.icons.common.notification01,
            width: 44 * scale,
            height: 44 * scale,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 1 * scale,
              right: -2 * scale,
              child: const _UnreadDot(),
            ),
        ],
      ),
    );
  }
}

class _AttendanceShortcut extends StatelessWidget {
  const _AttendanceShortcut({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        width: 72 * scale,
        height: 75 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 56 * scale,
                height: 56 * scale,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(0, -2 * scale),
                  child: Image.asset(
                    AssetPaths.images.home.iconAttend,
                    width: 32 * scale,
                    height: 37 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 1 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.b02,
                  borderRadius: BorderRadius.circular(11 * scale),
                ),
                child: Text(
                  '출석체크',
                  style: AppFont.b7_16.copyWith(
                    color: AppColors.white,
                    fontSize: 16 * scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.subRed03,
        shape: BoxShape.circle,
      ),
    );
  }
}
