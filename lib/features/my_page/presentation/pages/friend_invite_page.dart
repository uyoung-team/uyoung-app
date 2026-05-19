import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/add_friend_page.dart';
import 'package:uyoung_app/features/my_page/presentation/viewmodels/my_page_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class FriendInvitePage extends StatelessWidget {
  const FriendInvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          MyPageViewModel(const MyPageRepository(MyPageService()))..load(),
      child: const _FriendInviteView(),
    );
  }
}

class _FriendInviteView extends StatelessWidget {
  const _FriendInviteView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyPageViewModel>();

    return AppScaffold(
      title: '친구 초대',
      body: Container(
        color: AppColors.back,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          physics: const BouncingScrollPhysics(),
          children: [
            AppHeadlineText(
              '바다는 친구와 함께\n떠다닐 때 더 아름다워요.',
              style: AppFont.h2_26,
            ),
            const SizedBox(height: 10),
            Text(
              '초대 코드를 공유하거나 코드로 친구를 바로 추가할 수 있어요.',
              style: AppFont.b7_16.copyWith(color: AppColors.g02),
            ),
            const SizedBox(height: 28),
            AppSurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                children: [
                  Text(
                    '나의 초대 코드',
                    style: AppFont.b6_18.copyWith(color: AppColors.g02),
                  ),
                  const SizedBox(height: 14),
                  AppHeadlineText(viewModel.userCode, style: AppFont.h2_26),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InviteActionButton(
                    label: '초대코드 복사하기',
                    onTap: () => _copyInviteCode(context, viewModel.userCode),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _InviteActionButton(
                    label: '코드로 친구 추가',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddFriendPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _copyInviteCode(
    BuildContext context,
    String inviteCode,
  ) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('초대 코드가 복사되었어요.')));
  }
}

class _InviteActionButton extends StatelessWidget {
  const _InviteActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 73,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.b02,
          foregroundColor: AppColors.white,
          textStyle: AppFont.b6_18.copyWith(color: AppColors.white),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
