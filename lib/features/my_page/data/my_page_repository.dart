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
      final type = (row['asset_type'] ?? row['name'] ?? '').toString().toLowerCase();
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
