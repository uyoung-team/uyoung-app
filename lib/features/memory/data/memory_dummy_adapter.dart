import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/memory/data/memory_location_dummy.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_post_dummy.dart';
import 'package:uyoung_app/features/memory/data/memory_post_model.dart';

class MemoryDummyAdapter {
  const MemoryDummyAdapter._();

  static final Map<String, _DummyIslandMeta> _islandMeta = {
    '1': _DummyIslandMeta('일본팸 ✈️', AppColors.subRed04),
    '2': _DummyIslandMeta('상콩즈 🐼', AppColors.subYellow01),
    '3': _DummyIslandMeta('물개 달란트 🐬', AppColors.b01),
    '5': _DummyIslandMeta('울 애깅 💕', AppColors.subPurple02),
    '6': _DummyIslandMeta('술독 🍻', AppColors.subGreen01),
    '7': _DummyIslandMeta('유러피안 🇪🇺', AppColors.subBlue01),
  };

  static List<MemoryIslandItem> islandItems() {
    return MemoryPostDummy.postsByMemoryId.entries
        .map((entry) {
          final islandId = entry.key;
          final posts = entry.value;
          final meta = _islandMeta[islandId];

          if (meta == null || posts.isEmpty) {
            return null;
          }

          final flattened = localPhotosForIsland(islandId);
          final latestDate = flattened.isEmpty
              ? DateTime.now()
              : (flattened.map((item) => item.createdAt).toList()
                    ..sort((a, b) => b.compareTo(a)))
                  .first;

          return MemoryIslandItem(
            id: islandId,
            title: meta.title,
            isFavorite: islandId == '1' || islandId == '2',
            isNotificationOn: true,
            imagePath: posts.first.images.isEmpty ? null : posts.first.images.first,
            updatedAt: latestDate,
            inviteCode: 'DUMMY-$islandId',
            members: memberPreviews(islandId),
          );
        })
        .whereType<MemoryIslandItem>()
        .toList();
  }

  static MemoryIslandItem? islandItemById(String islandId) {
    for (final item in islandItems()) {
      if (item.id == islandId) {
        return item;
      }
    }
    return null;
  }

  static List<MemoryMemberPreview> memberPreviews(String islandId) {
    final posts = MemoryPostDummy.postsByMemoryId[islandId] ?? const <MemoryPostModel>[];
    final previews = <String, MemoryMemberPreview>{};

    for (final post in posts) {
      final key = '${islandId}_${post.name}';
      previews.putIfAbsent(
        key,
        () => MemoryMemberPreview(
          id: key,
          nickname: post.name,
          avatarUrl: post.profileImage,
        ),
      );
    }

    return previews.values.toList();
  }

  static List<MemoryPhotoSeed> localPhotosForIsland(String islandId) {
    final posts = MemoryPostDummy.postsByMemoryId[islandId] ?? const <MemoryPostModel>[];
    final photos = <MemoryPhotoSeed>[];

    for (final post in posts) {
      final createdAt = _parseCreatedAt(post.createdAt);
      for (final imagePath in post.images) {
        photos.add(
          MemoryPhotoSeed(
            path: imagePath,
            createdAt: createdAt,
            uploaderName: post.name,
            profileImagePath: post.profileImage,
          ),
        );
      }
    }

    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  static List<CalendarIslandFilter> calendarIslandFilters() {
    return _islandMeta.entries
        .map(
          (entry) => CalendarIslandFilter(
            id: entry.key,
            name: entry.value.title,
            color: entry.value.color,
            isSelected: true,
            alertEnabled: true,
          ),
        )
        .toList();
  }

  static List<CalendarEvent> calendarEventsForMonth(DateTime month) {
    final events = <CalendarEvent>[];
    final lastDay = DateTime(month.year, month.month + 1, 0).day;

    for (final entry in MemoryPostDummy.postsByMemoryId.entries) {
      final islandId = entry.key;
      final posts = entry.value;
      final title = _islandMeta[islandId]?.title ?? '기억섬';

      for (final post in posts) {
        final originalDate = _parseCreatedAt(post.createdAt);
        final projectedDay = originalDate.day > lastDay ? lastDay : originalDate.day;
        final projectedDate = DateTime(month.year, month.month, projectedDay);

        for (var index = 0; index < post.images.length; index += 1) {
          final imagePath = post.images[index];
          final location = MemoryLocationDummy.get(imagePath);
          events.add(
            CalendarEvent(
              id: '$islandId-${post.name}-${projectedDate.day}-$index',
              islandId: islandId,
              title: title,
              date: projectedDate,
              imageUrl: imagePath,
              takenAt: projectedDate,
              createdAt: projectedDate,
              locationName: location?.label,
            ),
          );
        }
      }
    }

    return events;
  }

  static DateTime _parseCreatedAt(String createdAt) {
    final cleaned = createdAt.replaceAll('월', '').replaceAll('일', '').trim();
    final parts = cleaned.split(RegExp(r'\s+'));
    final month = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 1 : 1;
    final day = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final year = DateTime.now().year;
    return DateTime(year, month, day);
  }
}

class _DummyIslandMeta {
  const _DummyIslandMeta(this.title, this.color);

  final String title;
  final Color color;
}
