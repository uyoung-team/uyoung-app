import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/home/data/shell_story_dummy.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class TodayShellStoryPage extends StatefulWidget {
  const TodayShellStoryPage({super.key});

  @override
  State<TodayShellStoryPage> createState() => _TodayShellStoryPageState();
}

class _TodayShellStoryPageState extends State<TodayShellStoryPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AssetPaths.images.shellStory.background,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 8),
                _AppBarRow(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 12),
                const _TitleSection(),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: todayShellFrameContents.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (_, index) =>
                        _FramePage(content: todayShellFrameContents[index]),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    todayShellFrameContents.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Image.asset(
                        index == _currentPage
                            ? AssetPaths.images.shellStory.filledIndicator
                            : AssetPaths.images.shellStory.emptyIndicator,
                        width: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(
                    height: 130,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Image.asset(
                          AssetPaths.images.shellStory.progressAlert,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 64, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '조개가 기억으로 가득 차면, 진주가 탄생해요!',
                                style: AppFont.h7_16,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '현재 이 기억섬의 달성률은 32 %',
                                style: AppFont.b8_14.copyWith(
                                  color: AppColors.g02,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  const _AppBarRow({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const Spacer(),
          Image.asset(AssetPaths.images.shellStory.menu, width: 24),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetPaths.images.shellStory.leftShell, width: 18),
            const SizedBox(width: 6),
            Text(
              '조개 속에 넣을 오늘의 이야기',
              style: AppFont.b8_14.copyWith(color: AppColors.g02),
            ),
            const SizedBox(width: 6),
            Image.asset(AssetPaths.images.shellStory.rightShell, width: 18),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '최근 우리가 제일 웃겼던\n순간은 언제였을까?',
          textAlign: TextAlign.center,
          style: AppFont.h4_22,
        ),
      ],
    );
  }
}

class _FramePage extends StatelessWidget {
  const _FramePage({required this.content});

  final ShellFrameContent content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(AssetPaths.images.shellStory.contentFrame, fit: BoxFit.contain),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(content.imagePath, width: 180, height: 180),
              const SizedBox(height: 12),
              Text(content.title, style: AppFont.h6_18, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                content.actionText,
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
              const SizedBox(height: 28),
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.bg02),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(content.profileImagePath, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.bg02),
                    ),
                    child: Text(
                      content.name,
                      style: AppFont.h7_16.copyWith(color: AppColors.b01),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
