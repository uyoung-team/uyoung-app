import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_repository.dart';
import 'package:uyoung_app/features/calendar/data/calendar_service.dart';
import 'package:uyoung_app/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

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
                child: Column(
                  children: [
                    Expanded(
                      child: _CalendarGrid(viewModel: viewModel),
                    ),
                    const SizedBox(height: 14),
                    _SelectedDaySummary(viewModel: viewModel),
                    const SizedBox(height: 14),
                  ],
                ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
      child: Row(
        children: [
          AppHeadlineText.h5('캘린더'),
          const Spacer(),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: SvgPicture.asset(
                  AssetPaths.icons.common.filter,
                  width: 36,
                  height: 36,
                ),
              );
            },
          ),
          IconButton(
            onPressed: viewModel.jumpToToday,
            icon: SvgPicture.asset(
              AssetPaths.icons.common.today,
              width: 36,
              height: 36,
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          IconButton(
            onPressed: viewModel.goToPreviousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Center(
              child: AppHeadlineText.h6(monthText),
            ),
          ),
          IconButton(
            onPressed: viewModel.goToNextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: labels
            .map(
              (label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppFont.b8_14.copyWith(
                      color: label == '일' ? AppColors.subRed03 : AppColors.g02,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
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
          onTap: () => viewModel.selectDay(day),
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
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.b01
                        : AppColors.bg03,
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

class _SelectedDaySummary extends StatelessWidget {
  const _SelectedDaySummary({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final label =
        '${viewModel.selectedDay.month}월 ${viewModel.selectedDay.day}일';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bg02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeadlineText.h7(label),
          const SizedBox(height: 6),
          Text(
            viewModel.selectedIslandCount == 0
                ? '선택된 기억섬이 없어요.'
                : '${viewModel.selectedIslandCount}개의 기억섬을 기준으로 기록을 보여줄 준비가 되었어요.',
            style: AppFont.b8_14.copyWith(
              color: viewModel.selectedIslandCount == 0
                  ? AppColors.g03
                  : AppColors.g02,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarFilterDrawer extends StatelessWidget {
  const _CalendarFilterDrawer({required this.viewModel});

  final CalendarViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  AppHeadlineText.h6('기억섬 필터'),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '표시할 기억섬을 선택하면 이후 캘린더 기록을 더 쉽게 좁혀볼 수 있어요.',
                style: AppFont.b8_14.copyWith(
                  color: AppColors.g02,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: viewModel.islandFilters.isEmpty
                  ? Center(
                      child: Text(
                        '선택할 기억섬이 아직 없어요.',
                        style: AppFont.b8_14.copyWith(color: AppColors.g03),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemBuilder: (context, index) {
                        final item = viewModel.islandFilters[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => viewModel.toggleIslandSelection(item.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: item.isSelected
                                  ? item.color.withValues(alpha: 0.14)
                                  : AppColors.back,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: item.isSelected
                                    ? item.color
                                    : AppColors.bg02,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppFont.b7_16.copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  item.isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: item.isSelected
                                      ? item.color
                                      : AppColors.g04,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemCount: viewModel.islandFilters.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
