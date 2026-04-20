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
