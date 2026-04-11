import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/notice_detail_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class NoticeDetailPage extends StatelessWidget {
  const NoticeDetailPage({
    super.key,
    required this.noticeId,
  });

  final String noticeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoticeDetailViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      )..load(noticeId),
      child: const _NoticeDetailView(),
    );
  }
}

class _NoticeDetailView extends StatelessWidget {
  const _NoticeDetailView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoticeDetailViewModel>();
    final notice = viewModel.notice;
    return AppScaffold(
      title: '공지사항 상세',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (viewModel.isLoading)
            const AppSurfaceCard(
              child: Text('공지사항을 불러오는 중입니다.'),
            )
          else if (notice == null)
            AppSurfaceCard(
              child: Text(
                viewModel.errorMessage ?? '공지사항을 찾을 수 없습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notice.isImportant) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1C2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '중요',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF9A6700),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppHeadlineText(
                    notice.title,
                    style: AppFont.h4_22,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    notice.createdAt?.toLocal().toString() ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    notice.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
