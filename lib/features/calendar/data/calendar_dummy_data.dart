import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/memory/data/memory_dummy_adapter.dart';

class CalendarDummyData {
  const CalendarDummyData._();

  static List<CalendarIslandFilter> get islandFilters =>
      MemoryDummyAdapter.calendarIslandFilters();

  static List<CalendarEvent> memoriesForMonth(DateTime month) =>
      MemoryDummyAdapter.calendarEventsForMonth(month);
}
