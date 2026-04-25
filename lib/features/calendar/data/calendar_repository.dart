import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_service.dart';

class CalendarRepository {
  const CalendarRepository(this.service);

  final CalendarService service;

  Future<List<CalendarIslandFilter>> fetchIslandFilters() async {
    try {
      final rows = await service.fetchIslandRows();

      return rows.map((row) {
        final island = Map<String, dynamic>.from(
          (row['islands'] as Map?) ?? const <String, dynamic>{},
        );

        return CalendarIslandFilter(
          id: island['id']?.toString() ?? '',
          name: island['name']?.toString() ?? '이름 없는 기억섬',
          color: CalendarService.colorFromHex(island['theme_color']?.toString()),
          isSelected: true,
          alertEnabled: true,
        );
      }).where((item) => item.id.isNotEmpty).toList();
    } catch (error) {
      throw StateError('기억섬 목록을 불러오지 못했어요. $error');
    }
  }
}
