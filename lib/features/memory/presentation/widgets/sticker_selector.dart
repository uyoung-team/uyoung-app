import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';

class StickerSelector extends StatelessWidget {
  const StickerSelector({
    super.key,
    required this.selectedSticker,
    required this.onSelect,
    required this.onRemove,
  });

  final String? selectedSticker;
  final ValueChanged<String> onSelect;
  final VoidCallback onRemove;

  static const List<String> _stickers = [
    'assets/images/character/character_emoticon_01.png',
    'assets/images/character/character_emoticon_02.png',
    'assets/images/character/character_emoticon_03.png',
    'assets/images/character/character_emoticon_04.png',
    'assets/images/character/character_emoticon_05.png',
    'assets/images/character/character_emoticon_06.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bg02, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _stickers.map((path) {
          final isSelected = selectedSticker == path;
          return GestureDetector(
            onTap: () => onSelect(path),
            onLongPress: isSelected ? onRemove : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.b02Op01 : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(path, fit: BoxFit.contain),
            ),
          );
        }).toList(),
      ),
    );
  }
}
