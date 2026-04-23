import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel(this.repository);

  final CalendarRepository repository;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  List<CalendarIslandFilter> _islandFilters = const [];
  bool _isLoading = false;
  String? _errorText;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDay => _selectedDay;
  List<CalendarIslandFilter> get islandFilters =>
      List.unmodifiable(_islandFilters);
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;
  int get selectedIslandCount =>
      _islandFilters.where((item) => item.isSelected).length;

  Future<void> load() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      _islandFilters = await repository.fetchIslandFilters();
    } catch (error) {
      _errorText = error.toString();
      _islandFilters = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToPreviousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  void jumpToToday() {
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    _focusedMonth = DateTime(day.year, day.month);
    notifyListeners();
  }

  void toggleIslandSelection(String islandId) {
    _islandFilters = _islandFilters
        .map(
          (item) => item.id == islandId
              ? item.copyWith(isSelected: !item.isSelected)
              : item,
        )
        .toList();
    notifyListeners();
  }
}
