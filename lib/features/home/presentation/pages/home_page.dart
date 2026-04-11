import 'package:flutter/material.dart';
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
      backgroundColor: AppColors.back,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.b03, AppColors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 82,
            left: 90,
            child: Image.asset(
              AssetPaths.images.character.character04,
              width: 211,
              height: 224,
              fit: BoxFit.contain,
            ),
          ),
          _PearlBox(
            pearlCountLabel: viewModel.pearlCountLabel,
          ),
          _NotificationButton(
            hasUnread: viewModel.hasUnread,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(viewModel: viewModel),
                ),
              );
              await viewModel.load();
            },
          ),
          _AttendanceBadge(
            onTap: () async {
              await Navigator.pushNamed(context, AppRouter.attendance);
              await viewModel.load();
            },
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
                  color: AppColors.white,
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
      ),
    );
  }
}

class _PearlBox extends StatelessWidget {
  const _PearlBox({
    required this.pearlCountLabel,
  });

  final String pearlCountLabel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 20,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('진주 충전 화면은 다음 단계에서 연결됩니다.')),
            );
        },
        child: Container(
          width: 90,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.bg02),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.subYellow,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                pearlCountLabel,
                style: AppFont.h8_14.copyWith(color: AppColors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.hasUnread,
    required this.onTap,
  });

  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 15,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: AppColors.black,
              ),
            ),
            if (hasUnread)
              const Positioned(
                top: -2,
                right: -4,
                child: _UnreadDot(),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      top: 106,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  AssetPaths.images.attendance.itemClam,
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.b02,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '출석 체크',
                  style: AppFont.b10_10.copyWith(color: AppColors.white),
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
        color: Color(0xFFFF4D4F),
        shape: BoxShape.circle,
      ),
    );
  }
}
