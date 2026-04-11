import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/attendance/data/attendance_repository.dart';
import 'package:uyoung_app/features/attendance/data/attendance_service.dart';
import 'package:uyoung_app/features/attendance/presentation/viewmodels/attendance_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel(
        const AttendanceRepository(
          AttendanceService(),
        ),
      )..load(),
      child: const _AttendanceView(),
    );
  }
}

class _AttendanceView extends StatelessWidget {
  const _AttendanceView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AttendanceViewModel>();
    final theme = Theme.of(context);
    return AppScaffold(
      title: '출석체크',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeadlineText('출석 구조 초안', style: AppFont.h6_18),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'RPC 호출과 attendance_logs 조회만 먼저 연결한 최소 구조입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeadlineText('오늘의 액션', style: AppFont.h6_18),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '지금은 daily_check_in_and_draw RPC 호출 결과를 확인하는 단계입니다.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: viewModel.isSubmitting
                      ? null
                      : () => viewModel.runCheckIn(),
                  child: Text(
                    viewModel.isSubmitting ? '처리 중...' : '출석체크 실행',
                  ),
                ),
                if (viewModel.lastResult != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    label: '최근 결과',
                    message: viewModel.lastResult!.summary,
                  ),
                ],
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _InlineNotice(
                    label: '오류',
                    message: viewModel.errorMessage!,
                    tone: _NoticeTone.error,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeadlineText('출석 로그', style: AppFont.h6_18),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'attendance_logs 조회 결과를 이후 보드 UI의 기반 데이터로 사용합니다.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                if (viewModel.isLoading)
                  const _LogSkeleton()
                else if (viewModel.logs.isEmpty)
                  const _EmptyLogs()
                else
                  ...viewModel.logs.map(
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _LogTile(
                        title: log.status,
                        subtitle: log.createdAt?.toLocal().toString() ??
                            'created_at 없음',
                      ),
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

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.label,
    required this.message,
    this.tone = _NoticeTone.normal,
  });

  final String label;
  final String message;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (tone) {
      _NoticeTone.normal => const Color(0xFFF5F7FB),
      _NoticeTone.error => const Color(0xFFFFF1F2),
    };

    final foregroundColor = switch (tone) {
      _NoticeTone.normal => AppColors.textPrimary,
      _NoticeTone.error => const Color(0xFFBE123C),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _LogSkeleton extends StatelessWidget {
  const _LogSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LogTile(
          title: 'loading...',
          subtitle: '출석 로그를 불러오는 중입니다.',
        ),
        SizedBox(height: AppSpacing.sm),
        _LogTile(
          title: 'loading...',
          subtitle: '보드 데이터 기반 구조를 준비하고 있습니다.',
        ),
      ],
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  const _EmptyLogs();

  @override
  Widget build(BuildContext context) {
    return Text(
      '아직 표시할 출석 로그가 없습니다.',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

enum _NoticeTone {
  normal,
  error,
}
