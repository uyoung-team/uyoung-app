import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';

class MemoryUploadPage extends StatefulWidget {
  const MemoryUploadPage({
    super.key,
    required this.islandId,
    required this.repository,
  });

  final String islandId;
  final MemoryRepository repository;

  @override
  State<MemoryUploadPage> createState() => _MemoryUploadPageState();
}

class _MemoryUploadPageState extends State<MemoryUploadPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _previewBytes = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImages();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(limit: 20);
    if (!mounted) {
      return;
    }
    if (files.isEmpty) {
      if (_selectedImages.isEmpty) {
        Navigator.of(context).pop();
      }
      return;
    }

    final nextFiles = <XFile>[..._selectedImages];
    final nextBytes = <Uint8List>[..._previewBytes];
    for (final file in files) {
      final alreadyExists = nextFiles.any((item) => item.path == file.path);
      if (alreadyExists) {
        continue;
      }
      nextFiles.add(file);
      nextBytes.add(await file.readAsBytes());
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedImages
        ..clear()
        ..addAll(nextFiles);
      _previewBytes
        ..clear()
        ..addAll(nextBytes);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _previewBytes.removeAt(index);
    });

    if (_selectedImages.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _upload() async {
    if (_selectedImages.isEmpty || _isUploading) {
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploadedPhotos = <MemoryLocalPhoto>[];
      final description = _descriptionController.text.trim();

      for (final image in _selectedImages) {
        final uploaded = await widget.repository.uploadIslandPhoto(
          islandId: widget.islandId,
          imageFile: image,
          description: description.isEmpty ? null : description,
        );
        uploadedPhotos.add(
          MemoryLocalPhoto(
            id: uploaded.id,
            path: uploaded.path,
            createdAt: uploaded.createdAt,
            uploaderName: uploaded.uploaderName,
            uploaderProfile: uploaded.profileImagePath,
            isLocalFile: false,
            description: uploaded.description,
            takenAt: uploaded.takenAt,
            latitude: uploaded.latitude,
            longitude: uploaded.longitude,
            locationName: uploaded.locationName,
          ),
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(uploadedPhotos);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('게시물 추가', style: AppFont.h3_24),
        actions: [
          TextButton(
            onPressed: _selectedImages.isEmpty || _isUploading ? null : _upload,
            child: Text(
              _isUploading ? '업로드 중...' : '완료',
              style: AppFont.b7_16.copyWith(
                color: _selectedImages.isEmpty || _isUploading
                    ? AppColors.g03
                    : AppColors.b02,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 170,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return _AddMoreCard(onTap: _pickImages);
                    }
                    return _SelectedPhotoCard(
                      bytes: _previewBytes[index],
                      onRemove: () => _removeImage(index),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                '설명',
                style: AppFont.b7_16.copyWith(color: AppColors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _descriptionController,
                maxLength: 300,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '사진과 함께 남길 글을 적어보세요.',
                  hintStyle: AppFont.b8_14.copyWith(color: AppColors.g03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.bg02),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.bg02),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.b02),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: AppFont.b8_14.copyWith(color: AppColors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPhotoCard extends StatelessWidget {
  const _SelectedPhotoCard({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.memory(
              bytes,
              width: 132,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMoreCard extends StatelessWidget {
  const _AddMoreCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.bg01,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.bg02),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 30, color: AppColors.g02),
            const SizedBox(height: 10),
            Text('사진 더 선택', style: AppFont.b8_14.copyWith(color: AppColors.g02)),
          ],
        ),
      ),
    );
  }
}
