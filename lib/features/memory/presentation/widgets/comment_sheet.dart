import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class CommentSheet extends StatelessWidget {
  const CommentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Column(
            children: [
              const CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.b03,
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 42,
                  color: AppColors.b02,
                ),
              ),
              const SizedBox(height: 24),
              AppHeadlineText.h4('아직 댓글이 없어요!'),
              const SizedBox(height: 6),
              Text(
                '첫번째 댓글을 남겨보세요.',
                style: AppFont.b7_16.copyWith(color: AppColors.g02),
              ),
            ],
          ),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
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
                Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
