import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class CreateMemoryPage extends StatefulWidget {
  const CreateMemoryPage({super.key});

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  static const int _maxTitleLength = 12;
  static const List<String> _palette = [
    '#FF6B6B',
    '#FF8E72',
    '#FFB26B',
    '#FFD56B',
    '#F4E76E',
    '#A4D96C',
    '#5FCD8C',
    '#54D2C6',
    '#6FD3FF',
    '#6EA8EB',
    '#7C93FF',
    '#9A7CFF',
    '#B780FF',
    '#E08EFF',
    '#FF94C2',
    '#D7B48C',
    '#B6BDC6',
    '#8B9AA9',
    '#5D6D7E',
    '#2D3A4A',
  ];

  final TextEditingController _titleController = TextEditingController();
  String? _selectedColor;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _selectedColor != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(
              onBack: () => Navigator.pop(context),
              onPickGallery: () => _showPreparingSnackBar('배경 이미지 선택'),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppHeadlineText(
                    '어떤 기억을 담을\n섬을 만들까요?',
                    style: AppFont.h2_26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '바다 위에 새로운 섬이 떠오르고 있어요.',
                    style: AppFont.b8_14.copyWith(color: AppColors.g03),
                  ),
                  const SizedBox(height: 28),
                  Text('기억섬 이름', style: AppFont.b8_14),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 1,
                            color: _titleController.text.isEmpty
                                ? AppColors.g03
                                : AppColors.b02,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              onChanged: (_) => setState(() {}),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(_maxTitleLength),
                              ],
                              style: AppFont.b7_16.copyWith(color: AppColors.black),
                              decoration: InputDecoration(
                                hintText: '비워두면 친구 이름으로 자동 생성돼요',
                                hintStyle:
                                    AppFont.b7_16.copyWith(color: AppColors.g03),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${_titleController.text.length}/$_maxTitleLength',
                              style: AppFont.b8_14.copyWith(color: AppColors.g03),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('기억섬 컬러', style: AppFont.b8_14),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _palette.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 34,
                          height: 34,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _hexToColor(color),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: canProceed
                          ? () => _showPreparingSnackBar('멤버 선택/생성')
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor:
                            canProceed ? AppColors.b02 : AppColors.bg02,
                        disabledBackgroundColor: AppColors.bg02,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '다음',
                        style: AppFont.b6_18.copyWith(
                          color: canProceed ? AppColors.white : AppColors.g03,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreparingSnackBar(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$label 기능은 다음 단계에서 이어서 구현할게요.')),
      );
  }

  Color _hexToColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.onBack,
    required this.onPickGallery,
  });

  final VoidCallback onBack;
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          color: AppColors.bg02,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: AppColors.white,
            size: 48,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: AppColors.white,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: AppHeadlineText(
                        '기억섬 만들기',
                        style: AppFont.h5_20.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: onPickGallery,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
