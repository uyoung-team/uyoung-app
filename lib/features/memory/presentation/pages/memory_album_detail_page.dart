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
  });

  final String islandId;
  final MemoryAlbum album;
  final MemoryRepository repository;

  @override
  State<MemoryAlbumDetailPage> createState() => _MemoryAlbumDetailPageState();
}

class _MemoryAlbumDetailPageState extends State<MemoryAlbumDetailPage> {
  late Future<List<MemoryLocalPhoto>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadPhotos();
  }

  Future<List<MemoryLocalPhoto>> _loadPhotos() async {
    final photos = await widget.repository.fetchAlbumPhotos(widget.album.id);
    return photos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.album.name, style: AppFont.b5_20),
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
