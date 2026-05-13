import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/calendar/data/calendar_models.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class CalendarMemoryIslandDetailPage extends StatefulWidget {
  const CalendarMemoryIslandDetailPage({
    super.key,
    required this.group,
    required this.date,
  });

  final CalendarDayMemoryGroup group;
  final DateTime date;

  @override
  State<CalendarMemoryIslandDetailPage> createState() =>
      _CalendarMemoryIslandDetailPageState();
}

class _CalendarMemoryIslandDetailPageState
    extends State<CalendarMemoryIslandDetailPage> {
  late List<String> _thumbnailPaths;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _thumbnailPaths = List<String>.from(widget.group.thumbnailPaths);
  }

  void _toggleSelectionMode() {
    setState(() {
      if (_isSelectionMode) {
        _isSelectionMode = false;
        _selectedIndexes.clear();
      } else {
        _isSelectionMode = true;
      }
    });
  }

  void _onTapThumb(int index) {
    if (!_isSelectionMode) {
      return;
    }

    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndexes.isEmpty) {
      return;
    }

    setState(() {
      final sortedIndexes = _selectedIndexes.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final index in sortedIndexes) {
        if (index >= 0 && index < _thumbnailPaths.length) {
          _thumbnailPaths.removeAt(index);
        }
      }
      _selectedIndexes.clear();
      if (_thumbnailPaths.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.back,
      bottomNavigationBar: _isSelectionMode
          ? Container(
              height: 86,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.bg03, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        '${_selectedIndexes.length}장의 사진이 선택됨',
                        style: AppFont.b6_18.copyWith(color: AppColors.black),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _selectedIndexes.isEmpty ? null : _deleteSelected,
                          child: Opacity(
                            opacity: _selectedIndexes.isEmpty ? 0.3 : 1,
                            child: SvgPicture.asset(
                              AssetPaths.icons.bar.delete,
                              width: 18,
                              height: 18,
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.group.islandName,
                          style: AppFont.h6_18.copyWith(color: AppColors.black),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
                          style: AppFont.b9_12.copyWith(color: AppColors.g03),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _isSelectionMode
                          ? TextButton(
                              onPressed: _toggleSelectionMode,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '삭제',
                                style: AppFont.b8_14.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: _toggleSelectionMode,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              constraints: const BoxConstraints(),
                              icon: SvgPicture.asset(
                                AssetPaths.icons.common.check,
                                width: 20,
                                height: 20,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.builder(
                  itemCount: _thumbnailPaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final path = _thumbnailPaths[index];
                    final isSelected = _selectedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () => _onTapThumb(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              path,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const ColoredBox(
                                color: AppColors.bg03,
                              ),
                            ),
                            if (isSelected)
                              Container(color: const Color(0x33000000)),
                            if (isSelected)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: SvgPicture.asset(
                                  AssetPaths.icons.common.check,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
