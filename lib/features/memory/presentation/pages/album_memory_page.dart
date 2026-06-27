import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_album_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class AlbumMemoryPage extends StatefulWidget {
  const AlbumMemoryPage({
    super.key,
    required this.islandId,
    required this.repository,
    required this.photos,
  });

  final String islandId;
  final MemoryRepository repository;
  final List<MemoryLocalPhoto> photos;

  @override
  State<AlbumMemoryPage> createState() => _AlbumMemoryPageState();
}

class _AlbumMemoryPageState extends State<AlbumMemoryPage> {
  late Future<List<MemoryAlbum>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = widget.repository.fetchAlbums(widget.islandId);
  }

  Future<void> _refresh() async {
    final future = widget.repository.fetchAlbums(widget.islandId);
    setState(() {
      _albumsFuture = future;
    });
    await future;
  }

  Future<void> _createAlbum() async {
    final controller = TextEditingController();
    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('새 앨범 만들기', style: AppFont.b5_20),
          content: TextField(
            controller: controller,
            maxLength: 20,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '앨범 이름을 입력해주세요.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('취소', style: AppFont.b8_14),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('생성', style: AppFont.b8_14),
            ),
          ],
        );
      },
    );

    if (shouldCreate != true) {
      return;
    }

    final name = controller.text.trim();
    if (name.isEmpty) {
      return;
    }

    try {
      final album = await widget.repository.createAlbum(
        islandId: widget.islandId,
        name: name,
      );
      final added = await _pickPhotosForAlbum(album.id);
      await _refresh();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              added ? '앨범을 만들고 사진을 담았어요.' : '앨범을 만들었어요.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
    }
  }

  Future<bool> _pickPhotosForAlbum(
    String albumId, {
    Set<String> excludedPhotoIds = const {},
  }) async {
    final selectablePhotos = widget.photos
        .where((photo) => photo.id != null && photo.id!.isNotEmpty)
        .where((photo) => !excludedPhotoIds.contains(photo.id))
        .toList();

    if (selectablePhotos.isEmpty) {
      return false;
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
                    Text('앨범에 담을 사진 선택', style: AppFont.b5_20),
                    const SizedBox(height: 6),
                    Text(
                      '해당 기억섬 사진들 중 원하는 사진을 골라보세요.',
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
                            child: Text('나중에', style: AppFont.b8_14),
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
      return false;
    }

    await widget.repository.addPhotosToAlbum(
      albumId: albumId,
      photoIds: selectedIds.toList(),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryAlbum>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        final albums = snapshot.data ?? const <MemoryAlbum>[];

        return Column(
          children: [
            Expanded(
              child: albums.isEmpty
                  ? _EmptyAlbumState(onCreateAlbum: _createAlbum)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                      itemCount: albums.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 18,
                            mainAxisExtent: 154,
                          ),
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        return _AlbumCard(
                          album: album,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MemoryAlbumDetailPage(
                                  islandId: widget.islandId,
                                  album: album,
                                  repository: widget.repository,
                                  availablePhotos: widget.photos,
                                ),
                              ),
                            );
                            await _refresh();
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.onTap,
  });

  final MemoryAlbum album;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = album.coverImageUrl?.trim();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                color: AppColors.bg01,
                child: cover != null && cover.isNotEmpty
                    ? Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _AlbumPlaceholder(),
                      )
                    : const _AlbumPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.name,
            style: AppFont.b7_16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            '${album.photoCount}개',
            style: AppFont.b9_12.copyWith(color: AppColors.g02),
          ),
        ],
      ),
    );
  }
}

class _AlbumPlaceholder extends StatelessWidget {
  const _AlbumPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.favorite,
        size: 26,
        color: AppColors.black,
      ),
    );
  }
}

class _EmptyAlbumState extends StatelessWidget {
  const _EmptyAlbumState({required this.onCreateAlbum});

  final Future<void> Function() onCreateAlbum;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.images.calendar.character,
              width: 88,
              height: 88,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 공유 앨범이 없어요.',
              style: AppFont.b7_16,
            ),
            const SizedBox(height: 8),
            Text(
              '테마별, 여행별, 이벤트별로 앨범을 만들어 사진을 모아보세요.',
              textAlign: TextAlign.center,
              style: AppFont.b9_12.copyWith(color: AppColors.g02),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onCreateAlbum,
              child: Text('첫 앨범 만들기', style: AppFont.b8_14),
            ),
          ],
        ),
      ),
    );
  }
}
