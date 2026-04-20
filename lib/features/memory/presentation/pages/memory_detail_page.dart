import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/presentation/pages/member_inquiry_page.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({
    super.key,
    required this.item,
  });

  final MemoryIslandItem item;

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  static const double _tabBarHeight = 52;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: selectedIndex == 0
          ? AppBar(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: AppHeadlineText(widget.item.title, style: AppFont.h5_20),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemberInquiryPage(islandId: widget.item.id),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.people_alt_outlined,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => selectedIndex = index),
            children: [
              _DetailTabPlaceholder(
                title: widget.item.title,
                subtitle: '이 섬의 전체 기억을 모아보는 화면이에요.',
                item: widget.item,
              ),
              _DetailTabPlaceholder(
                title: '일자별',
                subtitle: '날짜별로 추억을 정리해보는 화면이에요.',
                item: widget.item,
              ),
              _DetailTabPlaceholder(
                title: '타임라인',
                subtitle: '시간 흐름대로 기억을 살펴보는 화면이에요.',
                item: widget.item,
              ),
              _DetailTabPlaceholder(
                title: '즐겨찾기',
                subtitle: '즐겨찾은 사진과 기억을 모아보는 화면이에요.',
                item: widget.item,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: _tabBarHeight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(color: AppColors.bg02),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _modeButton('전체', 0)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('일자별', 1)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('타임라인', 2)),
                            const SizedBox(width: 6),
                            Expanded(child: _modeButton('즐겨찾기', 3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(content: Text('사진 추가는 다음 단계에서 연결할게요.')),
                        );
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.b02,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.b03 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppFont.b7_16.copyWith(
              color: isSelected ? AppColors.b02 : AppColors.g03,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTabPlaceholder extends StatelessWidget {
  const _DetailTabPlaceholder({
    required this.title,
    required this.subtitle,
    required this.item,
  });

  final String title;
  final String subtitle;
  final MemoryIslandItem item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.b03,
            borderRadius: BorderRadius.circular(20),
            image: item.imagePath != null && item.imagePath!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(item.imagePath!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: item.imagePath == null || item.imagePath!.isEmpty
              ? const Icon(
                  Icons.landscape_rounded,
                  color: AppColors.white,
                  size: 56,
                )
              : null,
        ),
        const SizedBox(height: 18),
        AppHeadlineText(title, style: AppFont.h4_22),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppFont.b8_14.copyWith(color: AppColors.g02),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '참여 멤버 ${item.members.length}',
                style: AppFont.b7_16.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 10),
              Text(
                item.members.isEmpty
                    ? '아직 연결된 멤버가 없습니다.'
                    : item.members.map((member) => member.nickname).join(', '),
                style: AppFont.b8_14.copyWith(color: AppColors.g02),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
