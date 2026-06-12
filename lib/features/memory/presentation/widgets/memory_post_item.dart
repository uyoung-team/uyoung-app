import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class MemoryPostItem extends StatefulWidget {
  const MemoryPostItem({
    super.key,
    required this.islandId,
    required this.photos,
    required this.uploaderName,
    required this.createdAt,
    required this.onEdit,
    required this.onDelete,
    this.uploaderProfile,
    this.description,
  });

  final String islandId;
  final List<MemoryLocalPhoto> photos;
  final String uploaderName;
  final DateTime createdAt;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final String? uploaderProfile;
  final String? description;

  @override
  State<MemoryPostItem> createState() => _MemoryPostItemState();
}

class _MemoryPostItemState extends State<MemoryPostItem> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.bg02,
              backgroundImage: _buildProfileImage(widget.uploaderProfile),
              child: _buildProfileImage(widget.uploaderProfile) == null
                  ? const Icon(Icons.person_outline, color: AppColors.g02)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.uploaderName, style: AppFont.b7_16),
                Text(
                  _formatRelativeTime(widget.createdAt),
                  style: AppFont.b9_12.copyWith(color: AppColors.g02),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showMoreSheet(context),
              child: const Icon(Icons.more_horiz, size: 22, color: AppColors.black),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 380,
          width: double.infinity,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: photos.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, i) {
                  final photo = photos[i];
                  return GestureDetector(
                    onTap: () => _openPhotoDetail(context, photo),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox.expand(
                        child: MemoryPhotoThumbnail(photo: photo),
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      AssetPaths.images.shellStory.frame,
                      fit: BoxFit.fill,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              if (photos.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${photos.length}',
                      style: AppFont.b9_12.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if ((widget.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            widget.description!.trim(),
            style: AppFont.b8_14.copyWith(color: AppColors.black),
          ),
        ],
        if (photos.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              photos.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Image.asset(
                  i == _currentIndex
                      ? AssetPaths.images.shellStory.filledIndicator
                      : AssetPaths.images.shellStory.emptyIndicator,
                  width: 14,
                  errorBuilder: (_, _, _) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentIndex ? AppColors.b02 : AppColors.bg03,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }

  ImageProvider<Object>? _buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  void _openPhotoDetail(BuildContext context, MemoryLocalPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoDetailPage(
          imagePath: photo.path,
          islandId: widget.islandId,
          photoId: photo.id,
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

  String _formatRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) {
      return '방금 전';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    }
    return '${diff.inDays}일 전';
  }

  Future<void> _showMoreSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionTile(
                  label: '수정하기',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await widget.onEdit();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                const Divider(height: 1, color: AppColors.bg03),
                _ActionTile(
                  label: '삭제하기',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await widget.onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.subRed03 : AppColors.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(label, style: AppFont.b7_16.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
