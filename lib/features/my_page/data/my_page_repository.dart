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
