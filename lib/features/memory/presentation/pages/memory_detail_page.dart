import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/presentation/pages/favorite_photos_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/member_inquiry_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({
    super.key,
    required this.item,
  });

  final MemoryIslandItem item;

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  final List<_MemoryLocalPhoto> _localPhotos = [];

  static const double _tabBarHeight = 52;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    setState(() {
      _localPhotos.insert(
        0,
        _MemoryLocalPhoto(
          path: pickedFile.path,
          createdAt: DateTime.now(),
          uploaderName: '나',
          isLocalFile: true,
        ),
      );
      selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: selectedIndex == 0
          ? AppBar(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: AppHeadlineText(widget.item.title, style: AppFont.h5_20),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemberInquiryPage(islandId: widget.item.id),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => selectedIndex = index),
            children: [
              _OverviewTab(
                item: widget.item,
                localPhotos: _localPhotos,
              ),
              _DateTab(item: widget.item, localPhotos: _localPhotos),
              _TimelineTab(item: widget.item, localPhotos: _localPhotos),
              _FavoriteTab(
                item: widget.item,
                onOpenFavoritePhotos: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FavoritePhotosPage(islandId: widget.item.id),
                    ),
                  );
                },
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: _tabBarHeight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(color: AppColors.bg02),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _modeButton('전체', 0)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('일자별', 1)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('타임라인', 2)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('즐겨찾기', 3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.b02,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.b03 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppFont.b7_16.copyWith(
              color: isSelected ? AppColors.b02 : AppColors.g03,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.item,
    required this.localPhotos,
  });

  final MemoryIslandItem item;
  final List<_MemoryLocalPhoto> localPhotos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.b03,
            borderRadius: BorderRadius.circular(20),
            image: item.imagePath != null && item.imagePath!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(item.imagePath!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: item.imagePath == null || item.imagePath!.isEmpty
              ? const Icon(
                  Icons.landscape_rounded,
                  color: AppColors.white,
                  size: 56,
                )
              : null,
        ),
        const SizedBox(height: 18),
        AppHeadlineText(item.title, style: AppFont.h4_22),
        const SizedBox(height: 8),
        Text(
          '이 섬의 구성원과 초대 코드, 빠른 진입 기능을 한눈에 확인할 수 있어요.',
          style: AppFont.b8_14.copyWith(color: AppColors.g02),
        ),
        const SizedBox(height: 18),
        if (localPhotos.isNotEmpty) ...[
          _QuickActionCard(
            title: '최근 추가한 사진',
            subtitle: '${localPhotos.length}장의 사진이 준비되었어요.',
            icon: Icons.photo_library_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PhotoDetailPage(
                    imagePath: localPhotos.first.path,
                    uploaderName: localPhotos.first.uploaderName,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: '멤버 보기',
                subtitle: '버블 메이트 ${item.members.length}',
                icon: Icons.people_alt_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MemberInquiryPage(islandId: item.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: '즐겨찾는 사진',
                subtitle: '중요한 기억만 보기',
                icon: Icons.favorite_border_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => FavoritePhotosPage(islandId: item.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '참여 멤버 ${item.members.length}',
                style: AppFont.b7_16.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 10),
              Text(
                item.members.isEmpty
                    ? '아직 연결된 멤버가 없습니다.'
                    : item.members.map((member) => member.nickname).join(', '),
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
              if (item.inviteCode != null && item.inviteCode!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  '초대 코드',
                  style: AppFont.b7_16.copyWith(color: AppColors.black),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.back,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.bg02),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.inviteCode!,
                          style: AppFont.b7_16.copyWith(color: AppColors.b02),
                        ),
                      ),
                      Text(
                        '공유용',
                        style: AppFont.b8_14.copyWith(color: AppColors.g03),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTab extends StatelessWidget {
  const _DateTab({
    required this.item,
    required this.localPhotos,
  });

  final MemoryIslandItem item;
  final List<_MemoryLocalPhoto> localPhotos;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<_MemoryLocalPhoto>>{};
    for (final photo in localPhotos) {
      final key = DateTime(
        photo.createdAt.year,
        photo.createdAt.month,
        photo.createdAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(photo);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return Center(
        child: Text(
          '아직 추가된 사진이 없어요.',
          style: AppFont.b7_16.copyWith(color: AppColors.g03),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
      itemCount: dates.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final date = dates[index];
        final photos = grouped[date] ?? const [];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.b03,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: AppHeadlineText.h7('${date.day}', color: AppColors.b02),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.month}월 ${date.day}일',
                      style: AppFont.b7_16.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${photos.length}장의 사진이 이 날짜에 저장되어 있어요.',
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                    if (photos.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, photoIndex) {
                            final photo = photos[photoIndex];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PhotoDetailPage(
                                      imagePath: photo.path,
                                      uploaderName: photo.uploaderName,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: _MemoryPhotoThumbnail(photo: photo),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({
    required this.item,
    required this.localPhotos,
  });

  final MemoryIslandItem item;
  final List<_MemoryLocalPhoto> localPhotos;

  @override
  Widget build(BuildContext context) {
    if (localPhotos.isEmpty) {
      return Center(
        child: Text(
          '아직 타임라인에 표시할 사진이 없어요.',
          style: AppFont.b7_16.copyWith(color: AppColors.g03),
        ),
      );
    }

    final timelineItems = localPhotos.take(8).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
      children: [
        ...timelineItems.asMap().entries.map((entry) {
          final index = entry.key;
          final photo = entry.value;
          final isLast = index == timelineItems.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.b02,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 92,
                      color: AppColors.bg02,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.bg02),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${photo.createdAt.month}월 ${photo.createdAt.day}일 · ${photo.uploaderName}',
                        style: AppFont.b7_16.copyWith(color: AppColors.black),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: _MemoryPhotoThumbnail(photo: photo),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '새로운 추억이 타임라인에 추가되었어요.',
                              style: AppFont.b8_14.copyWith(color: AppColors.g02),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _MemoryPhotoThumbnail extends StatelessWidget {
  const _MemoryPhotoThumbnail({required this.photo});

  final _MemoryLocalPhoto photo;

  @override
  Widget build(BuildContext context) {
    if (photo.isLocalFile) {
      return Image.file(
        File(photo.path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
      );
    }

    if (photo.path.startsWith('http://') || photo.path.startsWith('https://')) {
      return Image.network(
        photo.path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
      );
    }

    return Image.asset(
      photo.path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
    );
  }
}

class _FavoriteTab extends StatelessWidget {
  const _FavoriteTab({
    required this.item,
    required this.onOpenFavoritePhotos,
  });

  final MemoryIslandItem item;
  final VoidCallback onOpenFavoritePhotos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeadlineText.h7('즐겨찾는 사진'),
              const SizedBox(height: 8),
              Text(
                '이 기억섬에서 표시해둔 사진만 따로 모아볼 수 있어요.',
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onOpenFavoritePhotos,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.b02,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    '즐겨찾는 사진 열기',
                    style: AppFont.b7_16.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.bg02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.b02),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppFont.b7_16.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppFont.b8_14.copyWith(color: AppColors.g02),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryLocalPhoto {
  const _MemoryLocalPhoto({
    required this.path,
    required this.createdAt,
    required this.uploaderName,
    required this.isLocalFile,
  });

  final String path;
  final DateTime createdAt;
  final String uploaderName;
  final bool isLocalFile;
}
