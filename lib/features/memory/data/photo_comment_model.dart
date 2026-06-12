class PhotoCommentItem {
  const PhotoCommentItem({
    required this.id,
    required this.photoId,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.createdAt,
    this.avatarUrl,
    this.stickerAsset,
    this.stickerDxRatio,
    this.stickerDyRatio,
    this.stickerSize,
  });

  final String id;
  final String photoId;
  final String userId;
  final String nickname;
  final String content;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? stickerAsset;
  final double? stickerDxRatio;
  final double? stickerDyRatio;
  final double? stickerSize;

  bool get hasSticker => stickerAsset != null && stickerAsset!.isNotEmpty;
}
