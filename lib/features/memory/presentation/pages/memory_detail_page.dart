import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:uyoung_app/features/memory/data/memory_dummy_adapter.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/album_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/all_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/date_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/member_inquiry_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_post_edit_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_upload_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/timeline_memory_page.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

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
  final List<MemoryLocalPhoto> _localPhotos = [];
  final MemoryRepository _repository = const MemoryRepository(MemoryService());
  bool _isLoadingPhotos = false;

  static const double _tabBarHeight = 52;

  @override
  void initState() {
    super.initState();
    _localPhotos.addAll(
      MemoryDummyAdapter.localPhotosForIsland(widget.item.id).map(
        (photo) => MemoryLocalPhoto(
          id: photo.id,
          path: photo.path,
          createdAt: photo.createdAt,
          uploaderName: photo.uploaderName,
          uploaderProfile: photo.profileImagePath,
          isLocalFile: false,
          description: photo.description,
          takenAt: photo.takenAt,
          latitude: photo.latitude,
          longitude: photo.longitude,
          locationName: photo.locationName,
        ),
      ),
    );
    _loadPersistedPhotos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPersistedPhotos() async {
    setState(() => _isLoadingPhotos = true);
    try {
      final photos = await _repository.fetchIslandPhotos(widget.item.id);
      if (!mounted) {
        return;
      }

      final existingPaths = _localPhotos.map((photo) => photo.path).toSet();
      final persisted = photos
          .where((photo) => photo.path.isNotEmpty && !existingPaths.contains(photo.path))
          .map(
            (photo) => MemoryLocalPhoto(
              id: photo.id,
              path: photo.path,
              createdAt: photo.createdAt,
              uploaderName: photo.uploaderName,
              uploaderProfile: photo.profileImagePath,
              isLocalFile: false,
              description: photo.description,
              takenAt: photo.takenAt,
              latitude: photo.latitude,
              longitude: photo.longitude,
              locationName: photo.locationName,
            ),
          )
          .toList();

      persisted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _localPhotos.insertAll(0, persisted);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPhotos = false);
      }
    }
  }

  Future<void> _openUploadPage() async {
    final uploadedPhotos = await Navigator.of(context).push<List<MemoryLocalPhoto>>(
      MaterialPageRoute<List<MemoryLocalPhoto>>(
        builder: (_) => MemoryUploadPage(
          islandId: widget.item.id,
          repository: _repository,
        ),
      ),
    );

    if (uploadedPhotos == null || uploadedPhotos.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _localPhotos.insertAll(0, uploadedPhotos);
      selectedIndex = 0;
    });
  }

  void _openCalendarForDate(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarPage(
          showBackButton: true,
          initialSelectedDay: date,
          initiallySelectedIslandIds: {widget.item.id},
          openBottomSheetInitially: true,
        ),
      ),
    );
  }

  Future<void> _editPost(List<MemoryLocalPhoto> photos) async {
    if (photos.isEmpty) {
      return;
    }

    final updatedPhotos = await Navigator.of(context).push<List<MemoryLocalPhoto>>(
      MaterialPageRoute<List<MemoryLocalPhoto>>(
        builder: (_) => MemoryPostEditPage(
          islandId: widget.item.id,
          repository: _repository,
          initialPhotos: photos,
        ),
      ),
    );

    if (updatedPhotos == null || !mounted) {
      return;
    }

    final originalIds = photos
        .map((photo) => photo.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final originalPaths = photos.map((photo) => photo.path).toSet();

    setState(() {
      _localPhotos.removeWhere(
        (photo) =>
            originalIds.contains(photo.id) || originalPaths.contains(photo.path),
      );
      _localPhotos.insertAll(0, updatedPhotos);
    });
  }

  Future<void> _deletePost(List<MemoryLocalPhoto> photos) async {
    final deletableIds = photos
        .map((photo) => photo.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    if (deletableIds.isEmpty) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('게시글 삭제', style: AppFont.b5_20),
          content: Text(
            '선택한 게시글을 삭제할까요?',
            style: AppFont.b8_14.copyWith(color: AppColors.g02),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('취소', style: AppFont.b8_14),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.subRed03,
              ),
              child: Text(
                '삭제',
                style: AppFont.b8_14.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _repository.deletePost(
      photoIds: deletableIds,
      imageUrls: photos.map((photo) => photo.path).toList(),
    );

    setState(() {
      _localPhotos.removeWhere((photo) => deletableIds.contains(photo.id));
    });
  }

  void _removePhotosLocally(List<String> photoIds, List<String> paths) {
    setState(() {
      _localPhotos.removeWhere(
        (photo) =>
            (photo.id != null && photoIds.contains(photo.id)) ||
            paths.contains(photo.path),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AppTopBarIconButton(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              AssetPaths.icons.common.previous,
              width: 24,
              height: 24,
            ),
          ),
        ),
        title: Text(widget.item.title, style: AppFont.b5_20),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppTopBarIconButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MemberInquiryPage(islandId: widget.item.id),
                  ),
                );
              },
              child: SvgPicture.asset(
                AssetPaths.icons.common.hamburger,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => selectedIndex = index),
            children: [
              AllMemoryPage(
                islandId: widget.item.id,
                photos: _localPhotos,
                onEditPost: _editPost,
                onDeletePost: _deletePost,
                onTapDate: _openCalendarForDate,
              ),
              DateMemoryPage(
                islandId: widget.item.id,
                photos: _localPhotos,
                repository: _repository,
                onDeletePhotos: _removePhotosLocally,
              ),
              TimelineMemoryPage(
                islandId: widget.item.id,
                photos: _localPhotos,
              ),
              AlbumMemoryPage(
                islandId: widget.item.id,
                repository: _repository,
                photos: _localPhotos,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: AppColors.bg03,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: _modeButton('전체', 0)),
                                const SizedBox(width: 6),
                                Expanded(child: _modeButton('일자별', 1)),
                                const SizedBox(width: 6),
                                Expanded(child: _modeButton('타임라인', 2)),
                                const SizedBox(width: 6),
                                Expanded(child: _modeButton('앨범', 3)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openUploadPage,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DB5FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AssetPaths.icons.common.addPhotoPlus,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingPhotos)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(child: CircularProgressIndicator()),
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
            color: isSelected
                ? const Color(0xFFD6E8FF)
                : Colors.transparent,
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
