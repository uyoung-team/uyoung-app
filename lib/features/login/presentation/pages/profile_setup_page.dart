import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/core/theme/app_spacing.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/main_tab_shell.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => const MyPageRepository(MyPageService()),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView();

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final TextEditingController _nicknameController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _currentProfileImageUrl;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadInitialProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeadlineText('프로필 설정', style: AppFont.h3_24),
                    const SizedBox(height: 10),
                    Text(
                      '처음 시작하기 전에 사용할 닉네임을 입력해주세요.',
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                    const SizedBox(height: 36),
                    _ProfileImageSection(
                      selectedImageBytes: _selectedImageBytes,
                      currentImageUrl: _currentProfileImageUrl,
                      isSaving: _isSaving,
                      onPickImage: _pickProfileImage,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '닉네임',
                      style: AppFont.b8_14.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nicknameController,
                      maxLength: 12,
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력해주세요.',
                        hintStyle: AppFont.b7_16.copyWith(color: AppColors.g03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.bg02),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.bg02),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.b02,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    Text(
                      '프로필 이미지는 나중에 다시 바꿀 수 있어요.',
                      textAlign: TextAlign.center,
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed:
                            _isSaving || _nicknameController.text.trim().isEmpty
                            ? null
                            : _save,
                        child: Text(_isSaving ? '저장 중...' : '저장하고 시작하기'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _loadInitialProfile() async {
    final repository = context.read<MyPageRepository>();
    try {
      final profile = await repository.fetchMyPageProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _nicknameController.text = profile.nickname == '사용자'
            ? ''
            : profile.nickname;
        _currentProfileImageUrl = profile.profileImageUrl;
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null || !mounted) {
      return;
    }

    final bytes = await pickedImage.readAsBytes();
    setState(() {
      _selectedImage = pickedImage;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    final repository = context.read<MyPageRepository>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      await repository.updateProfile(
        nickname: _nicknameController.text,
        profileImageUrl: _currentProfileImageUrl,
        selectedImage: _selectedImage,
        resetPearlsIfFirstSetup: true,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const MainTabShell(),
        ),
        (_) => false,
      );
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

class _ProfileImageSection extends StatelessWidget {
  const _ProfileImageSection({
    required this.selectedImageBytes,
    required this.currentImageUrl,
    required this.isSaving,
    required this.onPickImage,
  });

  final Uint8List? selectedImageBytes;
  final String? currentImageUrl;
  final bool isSaving;
  final Future<void> Function() onPickImage;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = currentImageUrl?.trim();
    final ImageProvider<Object>? imageProvider = selectedImageBytes != null
        ? MemoryImage(selectedImageBytes!)
        : (trimmedUrl != null && trimmedUrl.isNotEmpty
              ? NetworkImage(trimmedUrl)
              : null);

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFE6EEF8),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(
                    Icons.person_outline_rounded,
                    size: 38,
                    color: AppColors.g02,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isSaving ? null : onPickImage,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD9E2EC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(
              '갤러리에서 사진 선택',
              style: AppFont.b8_14.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
