import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class FriendProfilePage extends StatelessWidget {
  const FriendProfilePage({
    super.key,
    required this.friend,
    MyPageRepository? repository,
  }) : _repository = repository ?? const MyPageRepository(MyPageService());

  final FriendItem friend;
  final MyPageRepository _repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.back,
      appBar: AppBar(
        backgroundColor: AppColors.back,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 28),
            SizedBox(
              height: 250,
              child: Center(
                child: SizedBox(
                  width: 210,
                  height: 210,
                  child: _Avatar(avatarUrl: friend.profileImageUrl),
                ),
              ),
            ),
            AppHeadlineText(friend.nickname, style: AppFont.h4_22),
            const SizedBox(height: 8),
            Text(
              friend.userCode,
              style: AppFont.b8_14.copyWith(color: AppColors.g02),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 134,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('놀러가기 기능은 다음 단계에서 연결할게요.')),
                    );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.b02,
                  foregroundColor: AppColors.white,
                ),
                child: Text(
                  '놀러가기',
                  style: AppFont.b7_16.copyWith(color: AppColors.white),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 34),
              child: TextButton(
                onPressed: () => _deleteFriend(context),
                child: Text(
                  '친구 삭제하기',
                  style: AppFont.b8_14.copyWith(color: AppColors.g02),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteFriend(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '친구를 삭제할까요?',
            style: AppFont.b6_18.copyWith(color: AppColors.black),
          ),
          content: Text(
            '삭제 후에도 다시 친구 추가할 수 있어요.',
            style: AppFont.b8_14.copyWith(color: AppColors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                '취소',
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                '삭제',
                style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await _repository.deleteFriend(friend.id);
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context, true);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = avatarUrl?.trim();
    if (_isNetworkUrl(trimmedUrl)) {
      return ClipOval(
        child: Image.network(
          trimmedUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  bool _isNetworkUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg02,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 84,
        color: AppColors.g02,
      ),
    );
  }
}
