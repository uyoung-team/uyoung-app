import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';

class MemoryPostEditPage extends StatefulWidget {
  const MemoryPostEditPage({
    super.key,
    required this.islandId,
    required this.repository,
    required this.initialPhotos,
  });

  final String islandId;
  final MemoryRepository repository;
  final List<MemoryLocalPhoto> initialPhotos;

  @override
  State<MemoryPostEditPage> createState() => _MemoryPostEditPageState();
}

class _MemoryPostEditPageState extends State<MemoryPostEditPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final List<MemoryLocalPhoto> _existingPhotos = [];
  final List<MemoryLocalPhoto> _removedExistingPhotos = [];
  final List<XFile> _newImages = [];
  final List<Uint8List> _newImageBytes = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _existingPhotos.addAll(widget.initialPhotos);
    _descriptionController.text = (widget.initialPhotos.firstOrNull?.description ?? '').trim();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(limit: 20);
    if (!mounted || files.isEmpty) {
      return;
    }

    final nextFiles = <XFile>[..._newImages];
    final nextBytes = <Uint8List>[..._newImageBytes];
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
      _newImages
        ..clear()
        ..addAll(nextFiles);
      _newImageBytes
        ..clear()
        ..addAll(nextBytes);
    });
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      _removedExistingPhotos.add(_existingPhotos.removeAt(index));
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
      _newImageBytes.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final hasAnyPhoto = _existingPhotos.isNotEmpty || _newImages.isNotEmpty;
    if (!hasAnyPhoto) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('최소 한 장의 사진이 필요해요.')));
      return;
    }

    setState(() => _isSaving = true);
    final nextDescription = _descriptionController.text.trim();

    try {
      final removedIds = _removedExistingPhotos
          .map((photo) => photo.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
      if (removedIds.isNotEmpty) {
        await widget.repository.deletePost(
          photoIds: removedIds,
          imageUrls: _removedExistingPhotos.map((photo) => photo.path).toList(),
        );
      }

      final remainingIds = _existingPhotos
          .map((photo) => photo.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
      if (remainingIds.isNotEmpty) {
        await widget.repository.updatePostDescription(
          photoIds: remainingIds,
          description: nextDescription.isEmpty ? null : nextDescription,
        );
      }

      final uploadedPhotos = <MemoryLocalPhoto>[];
      for (final image in _newImages) {
        final uploaded = await widget.repository.uploadIslandPhoto(
          islandId: widget.islandId,
          imageFile: image,
          description: nextDescription.isEmpty ? null : nextDescription,
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

      final updatedExisting = _existingPhotos
          .map(
            (photo) => MemoryLocalPhoto(
              id: photo.id,
              path: photo.path,
              createdAt: photo.createdAt,
              uploaderName: photo.uploaderName,
              uploaderProfile: photo.uploaderProfile,
              isLocalFile: photo.isLocalFile,
              description: nextDescription.isEmpty ? null : nextDescription,
              takenAt: photo.takenAt,
              latitude: photo.latitude,
              longitude: photo.longitude,
              locationName: photo.locationName,
            ),
          )
          .toList();

      Navigator.of(context).pop(<MemoryLocalPhoto>[
        ...updatedExisting,
        ...uploadedPhotos,
      ]);
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _existingPhotos.length + _newImages.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('게시글 수정', style: AppFont.h3_24),
        actions: [
          TextButton(
            onPressed: totalCount == 0 || _isSaving ? null : _save,
            child: Text(
              _isSaving ? '저장 중...' : '저장',
              style: AppFont.b7_16.copyWith(
                color: totalCount == 0 || _isSaving ? AppColors.g03 : AppColors.b02,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text('사진 추가', style: AppFont.b8_14),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.bg02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (totalCount > 0)
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: totalCount,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            if (index < _existingPhotos.length) {
                              final photo = _existingPhotos[index];
                              return _ExistingPhotoCard(
                                photo: photo,
                                onRemove: () => _removeExistingPhoto(index),
                              );
                            }

                            final newIndex = index - _existingPhotos.length;
                            return _NewPhotoCard(
                              bytes: _newImageBytes[newIndex],
                              onRemove: () => _removeNewImage(newIndex),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.bg01,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.bg02),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, size: 38, color: AppColors.g02),
                            const SizedBox(height: 12),
                            Text(
                              '남겨둘 사진을 선택해주세요.',
                              style: AppFont.b8_14.copyWith(color: AppColors.g02),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      '설명',
                      style: AppFont.b7_16.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: 8),
                    TextField(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExistingPhotoCard extends StatelessWidget {
  const _ExistingPhotoCard({
    required this.photo,
    required this.onRemove,
  });

  final MemoryLocalPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isNetwork = photo.path.startsWith('http://') || photo.path.startsWith('https://');

    return SizedBox(
      width: 132,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: isNetwork
                ? Image.network(
                    photo.path,
                    width: 132,
                    height: 160,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    photo.path,
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

class _NewPhotoCard extends StatelessWidget {
  const _NewPhotoCard({
    required this.bytes,
    required this.onRemove,
  });

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
