import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/home/data/shell_story_dummy.dart';
import 'package:uyoung_app/features/home/data/shell_story_model.dart';
import 'package:uyoung_app/features/home/presentation/pages/today_shell_story_page.dart';
import 'package:uyoung_app/features/home/presentation/pages/unfinished_shell_story_list_page.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class ShellStoryPage extends StatelessWidget {
  const ShellStoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('조개 이야기', style: AppFont.h5_20),
        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('필터 기능은 준비 중이에요.')),
                );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset(
                AssetPaths.images.shellStory.filter,
                width: 42,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PromoSection(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UnfinishedShellStoryListPage(),
                  ),
                );
              },
            ),
            const _StorySection(),
          ],
        ),
      ),
    );
  }
}

class _PromoSection extends StatelessWidget {
  const _PromoSection({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 170,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '아직 완성되지 않은\n조개 이야기를 확인해 봐요!',
                      style: AppFont.h4_22,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '자세히 보기 >',
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -30,
                bottom: -10,
                child: Image.asset(
                  AssetPaths.images.shellStory.promo,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('우리의 조개 이야기', style: AppFont.h6_18),
              Text(
                '총 ${shellStories.length} 개',
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: shellStories
              .map((story) => _StoryCard(story: story))
              .toList(),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final ShellStory story;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const TodayShellStoryPage(),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                story.imagePath,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  AssetPaths.images.shellStory.frame,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Text(
                      story.tag,
                      style: AppFont.h8_14.copyWith(color: const Color(0xFFF0F0F0)),
                    ),
                  ),
                  Text(
                    story.title,
                    style: AppFont.h5_20.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.date,
                    style: AppFont.h8_14.copyWith(color: const Color(0xFFCCCCCC)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
