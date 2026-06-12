import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/photo_comment_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class CommentSheet extends StatelessWidget {
  const CommentSheet({
    super.key,
    required this.comments,
  });

  final List<PhotoCommentItem> comments;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
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
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView.separated(
        itemCount: comments.length,
        separatorBuilder: (_, _) => const Divider(height: 24, color: AppColors.bg02),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.bg02,
                backgroundImage: comment.avatarUrl != null &&
                        comment.avatarUrl!.isNotEmpty
                    ? NetworkImage(comment.avatarUrl!)
                    : null,
                child: comment.avatarUrl == null || comment.avatarUrl!.isEmpty
                    ? Text(
                        comment.nickname.isEmpty ? '?' : comment.nickname[0],
                        style: AppFont.b8_14.copyWith(color: AppColors.g02),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.nickname,
                            style: AppFont.b7_16.copyWith(color: AppColors.black),
                          ),
                        ),
                        Text(
                          _relativeTime(comment.createdAt),
                          style: AppFont.b9_12.copyWith(color: AppColors.g03),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.content,
                      style: AppFont.b8_14.copyWith(color: AppColors.black),
                    ),
                  ],
                ),
              ),
              if (comment.hasSticker) ...[
                const SizedBox(width: 10),
                Image.asset(
                  comment.stickerAsset!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  static String _relativeTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return '방금 전';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }
    return '${difference.inDays}일 전';
  }
}
