import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  final List<MemoryLocalPhoto> _localPhotos = [];
  final MemoryRepository _repository = const MemoryRepository(MemoryService());
  bool _isLoadingPhotos = false;
  bool _isUploadingPhoto = false;

  static const double _tabBarHeight = 52;

  @override
  void initState() {
    super.initState();
    _localPhotos.addAll(
      MemoryDummyAdapter.localPhotosForIsland(widget.item.id).map(
        (photo) => MemoryLocalPhoto(
          path: photo.path,
          createdAt: photo.createdAt,
          uploaderName: photo.uploaderName,
          uploaderProfile: photo.profileImagePath,
          isLocalFile: false,
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
              path: photo.path,
              createdAt: photo.createdAt,
              uploaderName: photo.uploaderName,
              uploaderProfile: photo.profileImagePath,
              isLocalFile: false,
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }

    setState(() => _isUploadingPhoto = true);
    try {
      final uploaded = await _repository.uploadIslandPhoto(
        islandId: widget.item.id,
        imageFile: pickedFile,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _localPhotos.insert(
          0,
          MemoryLocalPhoto(
            path: uploaded.path,
            createdAt: uploaded.createdAt,
            uploaderName: uploaded.uploaderName,
            uploaderProfile: uploaded.profileImagePath,
            isLocalFile: false,
            takenAt: uploaded.takenAt,
            latitude: uploaded.latitude,
            longitude: uploaded.longitude,
            locationName: uploaded.locationName,
          ),
        );
        selectedIndex = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
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
            )
          : null,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => selectedIndex = index),
            children: [
              AllMemoryPage(photos: _localPhotos),
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
          if (_isLoadingPhotos || _isUploadingPhoto)
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
