import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/inquiries_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/notices_page.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/my_page_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class MyPagePage extends StatelessWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyPageViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      )..load(),
      child: const _MyPageView(),
    );
  }
}

class _MyPageView extends StatelessWidget {
  const _MyPageView();

  static const String _appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0+1');

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyPageViewModel>();
    final profile = viewModel.profile;
    final theme = Theme.of(context);

    return AppScaffold(
      title: '마이페이지',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileAvatar(size: 72),
                const SizedBox(height: AppSpacing.md),
                if (viewModel.isLoading)
                  const _LoadingTextGroup()
                else ...[
                  Text(profile.nickname, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'user_code ${profile.userCode}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    viewModel.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFBE123C),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1C2),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_outlined,
                    color: Color(0xFF9A6700),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('진주', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        viewModel.isLoading
                            ? '불러오는 중...'
                            : '${profile.pearlCount}개',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: '공지사항',
                  subtitle: '공지 목록으로 이동할 준비가 된 진입 메뉴',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NoticesPage(),
                      ),
                    );
                  },
                ),
                const _MenuDivider(),
                const _MenuTile(
                  icon: Icons.people_outline_rounded,
                  title: '친구',
                  subtitle: '친구 목록과 관계 기능으로 이어질 진입 메뉴',
                ),
                const _MenuDivider(),
                _MenuTile(
                  icon: Icons.support_agent_outlined,
                  title: '문의 내역',
                  subtitle: '문의 목록과 작성 흐름으로 이어질 진입 메뉴',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const InquiriesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('버전 정보', style: theme.textTheme.labelLarge),
                Text(
                  'v$_appVersion',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final profileImageUrl =
        context.select<MyPageViewModel, String?>((vm) => vm.profile.profileImageUrl);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: profileImageUrl != null && profileImageUrl.isNotEmpty
          ? Image.network(
              profileImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _AvatarFallback(),
            )
          : const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_rounded,
      color: AppColors.primary,
      size: 32,
    );
  }
}

class _LoadingTextGroup extends StatelessWidget {
  const _LoadingTextGroup();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE4FF),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 88,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECFA),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title 기능은 다음 단계에서 연결됩니다.'),
              ),
            );
          },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: AppColors.border,
    );
  }
}
