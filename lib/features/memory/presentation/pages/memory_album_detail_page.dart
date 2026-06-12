import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

class MemoryAlbumDetailPage extends StatefulWidget {
  const MemoryAlbumDetailPage({
    super.key,
    required this.islandId,
    required this.album,
    required this.repository,
    required this.availablePhotos,
  });

  final String islandId;
  final MemoryAlbum album;
  final MemoryRepository repository;
  final List<MemoryLocalPhoto> availablePhotos;

  @override
  State<MemoryAlbumDetailPage> createState() => _MemoryAlbumDetailPageState();
}

class _MemoryAlbumDetailPageState extends State<MemoryAlbumDetailPage> {
  late Future<List<MemoryLocalPhoto>> _photosFuture;
  List<MemoryLocalPhoto> _currentPhotos = const [];

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadPhotos();
  }

  Future<List<MemoryLocalPhoto>> _loadPhotos() async {
    final photos = await widget.repository.fetchAlbumPhotos(widget.album.id);
    final mapped = photos
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
    _currentPhotos = mapped;
    return mapped;
  }

  Future<void> _refresh() async {
    final future = _loadPhotos();
    setState(() {
      _photosFuture = future;
    });
    await future;
  }

  Future<void> _removeFromAlbum(MemoryLocalPhoto photo) async {
    final photoId = photo.id;
    if (photoId == null || photoId.isEmpty) {
      return;
    }
    await widget.repository.removePhotoFromAlbum(
      albumId: widget.album.id,
      photoId: photoId,
    );
    await _refresh();
  }

  Future<void> _addPhotosToAlbum() async {
    final existingIds = _currentPhotos
        .map((photo) => photo.id)
        .whereType<String>()
        .toSet();
    final selectablePhotos = widget.availablePhotos
        .where((photo) => photo.id != null && photo.id!.isNotEmpty)
        .where((photo) => !existingIds.contains(photo.id))
        .toList();

    if (selectablePhotos.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('추가할 수 있는 사진이 없어요.')));
      return;
    }

    final selectedIds = <String>{};
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('앨범에 사진 추가', style: AppFont.b5_20),
                    const SizedBox(height: 6),
                    Text(
                      '이 기억섬에 올라온 사진들 중에서 선택할 수 있어요.',
                      style: AppFont.b9_12.copyWith(color: AppColors.g02),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: selectablePhotos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (_, index) {
                          final photo = selectablePhotos[index];
                          final photoId = photo.id!;
                          final isSelected = selectedIds.contains(photoId);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  selectedIds.remove(photoId);
                                } else {
                                  selectedIds.add(photoId);
                                }
                              });
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: MemoryPhotoThumbnail(photo: photo),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.b02.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.b02,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.b02
                                          : Colors.black.withValues(alpha: 0.32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSelected ? Icons.check : Icons.add,
                                      size: 14,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            child: Text('취소', style: AppFont.b8_14),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () => Navigator.pop(sheetContext, true),
                            child: Text('선택한 사진 담기', style: AppFont.b8_14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldSave != true || selectedIds.isEmpty) {
      return;
    }

    await widget.repository.addPhotosToAlbum(
      albumId: widget.album.id,
      photoIds: selectedIds.toList(),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.album.name, style: AppFont.b5_20),
        actions: [
          IconButton(
            onPressed: _addPhotosToAlbum,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<MemoryLocalPhoto>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          final photos = snapshot.data ?? const <MemoryLocalPhoto>[];
          if (photos.isEmpty) {
            return Center(
              child: Text(
                '이 앨범에는 아직 담긴 사진이 없어요.',
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              final photo = photos[index];
              return GestureDetector(
                onLongPress: () => _removeFromAlbum(photo),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PhotoDetailPage(
                        islandId: widget.islandId,
                        photoId: photo.id,
                        imagePath: photo.path,
                        uploaderName: photo.uploaderName,
                        description: photo.description,
                        uploaderProfile: photo.uploaderProfile,
                        takenAt: photo.takenAt ?? photo.createdAt,
                        latitude: photo.latitude,
                        longitude: photo.longitude,
                        locationName: photo.locationName,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: MemoryPhotoThumbnail(photo: photo),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
