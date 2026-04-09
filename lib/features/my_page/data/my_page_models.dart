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
