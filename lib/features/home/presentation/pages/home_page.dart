import 'package:flutter/material.dart';
import 'package:uyoung_app/app/routes/app_router.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.back,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HomeHeaderSection(),
                      const SizedBox(height: AppSpacing.lg),
                      const _AttendanceEntryCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeaderSection extends StatelessWidget {
  const _HomeHeaderSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4B6BFB),
            Color(0xFF6A86FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              'HOME',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppHeadlineText(
            '안녕하세요,\n오늘의 흐름을 여기서 시작해볼까요?',
            style: AppFont.h4_22,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '오늘 필요한 흐름부터 바로 이어갈 수 있도록 홈을 정리했습니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceEntryCard extends StatelessWidget {
  const _AttendanceEntryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      backgroundColor: const Color(0xFFFDF6E9),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AppRouter.attendance),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1A8),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF8B5E00),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeadlineText('출석체크', style: AppFont.h6_18),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '오늘의 출석 상태와 보상 영역으로 이어질 카드 자리입니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.g02,
            ),
          ],
        ),
      ),
    );
  }
}
