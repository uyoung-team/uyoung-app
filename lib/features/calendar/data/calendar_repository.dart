import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/calendar/data/calendar_dummy_data.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_service.dart';

class CalendarRepository {
  const CalendarRepository(this.service);

  final CalendarService service;

  Future<List<CalendarIslandFilter>> fetchIslandFilters() async {
    try {
      final rows = await service.fetchIslandRows();
      if (rows.isEmpty) {
        return CalendarDummyData.islandFilters;
      }

      final filters = rows
          .map((row) {
            final island = Map<String, dynamic>.from(
              (row['islands'] as Map?) ?? const <String, dynamic>{},
            );

            return CalendarIslandFilter(
              id: island['id']?.toString() ?? '',
              name: island['name']?.toString() ?? '이름 없는 기억섬',
              color: CalendarService.colorFromHex(
                island['theme_color']?.toString(),
              ),
              isSelected: true,
              alertEnabled: true,
            );
          })
          .where((item) => item.id.isNotEmpty)
          .toList();

      return filters.isEmpty ? CalendarDummyData.islandFilters : filters;
    } catch (error) {
      debugPrint('Calendar island filters fetch error: $error');
      return CalendarDummyData.islandFilters;
    }
  }

  Future<List<CalendarEvent>> fetchMemories(DateTime month) async {
    try {
      final rows = await service.fetchMemoriesForMonth(month);
      if (rows.isEmpty) {
        return CalendarDummyData.memoriesForMonth(month);
      }

      final events = rows.map((row) {
        final eventDate = row['event_date']?.toString();
        return CalendarEvent(
          id: row['id']?.toString() ?? '',
          islandId: row['island_id']?.toString() ?? '',
          title: row['title']?.toString() ?? '',
          date:
              eventDate == null || eventDate.isEmpty
              ? month
              : DateTime.tryParse(eventDate) ?? month,
          imageUrl: row['image_url']?.toString(),
          type: row['type']?.toString() ?? 'memory',
        );
      }).toList();

      return events.isEmpty ? CalendarDummyData.memoriesForMonth(month) : events;
    } catch (error) {
      debugPrint('Calendar memories fetch error: $error');
      return CalendarDummyData.memoriesForMonth(month);
    }
  }
}
