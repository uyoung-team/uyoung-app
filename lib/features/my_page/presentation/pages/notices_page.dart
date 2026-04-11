import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/notice_detail_page.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/notices_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoticesViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      )..load(),
      child: const _NoticesView(),
    );
  }
}

class _NoticesView extends StatelessWidget {
  const _NoticesView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoticesViewModel>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: '공지사항',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Text(
              '중요 공지가 먼저 보이도록 정렬된 공지 목록입니다.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (viewModel.isLoading)
            const AppSurfaceCard(
              child: Text('공지사항을 불러오는 중입니다.'),
            )
          else if (viewModel.items.isEmpty)
            AppSurfaceCard(
              child: Text(
                '표시할 공지사항이 없습니다.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...viewModel.items.map(
              (notice) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _NoticeTile(notice: notice),
              ),
            ),
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
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({
    required this.notice,
  });

  final dynamic notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NoticeDetailPage(noticeId: notice.id as String),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (notice.isImportant == true) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1C2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '중요',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF9A6700),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      notice.title as String,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                notice.createdAt?.toLocal().toString() ?? '',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
