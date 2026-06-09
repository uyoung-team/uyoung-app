import 'package:flutter/material.dart';
import 'package:uyoung_app/features/calendar/data/calendar_dummy_data.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel(
    this.repository, {
    DateTime? initialSelectedDay,
    Set<String>? initiallySelectedIslandIds,
    bool openBottomSheetInitially = false,
  }) : _focusedMonth = DateTime(
         (initialSelectedDay ?? DateTime.now()).year,
         (initialSelectedDay ?? DateTime.now()).month,
       ),
       _initialSelectedDay = initialSelectedDay == null
           ? null
           : DateTime(
               initialSelectedDay.year,
               initialSelectedDay.month,
               initialSelectedDay.day,
             ),
       _initialSelectedIslandIds = Set<String>.from(
         initiallySelectedIslandIds ?? const <String>{},
       ),
       _pendingInitialBottomSheet = openBottomSheetInitially;

  final CalendarRepository repository;

  DateTime _focusedMonth;
  DateTime? _selectedDay;
  List<CalendarIslandFilter> _islandFilters = const [];
  List<CalendarEvent> _allMemories = const [];
  bool _isLoading = false;
  bool _isBottomSheetOpen = false;
  String? _errorText;
  final DateTime? _initialSelectedDay;
  final Set<String> _initialSelectedIslandIds;
  bool _pendingInitialBottomSheet = false;
  bool _pendingProgrammaticBottomSheetOpen = false;

  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDay => _selectedDay;
  List<CalendarIslandFilter> get islandFilters =>
      List.unmodifiable(_islandFilters);
  bool get isLoading => _isLoading;
  bool get isBottomSheetOpen => _isBottomSheetOpen;
  String? get errorText => _errorText;
  bool get pendingProgrammaticBottomSheetOpen =>
      _pendingProgrammaticBottomSheetOpen;
  int get selectedIslandCount =>
      _islandFilters.where((item) => item.isSelected).length;

  Future<void> load() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final previousSelection = {
        for (final item in _islandFilters) item.id: item.isSelected,
      };
      final fetchedFilters = await repository.fetchIslandFilters();
      _allMemories = await repository.fetchMemories(_focusedMonth);

      _islandFilters = fetchedFilters.map((item) {
        if (previousSelection.containsKey(item.id)) {
          return item.copyWith(
            isSelected: previousSelection[item.id] ?? item.isSelected,
          );
        }
        if (_initialSelectedIslandIds.isNotEmpty) {
          return item.copyWith(
            isSelected: _initialSelectedIslandIds.contains(item.id),
          );
        }
        return item;
      }).toList();

      final filterIds = _islandFilters.map((item) => item.id).toSet();
      final memoryIslandIds = _allMemories.map((item) => item.islandId).toSet();
      final hasMatchingIslandIds = filterIds.any(memoryIslandIds.contains);

      if (_allMemories.isNotEmpty && !hasMatchingIslandIds) {
        _islandFilters = CalendarDummyData.islandFilters;
      }

      if (_selectedDay == null && _initialSelectedDay != null) {
        _selectedDay = _initialSelectedDay;
      }

      final initialDate = _initialSelectedDay;
      if (_pendingInitialBottomSheet && initialDate != null) {
        if (hasMemory(initialDate)) {
          openBottomSheet(initialDate, programmatic: true);
        }
        _pendingInitialBottomSheet = false;
      }
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
    load(); // 달이 바뀌면 다시 로드
  }

  void goToNextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    load(); // 달이 바뀌면 다시 로드
  }

  void jumpToToday() {
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    load();
  }

  void setFocusedMonth(DateTime month) {
    _focusedMonth = DateTime(month.year, month.month);
    load();
  }

  void clearSelectedDay() {
    _selectedDay = null;
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    _focusedMonth = DateTime(day.year, day.month);
    notifyListeners();
  }

  void openBottomSheet(DateTime day, {bool programmatic = false}) {
    selectDay(day);
    _isBottomSheetOpen = true;
    _pendingProgrammaticBottomSheetOpen = programmatic;
    notifyListeners();
  }

  void closeBottomSheet() {
    if (!_isBottomSheetOpen) {
      return;
    }
    _isBottomSheetOpen = false;
    _pendingProgrammaticBottomSheetOpen = false;
    notifyListeners();
  }

  void consumePendingProgrammaticBottomSheet() {
    _pendingProgrammaticBottomSheetOpen = false;
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

  void reorderIslands(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _islandFilters.length) {
      return;
    }
    if (newIndex < 0 || newIndex > _islandFilters.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _islandFilters.removeAt(oldIndex);
    _islandFilters.insert(newIndex, item);
    notifyListeners();
  }

  void toggleAlert(String islandId, bool enabled) {
    _islandFilters = _islandFilters
        .map(
          (item) =>
              item.id == islandId ? item.copyWith(alertEnabled: enabled) : item,
        )
        .toList();
    notifyListeners();
  }

  List<Color> getDotColors(DateTime day) {
    return memoriesForDay(day).map((group) => group.color).toList();
  }

  String? getThumbnailPath(DateTime day) {
    final groups = memoriesForDay(day);
    if (groups.isEmpty || groups.first.thumbnailPaths.isEmpty) {
      return null;
    }
    return groups.first.thumbnailPaths.first;
  }

  bool hasMemory(DateTime day) {
    return memoriesForDay(day).isNotEmpty;
  }

  List<CalendarDayMemoryGroup> memoriesForDay(DateTime day) {
    // 선택된 섬 아이디 목록
    final selectedIslands = _islandFilters.where((item) => item.isSelected);
    final selectedIslandIds = selectedIslands.map((e) => e.id).toSet();

    // 해당 날짜의 메모리 필터링
    final dayMemories = _allMemories.where(
      (m) =>
          m.date.year == day.year &&
          m.date.month == day.month &&
          m.date.day == day.day &&
          selectedIslandIds.contains(m.islandId),
    );

    // 섬별로 그룹화
    final Map<String, List<String>> grouped = {};
    for (final m in dayMemories) {
      if (m.imageUrl != null) {
        grouped.update(
          m.islandId,
          (list) => list..add(m.imageUrl!),
          ifAbsent: () => [m.imageUrl!],
        );
      }
    }

    return selectedIslands
        .where((island) => grouped.containsKey(island.id))
        .map((island) {
          return CalendarDayMemoryGroup(
            islandId: island.id,
            islandName: island.name,
            color: island.color,
            thumbnailPaths: grouped[island.id] ?? const [],
          );
        })
        .toList();
  }

  bool hasAnyMemoryForDay(DateTime day) {
    return hasMemory(day);
  }
}
