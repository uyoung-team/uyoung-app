import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/pages/select_member_page.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/create_memory_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class CreateMemoryPage extends StatefulWidget {
  const CreateMemoryPage({super.key});

  @override
  State<CreateMemoryPage> createState() => _CreateMemoryPageState();
}

class _CreateMemoryPageState extends State<CreateMemoryPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateMemoryViewModel(
        repository: const MemoryRepository(MemoryService()),
      ),
      child: const _CreateMemoryStepOneView(),
    );
  }
}

class _CreateMemoryStepOneView extends StatelessWidget {
  const _CreateMemoryStepOneView();

  Future<void> _pickImage(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) {
      return;
    }

    await context.read<CreateMemoryViewModel>().setSelectedImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateMemoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(
              imageBytes: vm.selectedImageBytes,
              onBack: () => Navigator.pop(context),
              onPickGallery: () => _pickImage(context),
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
                            color: vm.titleController.text.isEmpty
                                ? AppColors.g03
                                : AppColors.b02,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: vm.titleController,
                              onChanged: (_) => vm.onTitleChanged(),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                  CreateMemoryViewModel.maxTitleLength,
                                ),
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
                              '${vm.titleController.text.length}/${CreateMemoryViewModel.maxTitleLength}',
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
                    children: CreateMemoryViewModel.palette.map((color) {
                      final isSelected = vm.selectedColor == color;
                      return GestureDetector(
                        onTap: () => vm.setColor(color),
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
                      onPressed: vm.canProceedToMembers
                          ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: vm,
                                    child: const SelectMemberPage(),
                                  ),
                                ),
                              );

                              if (!context.mounted || result == null) {
                                return;
                              }

                              Navigator.pop(context, result);
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor:
                            vm.canProceedToMembers ? AppColors.b02 : AppColors.bg02,
                        disabledBackgroundColor: AppColors.bg02,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '다음',
                        style: AppFont.b6_18.copyWith(
                          color: vm.canProceedToMembers
                              ? AppColors.white
                              : AppColors.g03,
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
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.imageBytes,
    required this.onBack,
    required this.onPickGallery,
  });

  final Uint8List? imageBytes;
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
          child: imageBytes == null
              ? const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.white,
                    size: 48,
                  ),
                )
              : Image.memory(imageBytes!, fit: BoxFit.cover),
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

Color _hexToColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}
