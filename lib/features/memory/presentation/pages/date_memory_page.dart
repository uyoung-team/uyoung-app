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
          '아직 추가된 사진이 없어요.',
          style: AppFont.b7_16.copyWith(color: AppColors.g03),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dayPhotos = grouped[date] ?? const [];

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
                          uploaderProfile: photo.uploaderProfile,
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
