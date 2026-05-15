import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/login/presentation/pages/login_page.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/invite_island_view_model.dart';

class InviteIslandPage extends StatelessWidget {
  const InviteIslandPage({
    super.key,
    required this.inviteCode,
  });

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InviteIslandViewModel(
        inviteCode: inviteCode,
        repository: const MemoryRepository(MemoryService()),
      )..load(),
      child: const _InviteIslandView(),
    );
  }
}

class _InviteIslandView extends StatefulWidget {
  const _InviteIslandView();

  @override
  State<_InviteIslandView> createState() => _InviteIslandViewState();
}

class _InviteIslandViewState extends State<_InviteIslandView> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _waitingForLogin = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (!_waitingForLogin || data.session == null) {
        return;
      }

      _waitingForLogin = false;
      _handleJoin();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InviteIslandViewModel>();
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.black),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.detail == null
          ? _InviteErrorState(
              message: viewModel.errorMessage ?? '초대 정보를 불러오지 못했어요.',
            )
          : _InviteContent(detail: viewModel.detail!),
      bottomNavigationBar: viewModel.detail == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: SizedBox(
                height: 56,
                child: TextButton(
                  onPressed: viewModel.isJoining
                      ? null
                      : () {
                          if (isLoggedIn) {
                            _handleJoin();
                            return;
                          }

                          setState(() {
                            _waitingForLogin = true;
                          });
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.b02,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: viewModel.isJoining
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLoggedIn
                              ? '입장하기'
                              : _waitingForLogin
                              ? '로그인 대기 중'
                              : '로그인 후 입장하기',
                          style: AppFont.b6_18.copyWith(color: AppColors.white),
                        ),
                ),
              ),
            ),
    );
  }

  Future<void> _handleJoin() async {
    final viewModel = context.read<InviteIslandViewModel>();

    try {
      final detail = await viewModel.join();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기억섬에 입장했어요.')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MemoryDetailPage(item: detail.toIslandItem()),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _InviteContent extends StatelessWidget {
  const _InviteContent({required this.detail});

  final IslandInviteDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: detail.bgImageUrl?.isNotEmpty == true
                  ? Image.network(detail.bgImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.bg03,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.landscape_rounded,
                        size: 56,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            detail.name,
            style: AppFont.b3_24.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (detail.members.isNotEmpty) _MemberStack(members: detail.members),
          const SizedBox(height: 12),
          Text(
            '기억섬 초대를 받았어요. 입장하면 멤버로 등록되고 바로 섬으로 이동해요.',
            style: AppFont.b8_14.copyWith(color: AppColors.g02),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MemberStack extends StatelessWidget {
  const _MemberStack({required this.members});

  final List<MemoryMemberPreview> members;

  @override
  Widget build(BuildContext context) {
    final visibleMembers = members.take(5).toList();
    final width = 32 + ((visibleMembers.length - 1) * 18);

    return SizedBox(
      height: 32,
      width: width.toDouble(),
      child: Stack(
        children: [
          for (int index = 0; index < visibleMembers.length; index++)
            Positioned(
              left: index * 18,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.g05,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: ClipOval(
                  child: visibleMembers[index].avatarUrl?.isNotEmpty == true
                      ? Image.network(
                          visibleMembers[index].avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            visibleMembers[index].nickname.characters.first,
                            style: AppFont.b9_12.copyWith(
                              color: AppColors.g02,
                            ),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InviteErrorState extends StatelessWidget {
  const _InviteErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          style: AppFont.b8_14.copyWith(color: AppColors.g02),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
