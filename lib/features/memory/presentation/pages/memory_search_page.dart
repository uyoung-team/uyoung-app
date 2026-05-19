import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_detail_page.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class MemorySearchPage extends StatefulWidget {
  const MemorySearchPage({
    super.key,
    required this.items,
  });

  final List<MemoryIslandItem> items;

  @override
  State<MemorySearchPage> createState() => _MemorySearchPageState();
}

class _MemorySearchPageState extends State<MemorySearchPage> {
  static const List<String> _recentSearches = [
    '최보빈',
    '우정포에버',
    '이윤서',
    '한승하',
    '인덕대 솔모임',
    '오키나와 팸',
    '일본',
  ];

  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = _query.trim().toLowerCase();
    final filteredItems = widget.items.where((item) {
      if (trimmedQuery.isEmpty) {
        return true;
      }

      final memberNames = item.members.map((member) => member.nickname).join(' ');
      return item.title.toLowerCase().contains(trimmedQuery) ||
          memberNames.toLowerCase().contains(trimmedQuery);
    }).toList();

    final recentItems = [...widget.items]
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }
        return (b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0));
      });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppHeadlineText('기억섬 검색', style: AppFont.h5_20),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => setState(() => _query = value),
                    style: AppFont.b6_18.copyWith(color: AppColors.black),
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요.',
                      hintStyle: AppFont.b6_18.copyWith(color: AppColors.g03),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _query = _controller.text),
                  icon: const Icon(Icons.search_rounded, color: AppColors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.bg02),
            const SizedBox(height: 16),
            Text(
              '최근 검색어',
              style: AppFont.b6_18.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _recentSearches.map((label) {
                return GestureDetector(
                  onTap: () {
                    _controller.text = label;
                    setState(() => _query = label);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.bg02),
                    ),
                    child: Text(
                      label,
                      style: AppFont.b7_16.copyWith(color: AppColors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              trimmedQuery.isEmpty ? '최근 자주 찾는 기억' : '검색 결과',
              style: AppFont.b6_18.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: (filteredItems.isEmpty && trimmedQuery.isNotEmpty)
                  ? Center(
                      child: Text(
                        '검색 결과가 없습니다.',
                        style: AppFont.b8_14.copyWith(color: AppColors.g02),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: trimmedQuery.isEmpty
                          ? recentItems.take(4).length
                          : filteredItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) {
                        final item = trimmedQuery.isEmpty
                            ? recentItems.take(4).toList()[index]
                            : filteredItems[index];
                        return _SearchMemoryCard(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMemoryCard extends StatelessWidget {
  const _SearchMemoryCard({required this.item});

  final MemoryIslandItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MemoryDetailPage(item: item),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bg02),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? Image.network(
                        item.imagePath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _SearchMemoryFallback(isFavorite: item.isFavorite),
                      )
                    : _SearchMemoryFallback(isFavorite: item.isFavorite),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppHeadlineText(
                      item.title.isEmpty ? '이름 없는 기억섬' : item.title,
                      style: AppFont.h8_14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.members.isEmpty
                          ? '참여 멤버 없음'
                          : item.members.map((member) => member.nickname).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFont.b9_12.copyWith(color: AppColors.g02),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMemoryFallback extends StatelessWidget {
  const _SearchMemoryFallback({required this.isFavorite});

  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isFavorite ? AppColors.b03 : AppColors.bg03,
      alignment: Alignment.center,
      child: Icon(
        isFavorite ? Icons.star_rounded : Icons.landscape_rounded,
        color: isFavorite ? AppColors.subYellow01 : AppColors.g03,
        size: 34,
      ),
    );
  }
}
