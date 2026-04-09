class MyPageProfile {
  const MyPageProfile({
    required this.nickname,
    required this.userCode,
    this.profileImageUrl,
    required this.pearlCount,
  });

  final String nickname;
  final String userCode;
  final String? profileImageUrl;
  final int pearlCount;

  factory MyPageProfile.empty() {
    return const MyPageProfile(
      nickname: '사용자',
      userCode: '-',
      profileImageUrl: null,
      pearlCount: 0,
    );
  }
}

class NoticeItem {
  const NoticeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.isImportant,
    this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isImportant;
  final DateTime? createdAt;
}

class InquiryItem {
  const InquiryItem({
    required this.id,
    required this.title,
    required this.status,
    this.answer,
    this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String? answer;
  final DateTime? createdAt;
}
