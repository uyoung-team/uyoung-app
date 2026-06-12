import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';

class LocationSheet extends StatefulWidget {
  const LocationSheet({
    super.key,
    this.originalLocation = '위치 정보 없음',
    this.adjustedLocation = '위치 정보 없음',
  });

  final String originalLocation;
  final String adjustedLocation;

  @override
  State<LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<LocationSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _hasKeyword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
              color: AppColors.back,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow('원본', widget.originalLocation, isDisabled: true),
                const Divider(height: 1),
                _infoRow('조정', widget.adjustedLocation, isDisabled: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.back,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: AppColors.g03),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        _hasKeyword = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '새로운 위치 입력',
                      hintStyle: AppFont.b8_14.copyWith(color: AppColors.g03),
                      border: InputBorder.none,
                    ),
                    style: AppFont.b8_14,
                  ),
                ),
                if (_hasKeyword)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() => _hasKeyword = false);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.g03,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_hasKeyword)
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, separatorIndex) =>
                    const Divider(height: 1, color: AppColors.bg03),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('한강진역', style: AppFont.b7_16),
                        const SizedBox(height: 4),
                        Text(
                          '대한민국 서울특별시 용산구 한남동 728-22,043',
                          style: AppFont.b8_14.copyWith(
                            color: AppColors.g02,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {required bool isDisabled}) {
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
}
