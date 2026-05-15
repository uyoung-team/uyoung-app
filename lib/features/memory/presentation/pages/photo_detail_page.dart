import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/change_day_sheet.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/comment_input_bar.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/location_sheet.dart';
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
    this.uploaderProfile,
  });

  final String imagePath;
  final String uploaderName;
  final String? uploaderProfile;

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  final double _popupWidth = 220;
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
    final GlobalKey moreKey = GlobalKey();

    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
        onPressed: () => Navigator.pop(context),
      ),
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
          child: GestureDetector(
            key: moreKey,
            onTap: () => _showMorePopup(context, moreKey),
            child: SvgPicture.asset(
              AssetPaths.icons.common.meatball,
              width: 22,
              height: 22,
            ),
          ),
        ),
      ],
    );
  }

  void _showMorePopup(BuildContext context, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    double left = position.dx - (_popupWidth - size.width);
    if (left < 16) left = 16;
    if (left + _popupWidth > screenWidth) {
      left = screenWidth - _popupWidth - 16;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      barrierDismissible: true,
      builder: (_) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: position.dy,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: _popupWidth,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _popupItem(
                        iconPath: AssetPaths.icons.bar.calendar,
                        label: '날짜 및 시간 조정',
                        onTap: () {
                          Navigator.pop(context);
                          _showChangeDaySheet(context);
                        },
                      ),
                      _divider(),
                      _popupItem(
                        iconPath: AssetPaths.icons.bar.location,
                        label: '위치 조정',
                        onTap: () {
                          Navigator.pop(context);
                          _showLocationSheet(context);
                        },
                      ),
                      _divider(),
                      _popupItem(
                        iconPath: AssetPaths.icons.common.delete,
                        label: '삭제하기',
                        color: AppColors.subRed03,
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangeDaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangeDaySheet(),
    );
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationSheet(),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('삭제하기', style: AppFont.b5_20),
          content: Text(
            '이 사진을 삭제할까요?',
            style: AppFont.b8_14.copyWith(color: AppColors.g02),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('취소', style: AppFont.b8_14),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.subRed03,
              ),
              child: Text(
                '삭제',
                style: AppFont.b8_14.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('사진을 삭제했어요.')));
    }
  }

  Widget _popupItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppFont.b7_16.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.bg03);

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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.bg02,
                  backgroundImage: widget.uploaderProfile != null &&
                          widget.uploaderProfile!.isNotEmpty
                      ? AssetImage(widget.uploaderProfile!)
                      : null,
                  child: widget.uploaderProfile == null ||
                          widget.uploaderProfile!.isEmpty
                      ? const Icon(Icons.person_outline, color: AppColors.g02)
                      : null,
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
