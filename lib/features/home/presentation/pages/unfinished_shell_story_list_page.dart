import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/home/data/shell_story_dummy.dart';
import 'package:uyoung_app/features/home/presentation/pages/today_shell_story_page.dart';
import 'package:uyoung_app/features/home/presentation/widgets/unfinished_shell_story_card.dart';

class UnfinishedShellStoryListPage extends StatelessWidget {
  const UnfinishedShellStoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('채우지 못 한 조개 이야기', style: AppFont.h5_20),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.25,
          children: unfinishedShellStorySeeds
              .map(
                (story) => UnfinishedShellStoryCard(
                  imagePath: story.imagePath,
                  tag: story.tag,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TodayShellStoryPage(),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
