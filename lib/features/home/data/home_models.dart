enum HomeNotificationType {
  invite,
  activity,
  notice,
  unknown;

  static HomeNotificationType fromValue(String? value) {
    switch (value) {
      case 'invite':
        return HomeNotificationType.invite;
      case 'activity':
        return HomeNotificationType.activity;
      case 'notice':
        return HomeNotificationType.notice;
      default:
        return HomeNotificationType.unknown;
    }
  }
}

class HomeNotification {
  const HomeNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String userId;
  final HomeNotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory HomeNotification.fromMap(Map<String, dynamic> map) {
    final title =
        (map['title'] ??
                map['category'] ??
                map['notification_title'] ??
                '') as String;
    final body =
        (map['body'] ??
                map['message'] ??
                map['content'] ??
                map['notification_body'] ??
                '') as String;

    return HomeNotification(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      type: HomeNotificationType.fromValue(map['type'] as String?),
      title: title,
      body: body,
      isRead: map['is_read'] == true,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }

  HomeNotification copyWith({
    String? id,
    String? userId,
    HomeNotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return HomeNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
