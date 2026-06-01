import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

class AllMemoryPage extends StatelessWidget {
  const AllMemoryPage({
    super.key,
    required this.photos,
  });

  final List<MemoryLocalPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<MemoryLocalPhoto>>{};
    for (final photo in photos) {
      final key = DateTime(
        photo.createdAt.year,
        photo.createdAt.month,
        photo.createdAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(photo);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return Center(
        child: Text(
          '아직 저장된 사진이 없어요.',
          style: AppFont.b7_16.copyWith(color: AppColors.g03),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dayPhotos = [...(grouped[date] ?? const [])]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            Center(child: _DateLabel(date: date)),
            const SizedBox(height: 14),
            ...dayPhotos.map(
              (photo) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PhotoDetailPage(
                          imagePath: photo.path,
                          uploaderName: photo.uploaderName,
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
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: MemoryPhotoThumbnail(photo: photo),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.b02, width: 1),
      ),
      child: Text(
        '${date.year}년 ${date.month}월 ${date.day}일 $weekday요일',
        style: AppFont.b8_14.copyWith(color: AppColors.b02),
      ),
    );
  }
}
