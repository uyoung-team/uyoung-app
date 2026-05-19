import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/add_friend_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/friend_profile_page.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/friends_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendsViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      )..load(),
      child: const _FriendsView(),
    );
  }
}

class _FriendsView extends StatelessWidget {
  const _FriendsView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FriendsViewModel>();
    return AppScaffold(
      title: '친구',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeadlineText('친구 목록', style: AppFont.h6_18),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'friends와 profiles를 기준으로 친구 목록의 최소 구조를 먼저 연결했습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddFriendPage(),
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    await context.read<FriendsViewModel>().load();
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('코드로 친구 추가'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (viewModel.isLoading)
            const _FriendsLoadingCard()
          else if (viewModel.friends.isEmpty)
            const _FriendsEmptyCard()
          else
            ...viewModel.friends.map(
              (friend) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _FriendListTile(
                  friend: friend,
                ),
              ),
            ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFBE123C),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend});

  final FriendItem friend;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final didDelete = await Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => FriendProfilePage(friend: friend),
          ),
        );
        if (didDelete == true && context.mounted) {
          await context.read<FriendsViewModel>().load();
        }
      },
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEFF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeadlineText(friend.nickname, style: AppFont.h8_14),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'user_code ${friend.userCode}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.g02,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsLoadingCard extends StatelessWidget {
  const _FriendsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const AppSurfaceCard(
      child: Text('친구 목록을 불러오는 중입니다.'),
    );
  }
}

class _FriendsEmptyCard extends StatelessWidget {
  const _FriendsEmptyCard();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeadlineText('아직 친구가 없습니다.', style: AppFont.h6_18),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '코드로 친구를 찾아 처음 연결을 시작해보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
