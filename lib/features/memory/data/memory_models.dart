class MemoryMemberPreview {
  const MemoryMemberPreview({
    required this.id,
    required this.nickname,
    this.avatarUrl,
  });

  final String id;
  final String nickname;
  final String? avatarUrl;

  factory MemoryMemberPreview.fromMap(Map<String, dynamic> map) {
    return MemoryMemberPreview(
      id: (map['id'] ?? '').toString(),
      nickname: (map['nickname'] ?? '').toString(),
      avatarUrl: map['avatar_url']?.toString() ?? map['avatarUrl']?.toString(),
    );
  }
}

class MemoryIslandItem {
  const MemoryIslandItem({
    required this.id,
    required this.title,
    required this.isFavorite,
    required this.isNotificationOn,
    this.imagePath,
    this.updatedAt,
    this.inviteCode,
    this.members = const [],
  });

  final String id;
  final String title;
  final bool isFavorite;
  final bool isNotificationOn;
  final String? imagePath;
  final DateTime? updatedAt;
  final String? inviteCode;
  final List<MemoryMemberPreview> members;
}

class InviteeUser {
  const InviteeUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.userCode,
  });

  final String id;
  final String nickname;
  final String? avatarUrl;
  final String userCode;

  factory InviteeUser.fromMap(Map<String, dynamic> map) {
    return InviteeUser(
      id: (map['id'] ?? '').toString(),
      nickname: (map['nickname'] ?? '').toString(),
      avatarUrl: map['avatar_url']?.toString(),
      userCode: (map['user_code'] ?? '').toString(),
    );
  }

  String get displayName => nickname.isNotEmpty ? nickname : userCode;
}

class FavoritePhoto {
  const FavoritePhoto({
    required this.id,
    required this.islandId,
    required this.userId,
    required this.photoKey,
    required this.createdAt,
  });

  final String id;
  final String islandId;
  final String userId;
  final String photoKey;
  final DateTime? createdAt;

  factory FavoritePhoto.fromMap(Map<String, dynamic> map) {
    return FavoritePhoto(
      id: (map['id'] ?? '').toString(),
      islandId: (map['island_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      photoKey: (map['photo_key'] ?? '').toString(),
      createdAt: map['created_at'] is String
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}

class MemoryPhotoSeed {
  const MemoryPhotoSeed({
    required this.path,
    required this.createdAt,
    required this.uploaderName,
    this.profileImagePath,
  });

  final String path;
  final DateTime createdAt;
  final String uploaderName;
  final String? profileImagePath;
}
