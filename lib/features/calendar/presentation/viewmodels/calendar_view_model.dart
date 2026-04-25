import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel(this.repository);

  final CalendarRepository repository;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  List<CalendarIslandFilter> _islandFilters = const [];
  bool _isLoading = false;
  bool _isBottomSheetOpen = false;
  String? _errorText;

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDay => _selectedDay;
  List<CalendarIslandFilter> get islandFilters =>
      List.unmodifiable(_islandFilters);
  bool get isLoading => _isLoading;
  bool get isBottomSheetOpen => _isBottomSheetOpen;
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

  void setFocusedMonth(DateTime month) {
    _focusedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    _focusedMonth = DateTime(day.year, day.month);
    notifyListeners();
  }

  void openBottomSheet(DateTime day) {
    selectDay(day);
    _isBottomSheetOpen = true;
    notifyListeners();
  }

  void closeBottomSheet() {
    if (!_isBottomSheetOpen) {
      return;
    }
    _isBottomSheetOpen = false;
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

  List<CalendarDayMemoryGroup> memoriesForDay(DateTime day) {
    final selectedIslands = _islandFilters.where((item) => item.isSelected);
    return selectedIslands
        .where((item) => _hasMemoryForDay(item, day))
        .map(
          (item) => CalendarDayMemoryGroup(
            islandId: item.id,
            islandName: item.name,
            color: item.color,
            thumbnailPaths: _thumbnailPathsForDay(item, day),
          ),
        )
        .toList();
  }

  bool hasAnyMemoryForDay(DateTime day) {
    return memoriesForDay(day).isNotEmpty;
  }

  bool _hasMemoryForDay(CalendarIslandFilter item, DateTime day) {
    final seed = item.id.hashCode + (day.month * 31) + day.day;
    return seed % 3 != 0;
  }

  List<String> _thumbnailPathsForDay(CalendarIslandFilter item, DateTime day) {
    final candidates = [
      AssetPaths.images.character.character01,
      AssetPaths.images.character.character02,
      AssetPaths.images.character.character03,
      AssetPaths.images.character.character04,
      AssetPaths.images.character.character05,
      AssetPaths.images.character.emoticon01,
      AssetPaths.images.character.emoticon02,
      AssetPaths.images.character.emoticon03,
      AssetPaths.images.character.emoticon04,
      AssetPaths.images.character.emoticon05,
      AssetPaths.images.character.emoticon06,
    ];

    final base = (item.id.hashCode.abs() + day.day + day.month) % candidates.length;
    final count = ((item.id.hashCode.abs() + day.day) % 4) + 1;

    return List<String>.generate(
      count,
      (index) => candidates[(base + index) % candidates.length],
    );
  }
}
