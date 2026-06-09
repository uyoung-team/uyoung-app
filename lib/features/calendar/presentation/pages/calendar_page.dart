import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';
import 'package:uyoung_app/features/calendar/data/calendar_service.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_memory_island_manage_page.dart';
import 'package:uyoung_app/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:uyoung_app/features/calendar/presentation/widgets/calendar_day_cell.dart';
import 'package:uyoung_app/features/calendar/presentation/widgets/calendar_memory_bottom_sheet.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({
    super.key,
    this.initialSelectedDay,
    this.initiallySelectedIslandIds,
    this.openBottomSheetInitially = false,
    this.showBackButton = false,
  });

  final DateTime? initialSelectedDay;
  final Set<String>? initiallySelectedIslandIds;
  final bool openBottomSheetInitially;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CalendarViewModel(
            const CalendarRepository(CalendarService()),
            initialSelectedDay: initialSelectedDay,
            initiallySelectedIslandIds: initiallySelectedIslandIds,
            openBottomSheetInitially: openBottomSheetInitially,
          )..load(),
      child: _CalendarView(showBackButton: showBackButton),
    );
  }
}

class _CalendarView extends StatefulWidget {
  const _CalendarView({required this.showBackButton});

  final bool showBackButton;

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  bool _openedInitialSheet = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    if (viewModel.pendingProgrammaticBottomSheetOpen &&
        viewModel.selectedDay != null &&
        !_openedInitialSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _openedInitialSheet) {
          return;
        }
        _openedInitialSheet = true;
        viewModel.consumePendingProgrammaticBottomSheet();
        _openMemoryBottomSheet(
          context,
          viewModel,
          viewModel.selectedDay!,
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      endDrawer: _CalendarFilterDrawer(viewModel: viewModel),
      body: SafeArea(
        child: Column(
          children: [
            _CalendarTopBar(
              viewModel: viewModel,
              showBackButton: widget.showBackButton,
            ),
            const SizedBox(height: 9),
            _CalendarMonthHeader(viewModel: viewModel),
            const SizedBox(height: 23),
            const _WeekdayHeader(),
            const SizedBox(height: 18),
            Expanded(child: _CalendarTableSection(viewModel: viewModel)),
          ],
        ),
      ),
    );
  }
}

class _CalendarTopBar extends StatelessWidget {
  const _CalendarTopBar({
    required this.viewModel,
    required this.showBackButton,
  });

  final CalendarViewModel viewModel;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
              onPressed: () => Navigator.of(context).pop(),
              icon: SvgPicture.asset(
                AssetPaths.icons.common.previous,
                width: 44,
                height: 44,
              ),
            )
          else
            const SizedBox(width: 8),
          Text(
            '캘린더',
            style: AppFont.h3_24.copyWith(color: AppColors.black),
          ),
          const Spacer(),
          Builder(
            builder: (context) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: SvgPicture.asset(
                  AssetPaths.icons.common.filter,
                  width: 44,
                  height: 44,
                ),
              );
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            onPressed: viewModel.jumpToToday,
            icon: SvgPicture.asset(
              AssetPaths.icons.common.today,
              width: 44,
              height: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final monthText =
        '${viewModel.focusedMonth.year}년 ${viewModel.focusedMonth.month}월';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            monthText,
            style: AppFont.b5_20.copyWith(color: AppColors.black),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _openMonthPicker(context, viewModel),
            child: const Icon(Icons.keyboard_arrow_down, size: 18),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: labels
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Center(
                      child: Text(
                        entry.value,
                        style: AppFont.b7_16.copyWith(
                          color: entry.key == 0
                              ? AppColors.subRed03
                              : entry.key == 6
                              ? AppColors.b01
                              : AppColors.black,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 7.5),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: AppColors.bg02,
          ),
        ],
      ),
    );
  }
}

class _CalendarTableSection extends StatelessWidget {
  const _CalendarTableSection({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            viewModel.errorText!,
            textAlign: TextAlign.center,
            style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
          ),
        ),
      );
    }

    final isCompact = viewModel.isBottomSheetOpen;
    final weeks = _weeksInMonth(viewModel.focusedMonth);
    final rowHeight = isCompact ? (weeks == 5 ? 45.0 : 40.0) : 95.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: viewModel.focusedMonth,
        locale: 'ko_KR',
        headerVisible: false,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        daysOfWeekVisible: false,
        sixWeekMonthsEnforced: false,
        availableGestures: AvailableGestures.horizontalSwipe,
        rowHeight: rowHeight,
        selectedDayPredicate: (day) =>
            viewModel.selectedDay != null &&
            _isSameDate(day, viewModel.selectedDay!),
        onDaySelected: (selectedDay, focusedDay) {
          viewModel.selectDay(selectedDay);
          if (!_isSameMonth(focusedDay, viewModel.focusedMonth)) {
            viewModel.setFocusedMonth(
              DateTime(focusedDay.year, focusedDay.month),
            );
          }

          if (viewModel.hasMemory(selectedDay)) {
            final groups = viewModel.memoriesForDay(selectedDay);
            viewModel.openBottomSheet(selectedDay);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              _openMemoryBottomSheet(
                context,
                viewModel,
                selectedDay,
                groups: groups,
              );
            });
          } else {
            viewModel.closeBottomSheet();
          }
        },
        onPageChanged: (focusedDay) {
          viewModel.setFocusedMonth(DateTime(focusedDay.year, focusedDay.month));
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) =>
              _buildCalendarCell(day, weeks, isCompact, false),
          selectedBuilder: (context, day, _) =>
              _buildCalendarCell(day, weeks, isCompact, true),
          todayBuilder: (context, day, _) =>
              _buildCalendarCell(
                day,
                weeks,
                isCompact,
                viewModel.selectedDay != null &&
                    _isSameDate(day, viewModel.selectedDay!),
                isToday: true,
              ),
          outsideBuilder: (context, day, _) =>
              _buildCalendarCell(day, weeks, isCompact, false, forceOutside: true),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    int weeks,
    bool isCompact,
    bool isSelected, {
    bool isToday = false,
    bool forceOutside = false,
  }) {
    return CalendarDayCell(
      date: day,
      isOutside: forceOutside || day.month != viewModel.focusedMonth.month,
      isSelected: isSelected,
      isToday: isToday,
      dotColors: viewModel.getDotColors(day),
      thumbnailPath: viewModel.getThumbnailPath(day),
      isCompactMode: isCompact,
      compactWeeks: weeks,
    );
  }

  int _weeksInMonth(DateTime day) {
    final firstOfMonth = DateTime(day.year, day.month, 1);
    final lastOfMonth = DateTime(day.year, day.month + 1, 0);

    DateTime start = firstOfMonth;
    while (start.weekday != DateTime.sunday) {
      start = start.subtract(const Duration(days: 1));
    }

    DateTime end = lastOfMonth;
    while (end.weekday != DateTime.saturday) {
      end = end.add(const Duration(days: 1));
    }

    final totalDays = end.difference(start).inDays + 1;
    return (totalDays / 7).ceil();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}

void _openMemoryBottomSheet(
  BuildContext context,
  CalendarViewModel viewModel,
  DateTime date,
  {
    List<CalendarDayMemoryGroup>? groups,
  }
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    builder: (_) => CalendarMemoryBottomSheet(
      date: date,
      groups: groups ?? viewModel.memoriesForDay(date),
    ),
  ).whenComplete(viewModel.closeBottomSheet);
}

void _openMonthPicker(BuildContext context, CalendarViewModel viewModel) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      int tempYear = viewModel.focusedMonth.year;
      int tempMonth = viewModel.focusedMonth.month;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: () {
                        setStateDialog(() => tempYear--);
                      },
                    ),
                    Text(
                      '$tempYear년',
                      style: AppFont.b5_20.copyWith(color: AppColors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: () {
                        setStateDialog(() => tempYear++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final isSelected = tempMonth == month;

                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() => tempMonth = month);
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.b01.withValues(alpha: 0.12)
                              : const Color(0xFFF3F4F7),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: AppColors.b01, width: 1)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$month월',
                          style: AppFont.b7_16.copyWith(
                            color: isSelected
                                ? AppColors.b01
                                : AppColors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          '취소',
                          style: AppFont.b7_16.copyWith(color: AppColors.g02),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.bg02,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          viewModel.setFocusedMonth(
                            DateTime(tempYear, tempMonth, 1),
                          );
                          viewModel.clearSelectedDay();
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          '확인',
                          style: AppFont.b7_16.copyWith(color: AppColors.b01),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _CalendarFilterDrawer extends StatelessWidget {
  const _CalendarFilterDrawer({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 312,
      backgroundColor: AppColors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '내 기억섬',
                    style: AppFont.b6_18.copyWith(color: AppColors.black),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const CalendarMemoryIslandManagePage(),
                          ),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      AssetPaths.icons.common.setting,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFE9E9ED),
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            const SizedBox(height: 16),
          Expanded(
              child: viewModel.islandFilters.isEmpty
                  ? Center(
                      child: Text(
                        '선택할 기억섬이 아직 없어요.',
                        style: AppFont.b8_14.copyWith(color: AppColors.g03),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemBuilder: (context, index) {
                        final item = viewModel.islandFilters[index];

                        return GestureDetector(
                          onTap: () => viewModel.toggleIslandSelection(item.id),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: item.isSelected
                                        ? Colors.transparent
                                        : const Color(0xFFD2D2D7),
                                    width: 1.5,
                                  ),
                                  color: item.isSelected
                                      ? item.color
                                      : AppColors.white,
                                ),
                                child: item.isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: AppColors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppFont.b7_16.copyWith(
                                    color: AppColors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 20),
                      itemCount: viewModel.islandFilters.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
