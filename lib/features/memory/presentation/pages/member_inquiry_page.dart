import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:uyoung_app/shared/services/asset_paths.dart';

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
      body: SafeArea(
        child: Builder(
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                _Header(
                  onBack: () => Navigator.of(context).pop(),
                  onExport: () async {
                    final inviteCode = island.inviteCode;
                    if (inviteCode == null || inviteCode.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('공유할 초대 코드가 없어요.')),
                      );
                      return;
                    }
                    await Clipboard.setData(ClipboardData(text: inviteCode));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('초대 코드가 복사되었어요.')),
                    );
                  },
                  onSettings: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('설정 기능은 준비 중이에요.')),
                    );
                  },
                ),
                const SizedBox(height: 26),
                _CoverImage(imagePath: island.imagePath),
                const SizedBox(height: 24),
                Text(
                  island.title,
                  textAlign: TextAlign.center,
                  style: AppFont.h3_24.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_estimatedStorageMb(viewModel.members.length)} MB',
                  textAlign: TextAlign.center,
                  style: AppFont.b6_18.copyWith(color: AppColors.g02),
                ),
                const SizedBox(height: 22),
                _SectionCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: AssetPaths.icons.islandDetail.calendar,
                        label: '캘린더',
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
                      const Divider(height: 1, color: AppColors.bg02),
                      _ActionRow(
                        icon: AssetPaths.icons.islandDetail.favorite,
                        label: '즐겨찾는 사진',
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
                const SizedBox(height: 12),
                _SectionCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '버블 메이트 ${viewModel.members.length}',
                          style: AppFont.b7_16.copyWith(color: AppColors.black),
                        ),
                        const SizedBox(height: 14),
                        _MemberRow(
                          avatar: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bg02),
                              image: DecorationImage(
                                image: AssetImage(AssetPaths.icons.islandDetail.character),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          name: '초대하기',
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
                            padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                            child: Text(
                              '아직 함께한 멤버가 없어요.',
                              style: AppFont.b8_14.copyWith(color: AppColors.g03),
                            ),
                          )
                        else
                          ...viewModel.members.map(
                            (member) => _MemberRow(
                              avatar: _MemberAvatar(member: member),
                              name: member.nickname.trim().isEmpty
                                  ? '이름 없음'
                                  : member.nickname.trim(),
                              onTap: () {
                                final displayName = member.nickname.trim().isEmpty
                                    ? '이름 없음'
                                    : member.nickname.trim();
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
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('기억섬 나가기 기능은 준비 중이에요.')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Text(
                        '기억섬 나가기',
                        style: AppFont.b7_16.copyWith(color: AppColors.subRed03),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _estimatedStorageMb(int memberCount) {
    final base = memberCount * 200 + 131;
    return base < 131 ? 131 : base;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onBack,
    required this.onExport,
    required this.onSettings,
  });

  final VoidCallback onBack;
  final VoidCallback onExport;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButtonShell(
          onTap: onBack,
          child: SvgPicture.asset(
            AssetPaths.icons.common.previous,
            width: 26,
            height: 26,
          ),
        ),
        const Spacer(),
        _IconButtonShell(
          onTap: onExport,
          child: SvgPicture.asset(
            AssetPaths.icons.common.export,
            width: 26,
            height: 26,
          ),
        ),
        const SizedBox(width: 8),
        _IconButtonShell(
          onTap: onSettings,
          child: SvgPicture.asset(
            AssetPaths.icons.common.setting,
            width: 26,
            height: 26,
          ),
        ),
      ],
    );
  }
}

class _IconButtonShell extends StatelessWidget {
  const _IconButtonShell({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(width: 44, height: 44, child: Center(child: child)),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Center(
      child: Container(
        width: 238,
        height: 164,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFCF6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF767490), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.network(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _CoverFallback(),
              )
            : _CoverFallback(),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCF6),
      ),
      child: Center(
        child: Image.asset(
          AssetPaths.icons.islandDetail.character,
          width: 170,
          height: 110,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bg02),
      ),
      child: child,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            Image.asset(icon, width: 28, height: 28),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppFont.b7_16.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.avatar,
    required this.name,
    required this.onTap,
  });

  final Widget avatar;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: AppFont.b7_16.copyWith(color: AppColors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final MemoryMemberPreview member;

  @override
  Widget build(BuildContext context) {
    final displayName = member.nickname.trim().isEmpty ? '이름 없음' : member.nickname.trim();

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.bg02,
      backgroundImage: member.avatarUrl?.isNotEmpty == true
          ? NetworkImage(member.avatarUrl!)
          : null,
      child: member.avatarUrl?.isNotEmpty == true
          ? null
          : Text(
              displayName[0],
              style: AppFont.b8_14.copyWith(color: AppColors.g02),
            ),
    );
  }
}
