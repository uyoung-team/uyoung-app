import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_memory_island_detail_page.dart';

class CalendarMemoryBottomSheet extends StatelessWidget {
  const CalendarMemoryBottomSheet({
    super.key,
    required this.date,
    required this.groups,
  });

  final DateTime date;
  final List<CalendarDayMemoryGroup> groups;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.48,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -4),
                blurRadius: 16,
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.g04,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: groups.isEmpty
                    ? Center(
                        child: Text(
                          '해당 날짜에 표시할 기억이 없어요.',
                          style: AppFont.b8_14.copyWith(color: AppColors.g03),
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        children: [
                          for (final group in groups)
                            _CalendarMemoryIslandSection(
                              group: group,
                              date: date,
                            ),
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

class _CalendarMemoryIslandSection extends StatelessWidget {
  const _CalendarMemoryIslandSection({
    required this.group,
    required this.date,
  });

  final CalendarDayMemoryGroup group;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    if (group.thumbnailPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: group.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              group.islandName,
              style: AppFont.h6_18.copyWith(color: AppColors.black),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _MemoryPhotoRow(
            thumbnailPaths: group.thumbnailPaths,
            group: group,
            date: date,
          ),
        ),
      ],
    );
  }
}

class _MemoryPhotoRow extends StatelessWidget {
  const _MemoryPhotoRow({
    required this.thumbnailPaths,
    required this.group,
    required this.date,
  });

  final List<String> thumbnailPaths;
  final CalendarDayMemoryGroup group;
  final DateTime date;

  ImageProvider<Object> _imageProviderFor(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  void _openDetailPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CalendarMemoryIslandDetailPage(group: group, date: date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstThumb = thumbnailPaths[0];
    final String? secondThumb = thumbnailPaths.length > 1
        ? thumbnailPaths[1]
        : null;
    final String? thirdThumb = thumbnailPaths.length > 2
        ? thumbnailPaths[2]
        : null;

    final showOverlayOnThird = thumbnailPaths.length >= 4;
    final remainingCount = showOverlayOnThird ? (thumbnailPaths.length - 3) : 0;

    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openDetailPage(context),
            child: _PhotoCard(
              imagePath: firstThumb,
              angleDegrees: -3.98,
              imageProvider: _imageProviderFor(firstThumb),
            ),
          ),
          const SizedBox(width: 15),
          if (secondThumb != null) ...[
            GestureDetector(
              onTap: () => _openDetailPage(context),
              child: _PhotoCard(
                imagePath: secondThumb,
                angleDegrees: 2.98,
                imageProvider: _imageProviderFor(secondThumb),
              ),
            ),
            const SizedBox(width: 15),
          ],
          if (thirdThumb != null)
            GestureDetector(
              onTap: () => _openDetailPage(context),
              child: showOverlayOnThird
                  ? _OverlayPhotoCard(
                      imagePath: thirdThumb,
                      label: '+$remainingCount',
                      imageProvider: _imageProviderFor(thirdThumb),
                    )
                  : _PhotoCard(
                      imagePath: thirdThumb,
                      angleDegrees: 2.99,
                      imageProvider: _imageProviderFor(thirdThumb),
                    ),
            ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.imagePath,
    required this.angleDegrees,
    required this.imageProvider,
  });

  final String imagePath;
  final double angleDegrees;
  final ImageProvider<Object> imageProvider;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angleDegrees * 3.141592 / 180,
      child: Container(
        width: 107,
        height: 143,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 6,
              color: Color(0x14000000),
            ),
          ],
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _OverlayPhotoCard extends StatelessWidget {
  const _OverlayPhotoCard({
    required this.imagePath,
    required this.label,
    required this.imageProvider,
  });

  final String imagePath;
  final String label;
  final ImageProvider<Object> imageProvider;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2.99 * 3.141592 / 180,
      child: Container(
        width: 107,
        height: 143,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 0,
              color: Color(0x14000000),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(image: imageProvider, fit: BoxFit.cover),
              Container(color: const Color(0x66000000)),
              Center(
                child: Text(
                  label,
                  style: AppFont.b5_20.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
