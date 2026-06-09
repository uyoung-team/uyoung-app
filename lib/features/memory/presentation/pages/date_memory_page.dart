import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_photo_thumbnail.dart';

class DateMemoryPage extends StatelessWidget {
  const DateMemoryPage({
    super.key,
    required this.photos,
  });

  final List<MemoryLocalPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<MemoryLocalPhoto>>{};
    for (final photo in photos) {
      final takenAt = photo.takenAt ?? photo.createdAt;
      final key = DateTime(
        takenAt.year,
        takenAt.month,
        takenAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(photo);
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dayPhotos = [...(grouped[date] ?? const [])]
          ..sort(
            (a, b) =>
                (b.takenAt ?? b.createdAt).compareTo(a.takenAt ?? a.createdAt),
          );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatKoreanDate(date), style: AppFont.b8_14),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: dayPhotos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final photo = dayPhotos[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PhotoDetailPage(
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
                    borderRadius: BorderRadius.circular(8),
                    child: MemoryPhotoThumbnail(photo: photo),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
          ],
        );
      },
    );
  }

  String _formatKoreanDate(DateTime d) {
    const w = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = w[d.weekday - 1];
    return '${d.year}년 ${d.month}월 ${d.day}일 $weekday요일';
  }
}
