import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/memory_post_item.dart';

class AllMemoryPage extends StatelessWidget {
  const AllMemoryPage({
    super.key,
    required this.photos,
    required this.onEditPost,
    required this.onDeletePost,
  });

  final List<MemoryLocalPhoto> photos;
  final Future<void> Function(List<MemoryLocalPhoto> photos) onEditPost;
  final Future<void> Function(List<MemoryLocalPhoto> photos) onDeletePost;

  @override
  Widget build(BuildContext context) {
    final posts = _groupPosts(photos);
    final grouped = <DateTime, List<_MemoryPostGroup>>{};
    for (final post in posts) {
      final key = DateTime(
        post.createdAt.year,
        post.createdAt.month,
        post.createdAt.day,
      );
      grouped.putIfAbsent(key, () => []).add(post);
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
        final dayPosts = [...(grouped[date] ?? const [])]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            Center(child: _DateLabel(date: date)),
            const SizedBox(height: 14),
            ...dayPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: MemoryPostItem(
                  photos: post.photos,
                  uploaderName: post.uploaderName,
                  uploaderProfile: post.uploaderProfile,
                  createdAt: post.createdAt,
                  description: post.description,
                  onEdit: () => onEditPost(post.photos),
                  onDelete: () => onDeletePost(post.photos),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }

  List<_MemoryPostGroup> _groupPosts(List<MemoryLocalPhoto> photos) {
    final sorted = [...photos]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <_MemoryPostGroup>[];

    for (final photo in sorted) {
      final normalizedDescription = (photo.description ?? '').trim();
      final matchedIndex = groups.indexWhere((group) {
        final sameUploader =
            group.uploaderName == photo.uploaderName &&
            group.uploaderProfile == photo.uploaderProfile;
        final sameDescription = (group.description ?? '').trim() == normalizedDescription;
        final diff = group.createdAt.difference(photo.createdAt).abs();
        return sameUploader && sameDescription && diff.inMinutes < 1;
      });

      if (matchedIndex == -1) {
        groups.add(
          _MemoryPostGroup(
            photos: [photo],
            uploaderName: photo.uploaderName,
            uploaderProfile: photo.uploaderProfile,
            createdAt: photo.createdAt,
            description: photo.description,
          ),
        );
      } else {
        groups[matchedIndex].photos.add(photo);
      }
    }

    return groups;
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

class _MemoryPostGroup {
  _MemoryPostGroup({
    required this.photos,
    required this.uploaderName,
    required this.createdAt,
    this.uploaderProfile,
    this.description,
  });

  final List<MemoryLocalPhoto> photos;
  final String uploaderName;
  final String? uploaderProfile;
  final DateTime createdAt;
  final String? description;
}
