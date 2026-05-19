import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';

class MyPageRepository {
  const MyPageRepository(this.service);

  final MyPageService service;

  Future<MyPageProfile> fetchMyPageProfile() async {
    final profileRow = await service.fetchProfile();
    final assetRows = await service.fetchUserAssets();

    if (profileRow == null) {
      return MyPageProfile.empty();
    }

    return MyPageProfile(
      nickname: (profileRow['nickname'] ?? '사용자').toString(),
      userCode: (profileRow['user_code'] ?? '-').toString(),
      profileImageUrl: profileRow['profile_image_url']?.toString(),
      pearlCount: _extractPearlCount(assetRows),
    );
  }

  Future<bool> needsProfileSetup() async {
    final profileRow = await service.fetchProfile();
    if (profileRow == null) {
      return true;
    }

    final nickname = (profileRow['nickname'] ?? '').toString().trim();
    return nickname.isEmpty;
  }

  Future<void> updateProfile({
    required String nickname,
  }) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      throw StateError('닉네임을 입력해주세요.');
    }

    try {
      await service.updateProfile(nickname: trimmed);
    } catch (error) {
      throw StateError('프로필을 저장하지 못했어요. $error');
    }
  }

  Future<List<NoticeItem>> fetchNotices() async {
    final rows = await service.fetchNotices();

    return rows.map(_mapNoticeItem).toList();
  }

  Future<NoticeItem?> fetchNoticeDetail(String id) async {
    final row = await service.fetchNoticeDetail(id);
    if (row == null) {
      return null;
    }

    return _mapNoticeItem(row);
  }

  Future<List<InquiryItem>> fetchInquiries() async {
    final rows = await service.fetchInquiries();

    return rows.map(_mapInquiryItem).toList();
  }

  Future<List<FriendItem>> fetchFriends() async {
    final friendRows = await service.fetchFriendRows();
    final friendIds = friendRows
        .map((row) => row['friend_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    if (friendIds.isEmpty) {
      return const [];
    }

    final profileRows = await service.fetchProfilesByIds(friendIds);
    final profileMap = {
      for (final row in profileRows) row['id']?.toString() ?? '': row,
    };

    return friendRows.map((row) {
      final friendId = row['friend_id']?.toString() ?? '';
      final profile = profileMap[friendId] ?? const <String, dynamic>{};

      return FriendItem(
        id: friendId,
        nickname: (profile['nickname'] ?? '친구').toString(),
        userCode: (profile['user_code'] ?? '-').toString(),
        profileImageUrl: profile['profile_image_url']?.toString(),
        createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()),
      );
    }).toList();
  }

  Future<FriendItem?> findFriendByCode(String userCode) async {
    final profile = await service.fetchProfileByUserCode(userCode.trim());
    if (profile == null) {
      return null;
    }

    return FriendItem(
      id: (profile['id'] ?? '').toString(),
      nickname: (profile['nickname'] ?? '친구').toString(),
      userCode: (profile['user_code'] ?? '-').toString(),
      profileImageUrl: profile['profile_image_url']?.toString(),
      createdAt: null,
    );
  }

  Future<void> addFriendByCode(String userCode) async {
    try {
      await service.addFriendByCode(userCode);
    } catch (error) {
      throw StateError('코드로 친구를 추가하지 못했어요. $error');
    }
  }

  Future<void> deleteFriend(String friendId) async {
    try {
      await service.deleteFriend(friendId);
    } catch (error) {
      throw StateError('친구를 삭제하지 못했어요. $error');
    }
  }

  NoticeItem _mapNoticeItem(Map<String, dynamic> row) {
    return NoticeItem(
      id: (row['id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      content: (row['content'] ?? '').toString(),
      isImportant: row['is_important'] == true,
      createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()),
    );
  }

  InquiryItem _mapInquiryItem(Map<String, dynamic> row) {
    return InquiryItem(
      id: (row['id'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      status: (row['status'] ?? '').toString(),
      answer: row['answer']?.toString(),
      createdAt: DateTime.tryParse((row['created_at'] ?? '').toString()),
    );
  }

  int _extractPearlCount(List<Map<String, dynamic>> assetRows) {
    for (final row in assetRows) {
      final type = (row['asset_type'] ?? row['name'] ?? '')
          .toString()
          .toLowerCase();
      if (type.contains('pearl') || type.contains('진주')) {
        final dynamic value =
            row['amount'] ?? row['quantity'] ?? row['count'] ?? 0;
        if (value is num) {
          return value.toInt();
        }
        return int.tryParse(value.toString()) ?? 0;
      }
    }

    return 0;
  }
}
