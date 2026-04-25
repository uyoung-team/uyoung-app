import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

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
      minChildSize: 0.32,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _CalendarMemoryIslandSection(group: group);
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 24),
                        itemCount: groups.length,
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
  const _CalendarMemoryIslandSection({required this.group});

  final CalendarDayMemoryGroup group;

  @override
  Widget build(BuildContext context) {
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
            AppHeadlineText(group.islandName, style: AppFont.h6_18),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final imagePath = group.thumbnailPaths[index];
              final remaining = group.thumbnailPaths.length - 3;

              if (index == 2 && group.thumbnailPaths.length > 3) {
                return _OverlayPhotoCard(
                  imagePath: imagePath,
                  label: '+$remaining',
                );
              }

              if (index > 2 && group.thumbnailPaths.length > 3) {
                return const SizedBox.shrink();
              }

              return _PhotoCard(
                imagePath: imagePath,
                angleDegrees: index.isEven ? -3.98 : 2.98,
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemCount: group.thumbnailPaths.length > 3 ? 3 : group.thumbnailPaths.length,
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.imagePath,
    required this.angleDegrees,
  });

  final String imagePath;
  final double angleDegrees;

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
            image: AssetImage(imagePath),
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
  });

  final String imagePath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2.99 * 3.141592 / 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              width: 107,
              height: 143,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(color: const Color(0x66000000)),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  label,
                  style: AppFont.b5_20.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
