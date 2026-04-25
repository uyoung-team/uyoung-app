import 'package:flutter/material.dart';
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

class _MemoryView extends StatelessWidget {
  const _MemoryView();

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
        title: AppHeadlineText('기억섬', style: AppFont.h5_20),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MemorySearchPage(items: viewModel.items),
                ),
              );
            },
            icon: SvgPicture.asset(
              AssetPaths.icons.common.search,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final createdItem = await Navigator.of(context).push<MemoryIslandItem>(
                MaterialPageRoute<MemoryIslandItem>(
                  builder: (_) => const CreateMemoryPage(),
                ),
              );
              if (createdItem != null && context.mounted) {
                await viewModel.insertCreatedItem(createdItem);
              }
            },
            icon: SvgPicture.asset(
              AssetPaths.icons.common.chatPlus,
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 12),
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
                  return _MemoryIslandCard(item: item);
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
  const _MemoryIslandCard({required this.item});

  final MemoryIslandItem item;

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
