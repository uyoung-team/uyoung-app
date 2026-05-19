import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_radius.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/friends_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FriendsViewModel(
        const MyPageRepository(
          MyPageService(),
        ),
      ),
      child: const _AddFriendView(),
    );
  }
}

class _AddFriendView extends StatefulWidget {
  const _AddFriendView();

  @override
  State<_AddFriendView> createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<_AddFriendView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FriendsViewModel>();
    return AppScaffold(
      title: '친구 추가',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppSurfaceCard(
            backgroundColor: const Color(0xFFF4F7FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeadlineText('코드로 친구 찾기', style: AppFont.h6_18),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '친구 코드를 입력해 프로필을 확인하는 최소 흐름만 먼저 연결했습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: '친구 코드',
                    hintText: '예: UY1234',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => viewModel.clearSearch(),
                  onSubmitted: (value) => viewModel.searchByCode(value),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: viewModel.isSearching
                      ? null
                      : () => viewModel.searchByCode(_controller.text),
                  child: Text(
                    viewModel.isSearching ? '찾는 중...' : '코드 확인',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (viewModel.searchResult != null)
            _SearchResultCard(
              nickname: viewModel.searchResult!.nickname,
              userCode: viewModel.searchResult!.userCode,
              isSubmitting: viewModel.isSearching,
              onAdd: () async {
                final message = await context.read<FriendsViewModel>().addFoundUser();
                if (!context.mounted || message == null) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
                Navigator.pop(context, true);
              },
            )
          else
            const _SearchPlaceholderCard(),
          if (viewModel.searchMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              viewModel.searchMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.nickname,
    required this.userCode,
    required this.isSubmitting,
    required this.onAdd,
  });

  final String nickname;
  final String userCode;
  final bool isSubmitting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    AppHeadlineText(nickname, style: AppFont.h6_18),
                    const SizedBox(height: AppSpacing.xxs),
                    Text('user_code $userCode',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프로필을 확인했어요. 바로 친구로 추가할 수 있습니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSubmitting ? null : onAdd,
                    child: Text(isSubmitting ? '추가 중...' : '친구 추가'),
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

class _SearchPlaceholderCard extends StatelessWidget {
  const _SearchPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Text(
        '친구 코드를 입력하면 여기에서 프로필 확인 결과를 보여줍니다.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
