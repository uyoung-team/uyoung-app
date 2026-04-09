import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/inquiries_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class InquiriesPage extends StatelessWidget {
  const InquiriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InquiriesViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      )..load(),
      child: const _InquiriesView(),
    );
  }
}

class _InquiriesView extends StatelessWidget {
  const _InquiriesView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InquiriesViewModel>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: '문의 내역',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Text(
              '문의 접수 기능은 제외하고, 최신순 문의 내역 조회만 먼저 연결했습니다.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (viewModel.isLoading)
            const AppSurfaceCard(
              child: Text('문의 내역을 불러오는 중입니다.'),
            )
          else if (viewModel.items.isEmpty)
            AppSurfaceCard(
              child: Text(
                '표시할 문의 내역이 없습니다.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...viewModel.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _InquiryTile(item: item),
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

class _InquiryTile extends StatelessWidget {
  const _InquiryTile({
    required this.item,
  });

  final InquiryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.title, style: theme.textTheme.labelLarge),
              ),
              _StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.createdAt?.toLocal().toString() ?? '',
            style: theme.textTheme.bodyMedium,
          ),
          if (item.answer != null && item.answer!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(item.answer!, style: theme.textTheme.bodyMedium),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isDone = normalized.contains('done') ||
        normalized.contains('complete') ||
        normalized.contains('answered') ||
        normalized.contains('답변');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFE8F7EE) : const Color(0xFFFFF1C2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? '대기중' : status,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isDone ? const Color(0xFF166534) : const Color(0xFF9A6700),
            ),
      ),
    );
  }
}
