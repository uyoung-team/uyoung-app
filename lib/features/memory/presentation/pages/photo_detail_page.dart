import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/comment_input_bar.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';

class PlacedSticker {
  PlacedSticker({
    required this.assetPath,
    required this.dxRatio,
    required this.dyRatio,
    this.size = 72,
  });

  final String assetPath;
  double dxRatio;
  double dyRatio;
  double size;
}

class PhotoDetailPage extends StatefulWidget {
  const PhotoDetailPage({
    super.key,
    required this.imagePath,
    this.uploaderName = '버블 메이트',
  });

  final String imagePath;
  final String uploaderName;

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  final List<PlacedSticker> _stickers = [];

  String? _pendingStickerAsset;
  double _pendingDxRatio = 0.5;
  double _pendingDyRatio = 0.6;
  final double _pendingSize = 72;
  double _photoWidth = 0;
  double _photoHeight = 530;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: _body(context),
      bottomNavigationBar: CommentInputBar(
        selectedSticker: _pendingStickerAsset,
        onStickerSelected: _onStickerSelected,
        onStickerRemoved: _onStickerRemoved,
        onSend: _onSend,
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          AppHeadlineText.h6('중국 상하이'),
          const SizedBox(height: 2),
          Text(
            '2025년 12월 13일 오후 3:38',
            style: AppFont.b9_12.copyWith(color: AppColors.g03),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              AssetPaths.icons.common.download,
              width: 24,
              height: 24,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: IconButton(
            onPressed: () => _showMoreSheet(context),
            icon: SvgPicture.asset(
              AssetPaths.icons.common.meatball,
              width: 22,
              height: 22,
            ),
          ),
        ),
      ],
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _moreItem(
                icon: Icons.schedule_rounded,
                label: '날짜 및 시간 조정',
              ),
              const SizedBox(height: 8),
              _moreItem(
                icon: Icons.location_on_outlined,
                label: '위치 조정',
              ),
              const SizedBox(height: 8),
              _moreItem(
                icon: Icons.delete_outline_rounded,
                label: '삭제하기',
                color: AppColors.subRed03,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moreItem({
    required IconData icon,
    required String label,
    Color color = AppColors.black,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bg02),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: AppFont.b7_16.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _photoArea(),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.bg02,
                  child: Icon(Icons.person_outline, color: AppColors.g02),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.uploaderName} 업로드',
                  style: AppFont.b8_14.copyWith(color: AppColors.g03),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    AssetPaths.icons.photoDetail.favorite,
                    width: 28,
                    height: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _photoArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _photoWidth = constraints.maxWidth;
        _photoHeight = 530;

        return SizedBox(
          width: double.infinity,
          height: _photoHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(widget.imagePath),
              for (final sticker in _stickers)
                _placedStickerWidget(sticker, _photoWidth, _photoHeight),
              if (_pendingStickerAsset != null)
                _pendingStickerWidget(_photoWidth, _photoHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.g05),
    );
  }

  Widget _placedStickerWidget(
    PlacedSticker sticker,
    double photoWidth,
    double photoHeight,
  ) {
    final left = (photoWidth - sticker.size) * sticker.dxRatio;
    final top = (photoHeight - sticker.size) * sticker.dyRatio;

    return Positioned(
      left: left,
      top: top,
      child: Image.asset(
        sticker.assetPath,
        width: sticker.size,
        height: sticker.size,
      ),
    );
  }

  Widget _pendingStickerWidget(double photoWidth, double photoHeight) {
    final left = (photoWidth - _pendingSize) * _pendingDxRatio;
    final top = (photoHeight - _pendingSize) * _pendingDyRatio;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final nextLeft = (left + details.delta.dx).clamp(
              0.0,
              photoWidth - _pendingSize,
            );
            final nextTop = (top + details.delta.dy).clamp(
              0.0,
              photoHeight - _pendingSize,
            );
            _pendingDxRatio = (nextLeft / (photoWidth - _pendingSize)).clamp(
              0.0,
              1.0,
            );
            _pendingDyRatio = (nextTop / (photoHeight - _pendingSize)).clamp(
              0.0,
              1.0,
            );
          });
        },
        child: Opacity(
          opacity: 0.92,
          child: Image.asset(
            _pendingStickerAsset!,
            width: _pendingSize,
            height: _pendingSize,
          ),
        ),
      ),
    );
  }

  void _onStickerSelected(String assetPath) {
    setState(() {
      _pendingStickerAsset = assetPath;
    });
  }

  void _onStickerRemoved() {
    setState(() {
      _pendingStickerAsset = null;
    });
  }

  void _onSend() {
    if (_pendingStickerAsset == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('선택한 스티커나 댓글이 없어요.')),
        );
      return;
    }

    setState(() {
      _stickers.add(
        PlacedSticker(
          assetPath: _pendingStickerAsset!,
          dxRatio: _pendingDxRatio,
          dyRatio: _pendingDyRatio,
          size: _pendingSize,
        ),
      );
      _pendingStickerAsset = null;
    });
  }
}
