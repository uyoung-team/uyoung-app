import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/home/data/home_models.dart';
import 'package:uyoung_app/features/home/data/home_repository.dart';
import 'package:uyoung_app/features/home/data/home_service.dart';
import 'package:uyoung_app/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({
    super.key,
    this.viewModel,
  });

  final HomeViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<HomeViewModel>.value(
        value: viewModel!,
        child: const _NotificationPageView(),
      );
    }

    return ChangeNotifierProvider(
      create: (_) =>
          HomeViewModel(const HomeRepository(HomeService()))..load(),
      child: const _NotificationPageView(),
    );
  }
}

class _NotificationPageView extends StatelessWidget {
  const _NotificationPageView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.back,
      appBar: AppBar(
        backgroundColor: AppColors.back,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.black,
        ),
        title: AppHeadlineText('알림', style: AppFont.h4_22),
        actions: [
          IconButton(
            onPressed: viewModel.hasUnread && !viewModel.isMarkingAll
                ? viewModel.markAllAsRead
                : null,
            icon: const Icon(
              Icons.done_all_rounded,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorText != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  viewModel.errorText!,
                  style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return Center(
              child: Text(
                '표시할 알림이 없어요.',
                style: AppFont.h8_14.copyWith(color: AppColors.g03),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            itemCount: viewModel.notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = viewModel.notifications[index];
              return _NotificationCard(
                item: item,
                timeAgo: viewModel.formatTimeAgo(item.createdAt),
                onTap: () => viewModel.markAsRead(item.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.timeAgo,
    required this.onTap,
  });

  final HomeNotification item;
  final String timeAgo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppFont.b8_14.copyWith(
      color: AppColors.black,
      height: 1.45,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
        decoration: BoxDecoration(
          color: AppColors.g05,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.g04,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(item.type),
                    color: AppColors.black,
                    size: 22,
                  ),
                ),
                if (!item.isRead)
                  const Positioned(
                    top: -1,
                    right: -1,
                    child: _UnreadDot(),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.h7_16.copyWith(color: AppColors.black),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeAgo,
                        style: AppFont.h8_14.copyWith(color: AppColors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodyStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(HomeNotificationType type) {
    switch (type) {
      case HomeNotificationType.invite:
        return Icons.mail_outline_rounded;
      case HomeNotificationType.activity:
        return Icons.bolt_rounded;
      case HomeNotificationType.notice:
        return Icons.notifications_none_rounded;
      case HomeNotificationType.unknown:
        return Icons.notifications_rounded;
    }
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
