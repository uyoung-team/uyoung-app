import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/create_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_search_page.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/memory_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemoryViewModel(
        const MemoryRepository(MemoryService()),
      )..load(),
      child: const _MemoryView(),
    );
  }
}

class _MemoryView extends StatefulWidget {
  const _MemoryView();

  @override
  State<_MemoryView> createState() => _MemoryViewState();
}

class _MemoryViewState extends State<_MemoryView> {
  Future<void> _openCreatePage(BuildContext context) async {
    final createdItem = await Navigator.of(context).push<MemoryIslandItem>(
      MaterialPageRoute<MemoryIslandItem>(
        builder: (_) => const CreateMemoryPage(),
      ),
    );
    if (createdItem != null && context.mounted) {
      await context.read<MemoryViewModel>().insertCreatedItem(createdItem);
    }
  }

  Future<void> _openActionSheet(
    BuildContext context, {
    required int index,
    required MemoryIslandItem item,
  }) async {
    final viewModel = context.read<MemoryViewModel>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionTile(
                  iconPath: AssetPaths.icons.bar.revise,
                  label: '이름 변경',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _showRenameDialog(
                      context,
                      index: index,
                      item: item,
                    );
                  },
                ),
                _ActionDivider(),
                _ActionTile(
                  iconPath: AssetPaths.icons.common.favorite,
                  label: item.isFavorite ? '즐겨찾기 해제' : '즐겨찾기',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await viewModel.toggleFavorite(index);
                  },
                ),
                _ActionDivider(),
                _ActionTile(
                  iconPath: item.isNotificationOn
                      ? AssetPaths.icons.common.notification01
                      : AssetPaths.icons.common.notification02,
                  label: item.isNotificationOn ? '알람 끄기' : '알람 켜기',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await viewModel.toggleAlarm(index);
                  },
                ),
                _ActionDivider(),
                _ActionTile(
                  iconPath: AssetPaths.icons.smallCommon.link,
                  label: '초대 링크 복사',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _copyInviteLink(context, item);
                  },
                ),
                _ActionDivider(),
                _ActionTile(
                  iconPath: AssetPaths.icons.common.exit,
                  label: '기억섬 나가기',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _showLeaveDialog(context, index: index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context, {
    required int index,
    required MemoryIslandItem item,
  }) async {
    final controller = TextEditingController(text: item.title);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('이름 변경', style: AppFont.b5_20),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: '기억섬 이름을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('취소', style: AppFont.b8_14),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('저장', style: AppFont.b8_14),
            ),
          ],
        );
      },
    );

    if (shouldSave == true && context.mounted) {
      await context.read<MemoryViewModel>().renameIsland(
        index: index,
        name: controller.text,
      );
    }
  }

  Future<void> _copyInviteLink(BuildContext context, MemoryIslandItem item) async {
    final inviteCode = item.inviteCode;
    if (inviteCode == null || inviteCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초대 링크를 찾을 수 없어요.')));
      return;
    }

    final link = context.read<MemoryViewModel>().repository.buildInviteLink(
      inviteCode,
    );
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('초대 링크를 복사했어요.')));
  }

  Future<void> _showLeaveDialog(BuildContext context, {required int index}) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('정말 나가시겠어요?', style: AppFont.b5_20),
          content: Text(
            '나가면 되돌릴 수 없습니다.',
            style: AppFont.b8_14.copyWith(color: AppColors.g02),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('아니요', style: AppFont.b8_14),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.subRed03,
              ),
              child: Text(
                '네, 나갈게요',
                style: AppFont.b8_14.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true && context.mounted) {
      await context.read<MemoryViewModel>().removeItem(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: AppHeadlineText('기억섬', style: AppFont.h3_24),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppTopBarIconButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MemorySearchPage(items: viewModel.items),
                  ),
                );
              },
              child: SvgPicture.asset(
                AssetPaths.icons.common.search,
                width: kAppTopBarIconVisualSize,
                height: kAppTopBarIconVisualSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: kAppTopBarHorizontalPadding),
            child: AppTopBarIconButton(
              onTap: () => _openCreatePage(context),
              child: SvgPicture.asset(
                AssetPaths.icons.common.chatPlus,
                width: kAppTopBarIconVisualSize,
                height: kAppTopBarIconVisualSize,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: viewModel.load,
          child: Builder(
            builder: (context) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null &&
                  viewModel.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      viewModel.errorMessage!,
                      style: AppFont.b8_14.copyWith(
                        color: AppColors.subRed03,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (viewModel.items.isEmpty) {
                return const _MemoryEmptyState();
              }

              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                itemCount: viewModel.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 170 / 150,
                ),
                itemBuilder: (context, index) {
                  final item = viewModel.items[index];
                  return _MemoryIslandCard(
                    item: item,
                    onLongPress: () =>
                        _openActionSheet(context, index: index, item: item),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

}

class _MemoryEmptyState extends StatelessWidget {
  const _MemoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetPaths.images.character.character02,
              width: 148,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            AppHeadlineText(
              '기억이 모일 섬이 아직 없어요.',
              style: AppFont.h5_20,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '기억섬을 만들고 함께 추억을 쌓아보세요.',
              style: AppFont.b8_14.copyWith(color: AppColors.g02),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 42,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push<MemoryIslandItem>(
                    MaterialPageRoute<MemoryIslandItem>(
                      builder: (_) => const CreateMemoryPage(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.b02,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '기억섬 생성하기',
                  style: AppFont.b7_16.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryIslandCard extends StatelessWidget {
  const _MemoryIslandCard({
    required this.item,
    required this.onLongPress,
  });

  final MemoryIslandItem item;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MemoryDetailPage(item: item),
            ),
          );
        },
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
            color: AppColors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imagePath != null && item.imagePath!.isNotEmpty)
                      Image.network(
                        item.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _MemoryCardFallback(),
                      )
                    else
                      const _MemoryCardFallback(),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _StatusChip(
                        iconPath: item.isFavorite
                            ? AssetPaths.icons.common.favorite
                            : null,
                        label: item.isFavorite ? '즐겨찾기' : '기억섬',
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.isNotificationOn
                              ? Icons.notifications_none_rounded
                              : Icons.notifications_off_outlined,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeadlineText(
                      item.title.isEmpty ? '이름 없는 기억섬' : item.title,
                      style: AppFont.h8_14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _MemberPreviewRow(members: item.members),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.subRed03 : AppColors.black;

    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
      title: Text(
        label,
        style: AppFont.b8_14.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}

class _ActionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.bg03);
  }
}

class _MemoryCardFallback extends StatelessWidget {
  const _MemoryCardFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.b03,
      alignment: Alignment.center,
      child: Image.asset(
        AssetPaths.images.character.character02,
        width: 72,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.iconPath,
  });

  final String label;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPath != null) ...[
            SvgPicture.asset(
              iconPath!,
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppColors.subYellow01,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppFont.b10_10.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

class _MemberPreviewRow extends StatelessWidget {
  const _MemberPreviewRow({required this.members});

  final List<MemoryMemberPreview> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Text(
        '참여 멤버가 아직 없습니다.',
        style: AppFont.b9_12.copyWith(color: AppColors.g02),
      );
    }

    final previewMembers = members.take(3).toList();
    final extraCount = members.length - previewMembers.length;

    return Row(
      children: [
        SizedBox(
          width: 64,
          height: 24,
          child: Stack(
            children: [
              for (var i = 0; i < previewMembers.length; i++)
                Positioned(
                  left: i * 18,
                  child: _MemberAvatar(member: previewMembers[i]),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            extraCount > 0
                ? '${previewMembers.first.nickname} 외 ${members.length - 1}명'
                : previewMembers.map((member) => member.nickname).join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.b9_12.copyWith(color: AppColors.g02),
          ),
        ),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final MemoryMemberPreview member;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
          ? Image.network(
              member.avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _MemberAvatarFallback(),
            )
          : const _MemberAvatarFallback(),
    );
  }
}

class _MemberAvatarFallback extends StatelessWidget {
  const _MemberAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.bg02),
      child: Icon(
        Icons.person_rounded,
        size: 14,
        color: AppColors.g02,
      ),
    );
  }
}
