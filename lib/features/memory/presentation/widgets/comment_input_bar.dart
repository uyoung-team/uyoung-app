import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/sticker_selector.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CommentInputBar extends StatefulWidget {
  const CommentInputBar({
    super.key,
    required this.selectedSticker,
    required this.onStickerSelected,
    required this.onStickerRemoved,
    required this.onSend,
    required this.onOpenComments,
  });

  final String? selectedSticker;
  final ValueChanged<String> onStickerSelected;
  final VoidCallback onStickerRemoved;
  final ValueChanged<String> onSend;
  final VoidCallback onOpenComments;

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  bool _isInputMode = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        constraints: const BoxConstraints(minHeight: 120),
        child: _isInputMode ? _commentInputUI() : _defaultButtons(context),
      ),
    );
  }

  Widget _defaultButtons(BuildContext context) {
    return Row(
      children: [
        _circleButton(
          assetPath: AssetPaths.icons.photoDetail.imoji,
          onTap: () {
            setState(() => _isInputMode = true);
          },
        ),
        const SizedBox(width: 6),
        _circleButton(
          assetPath: AssetPaths.icons.photoDetail.comment,
          onTap: widget.onOpenComments,
        ),
        const SizedBox(width: 6),
        _circleButton(assetPath: AssetPaths.icons.photoDetail.favorite),
      ],
    );
  }

  Widget _commentInputUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StickerSelector(
          selectedSticker: widget.selectedSticker,
          onSelect: widget.onStickerSelected,
          onRemove: widget.onStickerRemoved,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.bg02,
              child: Icon(Icons.person_outline, color: AppColors.g02),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.bg02, width: 1.5),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '느끼는 감정을 적어 주세요!',
                    hintStyle: AppFont.b8_14.copyWith(color: AppColors.g03),
                    border: InputBorder.none,
                  ),
                  style: AppFont.b8_14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _controller.text.trim().isEmpty
                  ? null
                  : () {
                      final text = _controller.text.trim();
                      widget.onSend(text);
                      _controller.clear();
                      setState(() => _isInputMode = false);
                    },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.b03,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  size: 18,
                  color: AppColors.b01,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleButton({
    required String assetPath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.bg02, width: 1.5),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
