import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';
import 'package:uyoung_app/features/calendar/data/calendar_service.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_memory_island_manage_page.dart';
import 'package:uyoung_app/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:uyoung_app/features/calendar/presentation/widgets/calendar_memory_bottom_sheet.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CalendarViewModel(const CalendarRepository(CalendarService()))..load(),
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    return Scaffold(
      backgroundColor: AppColors.back,
      endDrawer: _CalendarFilterDrawer(viewModel: viewModel),
      body: SafeArea(
        child: Column(
          children: [
            _CalendarTopBar(viewModel: viewModel),
            const SizedBox(height: 10),
            _CalendarMonthHeader(viewModel: viewModel),
            const SizedBox(height: 18),
            const _WeekdayHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _CalendarGrid(viewModel: viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarTopBar extends StatelessWidget {
  const _CalendarTopBar({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            '캘린더',
            style: AppFont.b5_20.copyWith(color: AppColors.black),
          ),
          const Spacer(),
          Builder(
            builder: (context) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
            constraints: const BoxConstraints(),
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

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.viewModel});

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

    final days = _buildCalendarDays(viewModel.focusedMonth);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == viewModel.focusedMonth.month;
        final isSelected = _isSameDate(day, viewModel.selectedDay);
        final isToday = _isSameDate(day, DateTime.now());

        return GestureDetector(
          onTap: () {
            viewModel.openBottomSheet(day);
            _openMemoryBottomSheet(context, viewModel, day);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.b03 : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.b01, width: 1.2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: AppFont.b7_16.copyWith(
                    color: !isCurrentMonth
                        ? AppColors.g04
                        : day.weekday == DateTime.sunday
                        ? AppColors.subRed03
                        : AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                if (viewModel.hasAnyMemoryForDay(day))
                  Wrap(
                    spacing: 3,
                    children: List<Widget>.generate(
                      viewModel.memoriesForDay(day).take(3).length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: viewModel.memoriesForDay(day)[index].color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.b01 : AppColors.bg03,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = firstDay.weekday % 7;
    final startDay = firstDay.subtract(Duration(days: startOffset));

    return List<DateTime>.generate(
      42,
      (index) => DateUtils.addDaysToDate(startDay, index),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

void _openMemoryBottomSheet(
  BuildContext context,
  CalendarViewModel viewModel,
  DateTime date,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CalendarMemoryBottomSheet(
      date: date,
      groups: viewModel.memoriesForDay(date),
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
