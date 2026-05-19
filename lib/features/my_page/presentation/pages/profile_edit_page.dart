import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/app_surface_card.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({
    super.key,
    required this.initialProfile,
  });

  final MyPageProfile initialProfile;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => const MyPageRepository(MyPageService()),
      child: _ProfileEditView(initialProfile: initialProfile),
    );
  }
}

class _ProfileEditView extends StatefulWidget {
  const _ProfileEditView({required this.initialProfile});

  final MyPageProfile initialProfile;

  @override
  State<_ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<_ProfileEditView> {
  late final TextEditingController _nicknameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.initialProfile.nickname,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '프로필 수정',
      body: Container(
        color: AppColors.back,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeadlineText('닉네임', style: AppFont.h6_18),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _nicknameController,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      hintText: '닉네임을 입력해주세요.',
                      border: OutlineInputBorder(),
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
                  Text(
                    '초대 코드',
                    style: AppFont.b7_16.copyWith(color: AppColors.g02),
                  ),
                  const SizedBox(height: 6),
                  AppHeadlineText(
                    widget.initialProfile.userCode,
                    style: AppFont.h6_18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? '저장 중...' : '저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final repository = context.read<MyPageRepository>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      await repository.updateProfile(nickname: _nicknameController.text);
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('프로필을 저장했어요.')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
