import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_local_photo.dart';

class MemoryPhotoThumbnail extends StatelessWidget {
  const MemoryPhotoThumbnail({super.key, required this.photo});

  final MemoryLocalPhoto photo;

  @override
  Widget build(BuildContext context) {
    if (photo.isLocalFile) {
      return Image.file(
        File(photo.path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
      );
    }

    if (photo.path.startsWith('http://') || photo.path.startsWith('https://')) {
      return Image.network(
        photo.path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
      );
    }

    return Image.asset(
      photo.path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
    );
  }
}
