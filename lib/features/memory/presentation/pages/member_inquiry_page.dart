import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/favorite_photos_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/island_invite_page.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/island_detail_view_model.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/friend_profile_page.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class MemberInquiryPage extends StatelessWidget {
  const MemberInquiryPage({
    super.key,
    required this.islandId,
  });

  final String islandId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IslandDetailViewModel(
        islandId: islandId,
        repository: const MemoryRepository(MemoryService()),
      )..load(),
      child: const _MemberInquiryView(),
    );
  }
}

class _MemberInquiryView extends StatelessWidget {
  const _MemberInquiryView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<IslandDetailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: AppHeadlineText('기억섬 멤버', style: AppFont.h5_20),
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  viewModel.errorMessage!,
                  style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final island = viewModel.island;
          if (island == null) {
            return Center(
              child: Text(
                '기억섬 정보를 찾을 수 없어요.',
                style: AppFont.b8_14.copyWith(color: AppColors.g03),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.b03,
                  borderRadius: BorderRadius.circular(18),
                  image: island.imagePath != null && island.imagePath!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(island.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: island.imagePath == null || island.imagePath!.isEmpty
                    ? const Icon(
                        Icons.landscape_rounded,
                        color: AppColors.white,
                        size: 42,
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Center(
                child: AppHeadlineText(
                  island.title,
                  style: AppFont.h4_22,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.bg02),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.b02,
                        size: 28,
                      ),
                      title: Text(
                        '캘린더',
                        style: AppFont.b7_16.copyWith(color: AppColors.black),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CalendarPage(
                              showBackButton: true,
                              initiallySelectedIslandIds: {island.id},
                            ),
                          ),
                        );
                      },
                    ),
                    Container(height: 1, color: AppColors.bg02),
                    ListTile(
                      leading: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColors.b02,
                        size: 28,
                      ),
                      title: Text(
                        '즐겨찾는 사진',
                        style: AppFont.b7_16.copyWith(color: AppColors.black),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => FavoritePhotosPage(islandId: island.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.bg02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '버블 메이트 ${viewModel.members.length}',
                      style: AppFont.b7_16.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.black),
                        ),
                        child: const Icon(Icons.add, size: 22),
                      ),
                      title: Text(
                        '초대하기',
                        style: AppFont.b7_16.copyWith(color: AppColors.black),
                      ),
                      onTap: () async {
                        final invited = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute<bool>(
                            builder: (_) => IslandInvitePage(
                              islandId: island.id,
                              existingMemberIds: viewModel.members
                                  .map((member) => member.id)
                                  .toSet(),
                            ),
                          ),
                        );

                        if (invited == true && context.mounted) {
                          await context.read<IslandDetailViewModel>().load();
                        }
                      },
                    ),
                    if (viewModel.members.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        child: Text(
                          '멤버가 없습니다',
                          style: AppFont.b8_14.copyWith(color: AppColors.g03),
                        ),
                      )
                    else
                      ...viewModel.members.map((member) => _memberTile(context, member)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _memberTile(BuildContext context, MemoryMemberPreview member) {
    final displayName = member.nickname.trim().isEmpty ? '이름 없음' : member.nickname.trim();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.bg02,
        backgroundImage: member.avatarUrl?.isNotEmpty == true
            ? NetworkImage(member.avatarUrl!)
            : null,
        child: member.avatarUrl?.isNotEmpty == true
            ? null
            : Text(
                displayName.isEmpty ? '?' : displayName[0],
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
      ),
      title: Text(displayName, style: AppFont.b7_16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FriendProfilePage(
              friend: FriendItem(
                id: member.id,
                nickname: displayName,
                userCode: member.id,
                profileImageUrl: member.avatarUrl,
              ),
            ),
          ),
        );
      },
    );
  }
}
