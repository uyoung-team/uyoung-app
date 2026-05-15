import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';

class ChangeDaySheet extends StatefulWidget {
  const ChangeDaySheet({super.key});

  @override
  State<ChangeDaySheet> createState() => _ChangeDaySheetState();
}

class _ChangeDaySheetState extends State<ChangeDaySheet> {
  bool _showTimePicker = false;

  int _ampmIndex = 0;
  int _hour = 4;
  int _minute = 7;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.back,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('취소', style: AppFont.b7_16),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('저장', style: AppFont.b7_16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _dateRow(
                      title: '원본',
                      value: '2025. 10.12 오전 4:07:23',
                      isDisabled: true,
                    ),
                    const Divider(height: 1),
                    _dateRow(
                      title: '조정',
                      value:
                          '2025. 10.12 ${_ampmIndex == 0 ? '오전' : '오후'} $_hour:${_minute.toString().padLeft(2, '0')}',
                      isDisabled: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('2025년 8월', style: AppFont.b7_16),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _WeekText('일', color: AppColors.subRed03),
                        _WeekText('월'),
                        _WeekText('화'),
                        _WeekText('수'),
                        _WeekText('목'),
                        _WeekText('금'),
                        _WeekText('토', color: AppColors.b02),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(31, (index) {
                        final day = index + 1;
                        final isSelected = day == 16;
                        return Container(
                          width: 36,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.b02
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '$day',
                            style: AppFont.b9_12.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTimePicker = !_showTimePicker;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('시간', style: AppFont.b8_14),
                      Text(
                        '${_ampmIndex == 0 ? '오전' : '오후'} $_hour:${_minute.toString().padLeft(2, '0')}',
                        style: AppFont.b9_12.copyWith(color: AppColors.g02),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showTimePicker)
            Positioned(right: 20, bottom: 110, child: _timePickerPopup()),
        ],
      ),
    );
  }

  Widget _dateRow({
    required String title,
    required String value,
    required bool isDisabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppFont.b8_14),
          Text(
            value,
            style: AppFont.b8_14.copyWith(
              color: isDisabled ? AppColors.g03 : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timePickerPopup() {
    return Container(
      width: 260,
      height: 180,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _wheelPicker(
            items: const ['오전', '오후'],
            initialIndex: _ampmIndex,
            width: 60,
            onChanged: (i) => setState(() => _ampmIndex = i),
          ),
          _wheelPicker(
            items: List.generate(12, (i) => '${i + 1}'),
            initialIndex: _hour - 1,
            width: 50,
            onChanged: (i) => setState(() => _hour = i + 1),
          ),
          Text(':', style: AppFont.b6_18),
          _wheelPicker(
            items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            initialIndex: _minute,
            width: 60,
            onChanged: (i) => setState(() => _minute = i),
          ),
        ],
      ),
    );
  }

  Widget _wheelPicker({
    required List<String> items,
    required int initialIndex,
    required double width,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 140,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 36,
        perspective: 0.003,
        onSelectedItemChanged: onChanged,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (_, index) => Center(
            child: Text(
              items[index],
              style: AppFont.b7_16,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekText extends StatelessWidget {
  const _WeekText(this.text, {this.color = AppColors.black});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          text,
          style: AppFont.b9_12.copyWith(color: color),
        ),
      ),
    );
  }
}
