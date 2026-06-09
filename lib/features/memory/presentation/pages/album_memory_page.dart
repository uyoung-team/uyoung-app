import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_album_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
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
      await widget.repository.createAlbum(
        islandId: widget.islandId,
        name: name,
      );
      await _refresh();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryAlbum>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        final albums = snapshot.data ?? const <MemoryAlbum>[];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '기억섬 안에서 사진을 분류하고 함께 공유해보세요.',
                      style: AppFont.b9_12.copyWith(color: AppColors.g02),
                    ),
                  ),
                  TextButton(
                    onPressed: _createAlbum,
                    child: Text('새 앨범', style: AppFont.b8_14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: albums.isEmpty
                  ? _EmptyAlbumState(onCreateAlbum: _createAlbum)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                      itemCount: albums.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.92,
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
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: double.infinity,
                color: AppColors.bg01,
                child: cover != null && cover.isNotEmpty
                    ? Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _AlbumPlaceholder(),
                      )
                    : const _AlbumPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(album.name, style: AppFont.b7_16, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            '사진 ${album.photoCount}장',
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
      child: Image.asset(
        AssetPaths.images.calendar.character,
        width: 72,
        height: 72,
        fit: BoxFit.contain,
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
