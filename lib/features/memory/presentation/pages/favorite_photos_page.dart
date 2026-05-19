import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/presentation/pages/photo_detail_page.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/presentation/viewmodels/favorite_photo_view_model.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class FavoritePhotosPage extends StatelessWidget {
  const FavoritePhotosPage({
    super.key,
    required this.islandId,
  });

  final String islandId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoritePhotoViewModel(
        islandId: islandId,
        repository: const MemoryRepository(MemoryService()),
      )..load(),
      child: const _FavoritePhotosView(),
    );
  }
}

class _FavoritePhotosView extends StatelessWidget {
  const _FavoritePhotosView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritePhotoViewModel>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppHeadlineText('즐겨찾는 사진', style: AppFont.h5_20),
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorText != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  viewModel.errorText!,
                  textAlign: TextAlign.center,
                  style: AppFont.b8_14.copyWith(color: AppColors.subRed03),
                ),
              ),
            );
          }

          if (viewModel.photos.isEmpty) {
            return Center(
              child: Text(
                '아직 즐겨찾기한 사진이 없어요',
                style: AppFont.b7_16.copyWith(color: AppColors.g03),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: viewModel.photos.length,
            itemBuilder: (_, index) => _FavoritePhotoTile(
              photoKey: viewModel.photos[index].photoKey,
            ),
          );
        },
      ),
    );
  }
}

class _FavoritePhotoTile extends StatelessWidget {
  const _FavoritePhotoTile({required this.photoKey});

  final String photoKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PhotoDetailPage(imagePath: photoKey),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.g05),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (photoKey.startsWith('http://') || photoKey.startsWith('https://')) {
      return Image.network(
        photoKey,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _FavoritePhotoPlaceholder(),
      );
    }

    return Image.asset(
      photoKey,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _FavoritePhotoPlaceholder(),
    );
  }
}

class _FavoritePhotoPlaceholder extends StatelessWidget {
  const _FavoritePhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.g04,
        size: 36,
      ),
    );
  }
}
