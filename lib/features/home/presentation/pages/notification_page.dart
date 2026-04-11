import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/home/data/home_models.dart';
import 'package:uyoung_app/features/home/data/home_repository.dart';
import 'package:uyoung_app/features/home/data/home_service.dart';
import 'package:uyoung_app/features/home/presentation/viewmodels/notification_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          NotificationViewModel(const HomeRepository(HomeService()))..load(),
      child: const _NotificationPageView(),
    );
  }
}

class _NotificationPageView extends StatelessWidget {
  const _NotificationPageView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();

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
        title: AppHeadlineText('알림', style: AppFont.h3_24),
        actions: [
          IconButton(
            onPressed: viewModel.hasUnread && !viewModel.isMarkingAll
                ? viewModel.markAllAsRead
                : null,
            icon: SvgPicture.asset(
              AssetPaths.icons.common.setting,
              width: 35,
              height: 35,
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
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
                  style: AppFont.b6_18.copyWith(color: AppColors.subRed03),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                _NotificationFilterBar(
                  selected: viewModel.filter,
                  onSelected: viewModel.setFilter,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '표시할 알림이 없어요.',
                      style: AppFont.b6_18.copyWith(color: AppColors.g03),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              _NotificationFilterBar(
                selected: viewModel.filter,
                onSelected: viewModel.setFilter,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  itemCount: viewModel.notifications.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = viewModel.notifications[index];
                    return _NotificationCard(
                      item: item,
                      timeAgo: viewModel.formatTimeAgo(item.createdAt),
                      onTap: () => viewModel.markAsRead(item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _FilterChip(
            label: '전체',
            selected: selected == NotificationFilter.all,
            onTap: () => onSelected(NotificationFilter.all),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: '초대',
            selected: selected == NotificationFilter.invite,
            onTap: () => onSelected(NotificationFilter.invite),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: '활동',
            selected: selected == NotificationFilter.activity,
            onTap: () => onSelected(NotificationFilter.activity),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: '공지',
            selected: selected == NotificationFilter.notice,
            onTap: () => onSelected(NotificationFilter.notice),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.b03 : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.b02 : AppColors.bg02,
          ),
        ),
        child: Text(
          label,
          style: AppFont.b6_18.copyWith(
            color: selected ? AppColors.b01 : AppColors.g02,
          ),
        ),
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
    final bodyStyle = AppFont.b6_18.copyWith(
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
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.g04,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(item.type),
                    color: AppColors.black,
                    size: 26,
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
            const SizedBox(width: 18),
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
                          style: AppFont.h3_24.copyWith(color: AppColors.black),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeAgo,
                        style: AppFont.b6_18.copyWith(color: AppColors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
