import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

class DateMemoryPage extends StatefulWidget {
  const DateMemoryPage({
    super.key,
    required this.islandId,
    required this.photos,
    required this.repository,
    required this.onDeletePhotos,
  });

  final String islandId;
  final List<MemoryLocalPhoto> photos;
  final MemoryRepository repository;
  final void Function(List<String> photoIds, List<String> paths) onDeletePhotos;

  @override
  State<DateMemoryPage> createState() => _DateMemoryPageState();
}

class _DateMemoryPageState extends State<DateMemoryPage> {
  late List<MemoryLocalPhoto> _photos;
  bool _isSelectionMode = false;
  final Set<String> _selectedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _photos = List<MemoryLocalPhoto>.from(widget.photos);
  }

  @override
  void didUpdateWidget(covariant DateMemoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.photos, widget.photos)) {
      _photos = List<MemoryLocalPhoto>.from(widget.photos);
      final validKeys = _photos.map(_photoKey).toSet();
      _selectedKeys.removeWhere((key) => !validKeys.contains(key));
      if (_selectedKeys.isEmpty) {
        _isSelectionMode = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<MemoryLocalPhoto>>{};
    for (final photo in _photos) {
      final takenAt = photo.takenAt ?? photo.createdAt;
      final key = DateTime(takenAt.year, takenAt.month, takenAt.day);
      grouped.putIfAbsent(key, () => <MemoryLocalPhoto>[]).add(photo);
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

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _toggleSelectionMode,
                    child: Text(
                      _isSelectionMode ? '선택 취소' : '선택',
                      style: AppFont.b8_14.copyWith(color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  18,
                  0,
                  18,
                  (_isSelectionMode && _selectedKeys.isNotEmpty) ? 250 : 120,
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final dayPhotos = [...(grouped[date] ?? const <MemoryLocalPhoto>[])]
                    ..sort(
                      (a, b) => (b.takenAt ?? b.createdAt).compareTo(
                        a.takenAt ?? a.createdAt,
                      ),
                    );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatKoreanDate(date), style: AppFont.b8_14),
                      const SizedBox(height: 8),
                      GridView.builder(
                        itemCount: dayPhotos.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (_, i) {
                          final photo = dayPhotos[i];
                          final isSelected = _selectedKeys.contains(_photoKey(photo));
                          return GestureDetector(
                            onTap: () => _handlePhotoTap(photo),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MemoryPhotoThumbnail(photo: photo),
                                  if (_isSelectionMode)
                                    Container(
                                      color: isSelected
                                          ? const Color(0x330C0C0C)
                                          : const Color(0x12000000),
                                    ),
                                  if (_isSelectionMode)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.b02
                                              : Colors.white.withValues(alpha: 0.85),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.b02
                                                : AppColors.g03,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        if (_isSelectionMode && _selectedKeys.isNotEmpty)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 104),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_selectedKeys.length}장의 사진이 선택됨',
                      style: AppFont.b7_16.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: '앨범 담기',
                            onTap: _selectedKeys.isEmpty ? null : _addSelectedToAlbum,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            label: '다운로드',
                            onTap: _selectedKeys.isEmpty ? null : _showDownloadPreparing,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            label: '삭제',
                            foregroundColor: AppColors.subRed03,
                            onTap: _selectedKeys.isEmpty ? null : _deleteSelected,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedKeys.clear();
      }
    });
  }

  void _handlePhotoTap(MemoryLocalPhoto photo) {
    if (_isSelectionMode) {
      final key = _photoKey(photo);
      setState(() {
        if (_selectedKeys.contains(key)) {
          _selectedKeys.remove(key);
        } else {
          _selectedKeys.add(key);
        }
      });
      return;
    }

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
  }

  Future<void> _addSelectedToAlbum() async {
    final selectedIds = _selectedPhotos
        .map((photo) => photo.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    if (selectedIds.isEmpty) {
      return;
    }

    final albums = await widget.repository.fetchAlbums(widget.islandId);
    if (!mounted) {
      return;
    }

    if (albums.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('먼저 앨범을 만들어주세요.')));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('앨범에 담기', style: AppFont.b5_20),
                  const SizedBox(height: 16),
                  for (final album in albums) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(album.name, style: AppFont.b7_16),
                      subtitle: Text(
                        '사진 ${album.photoCount}장',
                        style: AppFont.b9_12.copyWith(color: AppColors.g03),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await widget.repository.addPhotosToAlbum(
                          albumId: album.id,
                          photoIds: selectedIds,
                        );
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _selectedKeys.clear();
                          _isSelectionMode = false;
                        });
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('${album.name} 앨범에 담았어요.')),
                          );
                      },
                    ),
                    if (album != albums.last)
                      const Divider(height: 1, color: AppColors.bg02),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteSelected() async {
    final selected = _selectedPhotos;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('사진 삭제', style: AppFont.b5_20),
          content: Text(
            '선택한 사진을 삭제할까요?',
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

    if (shouldDelete != true) {
      return;
    }

    final photoIds = selected
        .map((photo) => photo.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    final paths = selected.map((photo) => photo.path).toList();

    await widget.repository.deletePost(photoIds: photoIds, imageUrls: paths);
    if (!mounted) {
      return;
    }

    setState(() {
      _photos.removeWhere((photo) => _selectedKeys.contains(_photoKey(photo)));
      _selectedKeys.clear();
      _isSelectionMode = false;
    });
    widget.onDeletePhotos(photoIds, paths);
  }

  void _showDownloadPreparing() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('다운로드 기능은 준비 중이에요.')));
  }

  List<MemoryLocalPhoto> get _selectedPhotos => _photos
      .where((photo) => _selectedKeys.contains(_photoKey(photo)))
      .toList();

  String _photoKey(MemoryLocalPhoto photo) => photo.id ?? photo.path;

  String _formatKoreanDate(DateTime d) {
    const w = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = w[d.weekday - 1];
    return '${d.year}년 ${d.month}월 ${d.day}일 $weekday요일';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.onTap,
    this.foregroundColor = AppColors.black,
  });

  final String label;
  final VoidCallback? onTap;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.bg01,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFont.b8_14.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
