import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/core/theme/app_font.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';
import 'package:uyoung_app/features/memory/data/photo_comment_model.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/change_day_sheet.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/comment_sheet.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/location_sheet.dart';
import 'package:uyoung_app/features/memory/presentation/widgets/sticker_selector.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';
import 'package:uyoung_app/shared/widgets/app_headline_text.dart';
import 'package:uyoung_app/shared/widgets/app_top_bar_icon_button.dart';

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
    this.islandId,
    this.photoId,
    this.uploaderName = '버블 메이트',
    this.description,
    this.uploaderProfile,
    this.takenAt,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  final String imagePath;
  final String? islandId;
  final String? photoId;
  final String uploaderName;
  final String? description;
  final String? uploaderProfile;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  final double _popupWidth = 220;
  final List<PlacedSticker> _stickers = [];
  final MemoryRepository _repository = const MemoryRepository(MemoryService());
  final List<PhotoCommentItem> _comments = [];

  String? _pendingStickerAsset;
  double _photoWidth = 0;
  double _photoHeight = 530;
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;
  bool _isLoadingComments = false;
  bool _isInputMode = false;
  final TextEditingController _commentController = TextEditingController();
  String? _editingCommentId;
  int? _editingLocalStickerIndex;
  String? _editingStickerAsset;
  double _editingDxRatio = 0.12;
  double _editingDyRatio = 0.14;
  double _editingSize = 88;
  bool _isSavingStickerPosition = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadFavoriteState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final photoId = widget.photoId;
    if (photoId == null || photoId.isEmpty) {
      return;
    }

    setState(() => _isLoadingComments = true);
    try {
      final comments = await _repository.fetchPhotoComments(photoId);
      if (!mounted) {
        return;
      }
      setState(() {
        _comments
          ..clear()
          ..addAll(comments);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingComments = false);
      }
    }
  }

  Future<void> _loadFavoriteState() async {
    final islandId = widget.islandId;
    if (islandId == null || islandId.isEmpty) {
      return;
    }

    try {
      final favorites = await _repository.fetchFavoritePhotos(islandId);
      if (!mounted) {
        return;
      }

      setState(() {
        _isFavorite = favorites.any((photo) => photo.photoKey == widget.imagePath);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    final GlobalKey moreKey = GlobalKey();

    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AppTopBarIconButton(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.black, size: 20),
        ),
      ),
      centerTitle: true,
      title: Column(
        children: [
          AppHeadlineText.h6(_displayLocation),
          const SizedBox(height: 2),
          Text(
            _displayTakenAt,
            style: AppFont.b9_12.copyWith(color: AppColors.g03),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AppTopBarIconButton(
            onTap: () {},
            child: SvgPicture.asset(
              AssetPaths.icons.common.download,
              width: 24,
              height: 24,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: KeyedSubtree(
            key: moreKey,
            child: AppTopBarIconButton(
              onTap: () => _showMorePopup(context, moreKey),
              child: SvgPicture.asset(
                AssetPaths.icons.common.meatball,
                width: 24,
                height: 24,
              ),
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
                        iconPath: AssetPaths.icons.common.folderPlus,
                        label: '앨범에 담기',
                        onTap: () {
                          Navigator.pop(context);
                          _showAlbumPicker(context);
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
      builder: (_) => LocationSheet(
        originalLocation: _displayLocation,
        adjustedLocation: _displayLocation,
      ),
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

  Future<void> _toggleFavorite() async {
    final islandId = widget.islandId;
    if (islandId == null || islandId.isEmpty) {
      return;
    }

    final previous = _isFavorite;
    setState(() {
      _isTogglingFavorite = true;
      _isFavorite = !previous;
    });

    try {
      final isFavorite = await _repository.toggleFavoritePhoto(
        islandId: islandId,
        photoKey: widget.imagePath,
      );
      if (!mounted) {
        return;
      }
      setState(() => _isFavorite = isFavorite);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isFavorite = previous);
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  Future<void> _showAlbumPicker(BuildContext context) async {
    final islandId = widget.islandId;
    final photoId = widget.photoId;
    if (islandId == null || islandId.isEmpty || photoId == null || photoId.isEmpty) {
      return;
    }

    final albums = await _repository.fetchAlbums(islandId);
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: albums.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '먼저 앨범을 하나 만들어주세요.',
                      style: AppFont.b8_14.copyWith(color: AppColors.g02),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final album in albums) ...[
                        ListTile(
                          title: Text(album.name, style: AppFont.b7_16),
                          subtitle: Text(
                            '사진 ${album.photoCount}장',
                            style: AppFont.b9_12.copyWith(color: AppColors.g02),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await _repository.addPhotosToAlbum(
                              albumId: album.id,
                              photoIds: [photoId],
                            );
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text('${album.name} 앨범에 담았어요.')),
                              );
                          },
                        ),
                        if (album != albums.last)
                          const Divider(height: 1, color: AppColors.bg03),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _photoArea(),
          const SizedBox(height: 18),
          if ((widget.description ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.description!.trim(),
                  style: AppFont.b8_14.copyWith(color: AppColors.black),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _isInputMode ? _inputComposer() : _defaultInfoRow(),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _defaultInfoRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.bg02,
              backgroundImage: _uploaderProfileImage(),
              child: widget.uploaderProfile == null || widget.uploaderProfile!.isEmpty
                  ? const Icon(Icons.person_outline, color: AppColors.g02)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.uploaderName} 업로드',
                style: AppFont.b8_14.copyWith(color: AppColors.g03),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _detailActionButton(
              imagePath: 'assets/images/smile.png',
              onTap: () => setState(() => _isInputMode = true),
            ),
            const SizedBox(width: 6),
            _detailActionButton(
              imagePath: 'assets/images/comment.png',
              onTap: _openCommentsSheet,
            ),
            const SizedBox(width: 6),
            _detailActionButton(
              imagePath: 'assets/images/star.png',
              onTap: _isTogglingFavorite ? null : _toggleFavorite,
              tint: _isFavorite ? AppColors.b01 : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _inputComposer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StickerSelector(
          selectedSticker: _pendingStickerAsset,
          onSelect: _onStickerSelected,
          onRemove: _onStickerRemoved,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.bg02,
              backgroundImage: _uploaderProfileImage(),
              child: widget.uploaderProfile == null || widget.uploaderProfile!.isEmpty
                  ? const Icon(Icons.person_outline, color: AppColors.g02)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.bg02, width: 1.5),
                ),
                child: TextField(
                  controller: _commentController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '느끼는 감정을 적어 주세요!',
                    hintStyle: AppFont.b8_14.copyWith(color: AppColors.g03),
                    border: InputBorder.none,
                  ),
                  style: AppFont.b8_14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: (_pendingStickerAsset == null &&
                      _commentController.text.trim().isEmpty)
                  ? null
                  : () => _onSend(_commentController.text.trim()),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.b03,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  size: 18,
                  color: AppColors.b01,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailActionButton({
    required String imagePath,
    required VoidCallback? onTap,
    Color? tint,
  }) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bg02, width: 2),
          ),
          child: Center(
          child: tint == null
              ? Image.asset(imagePath, width: 23, height: 23)
              : ColorFiltered(
                  colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                  child: Image.asset(imagePath, width: 23, height: 23),
                ),
        ),
      ),
    );
  }

  String get _displayLocation {
    if (widget.locationName != null && widget.locationName!.isNotEmpty) {
      return widget.locationName!;
    }
    if (widget.latitude != null && widget.longitude != null) {
      return '${widget.latitude!.toStringAsFixed(4)}, ${widget.longitude!.toStringAsFixed(4)}';
    }
    return '위치 정보 없음';
  }

  String get _displayTakenAt {
    final takenAt = widget.takenAt;
    if (takenAt == null) {
      return '시간 정보 없음';
    }

    final period = takenAt.hour < 12 ? '오전' : '오후';
    final hour = takenAt.hour % 12 == 0 ? 12 : takenAt.hour % 12;
    final minute = takenAt.minute.toString().padLeft(2, '0');
    return '${takenAt.year}년 ${takenAt.month}월 ${takenAt.day}일 $period $hour:$minute';
  }

  ImageProvider<Object>? _uploaderProfileImage() {
    final path = widget.uploaderProfile;
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  Widget _photoArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _photoWidth = constraints.maxWidth;
        _photoHeight = 530;

        return SizedBox(
          width: double.infinity,
          height: _photoHeight,
          child: GestureDetector(
            onTap: _clearStickerEditing,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(widget.imagePath),
                for (final comment in _comments.where((item) => item.hasSticker))
                  if (_editingCommentId != comment.id)
                    _persistedStickerWidget(comment, _photoWidth, _photoHeight),
                for (int index = 0; index < _stickers.length; index++)
                  if (_editingLocalStickerIndex != index)
                    _placedStickerWidget(index, _stickers[index], _photoWidth, _photoHeight),
                if (_editingStickerAsset != null)
                  _editingStickerWidget(_photoWidth, _photoHeight),
              ],
            ),
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
    int index,
    PlacedSticker sticker,
    double photoWidth,
    double photoHeight,
  ) {
    final left = (photoWidth - sticker.size) * sticker.dxRatio;
    final top = (photoHeight - sticker.size) * sticker.dyRatio;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onLongPress: () => _startEditingLocalSticker(index, sticker),
        child: Image.asset(
          sticker.assetPath,
          width: sticker.size,
          height: sticker.size,
        ),
      ),
    );
  }

  Widget _persistedStickerWidget(
    PhotoCommentItem comment,
    double photoWidth,
    double photoHeight,
  ) {
    final size = comment.stickerSize ?? 72;
    final dxRatio = comment.stickerDxRatio ?? 0.5;
    final dyRatio = comment.stickerDyRatio ?? 0.6;
    final left = (photoWidth - size) * dxRatio;
    final top = (photoHeight - size) * dyRatio;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onLongPress: () => _startEditingPersistedSticker(comment),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              comment.stickerAsset!,
              width: size,
              height: size,
            ),
            if (comment.content.trim().isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  comment.content,
                  style: AppFont.b8_14.copyWith(color: AppColors.black),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _editingStickerWidget(double photoWidth, double photoHeight) {
    final left = (photoWidth - _editingSize) * _editingDxRatio;
    final top = (photoHeight - _editingSize) * _editingDyRatio;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onLongPressStart: (_) {},
        onPanUpdate: (details) {
          setState(() {
            final nextLeft = (left + details.delta.dx).clamp(
              0.0,
              photoWidth - _editingSize,
            );
            final nextTop = (top + details.delta.dy).clamp(
              0.0,
              photoHeight - _editingSize,
            );
            _editingDxRatio = (nextLeft / (photoWidth - _editingSize)).clamp(
              0.0,
              1.0,
            );
            _editingDyRatio = (nextTop / (photoHeight - _editingSize)).clamp(
              0.0,
              1.0,
            );
          });
        },
        onPanEnd: (_) => _persistStickerEditing(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _adjustIcon(
                    Icons.close,
                    onTap: _deleteEditingSticker,
                  ),
                ),
                const SizedBox(height: 6),
                Image.asset(
                  _editingStickerAsset!,
                  width: _editingSize,
                  height: _editingSize,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _adjustIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.b02,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: AppColors.white,
        ),
      ),
    );
  }

  void _clearStickerEditing() {
    if (_editingCommentId == null && _editingLocalStickerIndex == null) {
      return;
    }
    setState(() {
      _editingCommentId = null;
      _editingLocalStickerIndex = null;
      _editingStickerAsset = null;
      _isSavingStickerPosition = false;
    });
  }

  void _startEditingPersistedSticker(PhotoCommentItem comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editingLocalStickerIndex = null;
      _editingStickerAsset = comment.stickerAsset;
      _editingDxRatio = comment.stickerDxRatio ?? 0.5;
      _editingDyRatio = comment.stickerDyRatio ?? 0.6;
      _editingSize = comment.stickerSize ?? 72;
    });
  }

  void _startEditingLocalSticker(int index, PlacedSticker sticker) {
    setState(() {
      _editingCommentId = null;
      _editingLocalStickerIndex = index;
      _editingStickerAsset = sticker.assetPath;
      _editingDxRatio = sticker.dxRatio;
      _editingDyRatio = sticker.dyRatio;
      _editingSize = sticker.size;
    });
  }

  Future<void> _persistStickerEditing() async {
    if (_editingCommentId == null || _isSavingStickerPosition) {
      if (_editingLocalStickerIndex != null &&
          _editingLocalStickerIndex! >= 0 &&
          _editingLocalStickerIndex! < _stickers.length) {
        setState(() {
          _stickers[_editingLocalStickerIndex!].dxRatio = _editingDxRatio;
          _stickers[_editingLocalStickerIndex!].dyRatio = _editingDyRatio;
          _stickers[_editingLocalStickerIndex!].size = _editingSize;
        });
      }
      return;
    }

    setState(() => _isSavingStickerPosition = true);
    try {
      final updated = await _repository.updatePhotoComment(
        commentId: _editingCommentId!,
        stickerDxRatio: _editingDxRatio,
        stickerDyRatio: _editingDyRatio,
        stickerSize: _editingSize,
      );
      if (!mounted) {
        return;
      }
      final index = _comments.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        setState(() {
          _comments[index] = updated;
          _isSavingStickerPosition = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSavingStickerPosition = false);
    }
  }

  Future<void> _deleteEditingSticker() async {
    if (_editingLocalStickerIndex != null &&
        _editingLocalStickerIndex! >= 0 &&
        _editingLocalStickerIndex! < _stickers.length) {
      setState(() {
        _stickers.removeAt(_editingLocalStickerIndex!);
        _editingLocalStickerIndex = null;
        _editingStickerAsset = null;
      });
      return;
    }

    final commentId = _editingCommentId;
    if (commentId == null) {
      return;
    }

    try {
      await _repository.deletePhotoComment(commentId);
      if (!mounted) {
        return;
      }
      setState(() {
        _comments.removeWhere((item) => item.id == commentId);
        _editingCommentId = null;
        _editingStickerAsset = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
    }
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

  void _openCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 750,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: _isLoadingComments
              ? const Center(child: CircularProgressIndicator())
              : CommentSheet(comments: _comments),
        );
      },
    );
  }

  Future<void> _onSend(String commentText) async {
    if (_pendingStickerAsset == null && commentText.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('선택한 스티커나 댓글이 없어요.')),
        );
      return;
    }

    try {
      final photoId = widget.photoId;
      if (photoId == null || photoId.isEmpty) {
        if (_pendingStickerAsset != null) {
          setState(() {
            _stickers.add(
              PlacedSticker(
                assetPath: _pendingStickerAsset!,
                dxRatio: 0.5,
                dyRatio: 0.6,
                size: 72,
              ),
            );
            _pendingStickerAsset = null;
            _commentController.clear();
            _isInputMode = false;
          });
        }
        return;
      }
      final comment = await _repository.createPhotoComment(
        photoId: photoId,
        content: commentText.trim(),
        stickerAsset: _pendingStickerAsset,
        stickerDxRatio: _pendingStickerAsset == null ? null : 0.5,
        stickerDyRatio: _pendingStickerAsset == null ? null : 0.6,
        stickerSize: _pendingStickerAsset == null ? null : 72,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _comments.insert(0, comment);
        _pendingStickerAsset = null;
        _commentController.clear();
        _isInputMode = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('댓글을 남겼어요.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
    }
  }
}
