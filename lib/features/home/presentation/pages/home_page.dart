import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 560;

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
                      const _SectionLabel(
                        title: '오늘의 시작',
                        subtitle: '가볍게 확인하고 바로 다음 행동으로 넘어갈 수 있도록 정리했습니다.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _AttendanceEntryCard(),
                      const SizedBox(height: AppSpacing.xl),
                      const _SectionLabel(
                        title: '주요 공간',
                        subtitle: '아직은 최소 골격만 연결하고, 다음 단계에서 각 기능을 채워 넣습니다.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DestinationGrid(isWide: isWide),
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
          Text(
            '안녕하세요,\n오늘의 흐름을 여기서 시작해볼까요?',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '출석체크와 주요 공간 진입을 한 화면에 가볍게 모은 홈 초안입니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
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
                Text('출석체크', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '오늘의 출석 상태와 보상 영역으로 이어질 카드 자리입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: const [
                    _StatusChip(label: '오늘 진입 포인트'),
                    _StatusChip(label: '보드 연결 예정'),
                    _StatusChip(label: 'RPC 연동 전'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationGrid extends StatelessWidget {
  const _DestinationGrid({
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _DestinationItem(
        title: '기억섬',
        description: '멤버와 사진, 관계 흐름을 정리할 공간입니다.',
        icon: Icons.landscape_outlined,
      ),
      _DestinationItem(
        title: '캘린더',
        description: '일정과 기록 흐름을 확인하는 달력 공간입니다.',
        icon: Icons.calendar_month_outlined,
      ),
      _DestinationItem(
        title: '상점',
        description: '획득한 자산과 교환 흐름을 담을 예정입니다.',
        icon: Icons.storefront_outlined,
      ),
      _DestinationItem(
        title: '마이페이지',
        description: '프로필, 공지, 문의 등 개인 설정의 시작점입니다.',
        icon: Icons.person_outline,
      ),
    ];

    if (!isWide) {
      return Column(
        children: [
          for (final item in items) ...[
            _DestinationCard(item: item),
            if (item != items.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final item in items)
          SizedBox(
            width: 356,
            child: _DestinationCard(item: item),
          ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.item,
  });

  final _DestinationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(item.icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(item.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          const _StatusChip(label: 'placeholder'),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _DestinationItem {
  const _DestinationItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
