import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_dummy_adapter.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/album_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/all_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/date_memory_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/member_inquiry_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_upload_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/timeline_memory_page.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

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

  Future<void> _editPost(List<MemoryLocalPhoto> photos) async {
    final editableIds = photos
        .map((photo) => photo.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    if (editableIds.isEmpty) {
      return;
    }

    final controller = TextEditingController(
      text: (photos.first.description ?? '').trim(),
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('게시글 수정', style: AppFont.b5_20),
          content: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: '사진과 함께 남길 글을 적어보세요.',
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

    if (shouldSave != true || !mounted) {
      return;
    }

    final nextDescription = controller.text.trim();
    await _repository.updatePostDescription(
      photoIds: editableIds,
      description: nextDescription.isEmpty ? null : nextDescription,
    );

    setState(() {
      for (var i = 0; i < _localPhotos.length; i++) {
        final photo = _localPhotos[i];
        if (editableIds.contains(photo.id)) {
          _localPhotos[i] = MemoryLocalPhoto(
            id: photo.id,
            path: photo.path,
            createdAt: photo.createdAt,
            uploaderName: photo.uploaderName,
            isLocalFile: photo.isLocalFile,
            description: nextDescription.isEmpty ? null : nextDescription,
            uploaderProfile: photo.uploaderProfile,
            takenAt: photo.takenAt,
            latitude: photo.latitude,
            longitude: photo.longitude,
            locationName: photo.locationName,
          );
        }
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            AssetPaths.icons.common.previous,
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.item.title, style: AppFont.b5_20),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MemberInquiryPage(islandId: widget.item.id),
                ),
              );
            },
            icon: SvgPicture.asset(
              AssetPaths.icons.common.hamburger,
              width: 22,
              height: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => selectedIndex = index),
            children: [
              AllMemoryPage(
                photos: _localPhotos,
                onEditPost: _editPost,
                onDeletePost: _deletePost,
              ),
              DateMemoryPage(photos: _localPhotos),
              TimelineMemoryPage(photos: _localPhotos),
              AlbumMemoryPage(photos: _localPhotos),
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
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _openUploadPage,
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
                      child: Center(
                        child: SvgPicture.asset(
                          AssetPaths.icons.common.addPhotoPlus,
                          width: 26,
                          height: 26,
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
