import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class UnfinishedShellStoryCard extends StatelessWidget {
  const UnfinishedShellStoryCard({
    super.key,
    required this.imagePath,
    required this.tag,
    this.onTap,
  });

  final String imagePath;
  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.25),
                BlendMode.darken,
              ),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                AssetPaths.images.shellStory.unfinishedFrame,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 19,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white),
                ),
                child: Text(
                  tag,
                  style: AppFont.h9_12.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '최근 우리가 제일 웃겼던\n순간은 언제였을까?',
                  textAlign: TextAlign.center,
                  style: AppFont.h4_22.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
