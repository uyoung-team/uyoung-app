import 'package:image_picker/image_picker.dart';
import 'package:uyoung_app/features/memory/data/memory_dummy_adapter.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_service.dart';

class MemoryRepository {
  const MemoryRepository(this.service);

  final MemoryService service;

  Future<List<MemoryIslandItem>> loadItems() async {
    try {
      final islandRows = await service.fetchIslandRows();
      final islandIds = islandRows
          .map((row) => row['island_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      final memberRows = await service.fetchIslandMemberRows(islandIds);
      final membersByIsland = await _groupMembersByIsland(memberRows);

      final items = islandRows.map((row) {
        final island = Map<String, dynamic>.from(
          (row['islands'] ?? const <String, dynamic>{}) as Map,
        );
        final islandId =
            island['id']?.toString() ?? row['island_id']?.toString() ?? '';

        return MemoryIslandItem(
          id: islandId,
          title: (island['name'] ?? island['island_name'] ?? '').toString(),
          isFavorite: row['is_favorite'] == true,
          isNotificationOn: !(row['is_muted'] == true),
          imagePath: island['bg_image_url']?.toString(),
          updatedAt: DateTime.tryParse((island['updated_at'] ?? '').toString()),
          inviteCode: island['invite_code']?.toString(),
          members: membersByIsland[islandId] ?? const [],
        );
      }).toList();

      items.sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }

        final aUpdatedAt = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bUpdatedAt = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bUpdatedAt.compareTo(aUpdatedAt);
      });

      return items.isEmpty ? MemoryDummyAdapter.islandItems() : items;
    } catch (error) {
      return MemoryDummyAdapter.islandItems();
    }
  }

  Future<List<InviteeUser>> searchUsers(String keyword) async {
    try {
      final rows = await service.searchUsers(keyword);
      return rows.map(InviteeUser.fromMap).toList();
    } catch (error) {
      throw StateError('초대할 사용자를 불러오지 못했어요. $error');
    }
  }

  Future<String> uploadIslandBackground(XFile imageFile) async {
    try {
      return await service.uploadIslandBackground(imageFile);
    } catch (error) {
      throw StateError('배경 이미지를 업로드하지 못했어요. $error');
    }
  }

  Future<MemoryIslandItem> createIsland({
    required String islandName,
    required String color,
    String? bgUrl,
    List<String> inviteeIds = const [],
  }) async {
    try {
      final islandId = await service.createIslandWithMembers(
        islandName: islandName,
        color: color,
        bgUrl: bgUrl,
        inviteeIds: inviteeIds,
      );
      final inviteCode = await service.fetchInviteCode(islandId);
      final islandRows = await service.fetchIslandByIds([islandId]);
      final memberRows = await service.fetchIslandMemberRows([islandId]);
      final island = islandRows.isNotEmpty ? islandRows.first : <String, dynamic>{};
      final members = (await _groupMembersByIsland(memberRows))[islandId] ?? const [];

      return MemoryIslandItem(
        id: islandId,
        title: (island['name'] ?? islandName).toString(),
        isFavorite: false,
        isNotificationOn: true,
        imagePath: island['bg_image_url']?.toString() ?? bgUrl,
        updatedAt: DateTime.tryParse((island['updated_at'] ?? '').toString()),
        inviteCode: inviteCode,
        members: members,
      );
    } catch (error) {
      throw StateError('기억섬 생성에 실패했어요. $error');
    }
  }

  Future<MemoryIslandItem> fetchIsland(String islandId) async {
    try {
      final island = await service.fetchIsland(islandId);
      if (island == null) {
        final dummyItem = MemoryDummyAdapter.islandItemById(islandId);
        if (dummyItem != null) {
          return dummyItem;
        }
        throw StateError('기억섬을 찾을 수 없어요.');
      }

      final members = await fetchIslandMembers(islandId);
      return MemoryIslandItem(
        id: (island['id'] ?? islandId).toString(),
        title: (island['name'] ?? '').toString(),
        isFavorite: false,
        isNotificationOn: true,
        imagePath: island['bg_image_url']?.toString(),
        updatedAt: DateTime.tryParse((island['updated_at'] ?? '').toString()),
        inviteCode: island['invite_code']?.toString(),
        members: members,
      );
    } catch (error) {
      final dummyItem = MemoryDummyAdapter.islandItemById(islandId);
      if (dummyItem != null) {
        return dummyItem;
      }
      throw StateError('기억섬 정보를 불러오지 못했어요. $error');
    }
  }

  Future<MemoryIslandItem> renameIsland({
    required MemoryIslandItem item,
    required String name,
  }) async {
    try {
      await service.updateIslandName(islandId: item.id, name: name);
      return item.copyWith(title: name);
    } catch (error) {
      throw StateError('기억섬 이름을 변경하지 못했어요. $error');
    }
  }

  Future<MemoryIslandItem> updateIslandSettings({
    required MemoryIslandItem item,
    bool? isFavorite,
    bool? isMuted,
  }) async {
    try {
      await service.updateIslandMemberSettings(
        islandId: item.id,
        isFavorite: isFavorite,
        isMuted: isMuted,
      );
      return item.copyWith(
        isFavorite: isFavorite ?? item.isFavorite,
        isNotificationOn: isMuted != null ? !isMuted : item.isNotificationOn,
      );
    } catch (error) {
      throw StateError('기억섬 설정을 변경하지 못했어요. $error');
    }
  }

  Future<void> leaveIsland(String islandId) async {
    try {
      await service.leaveIsland(islandId);
    } catch (error) {
      throw StateError('기억섬에서 나가지 못했어요. $error');
    }
  }

  String buildInviteLink(String inviteCode) {
    return 'https://momenture.app/invite?code=$inviteCode';
  }

  Future<IslandInviteDetail?> fetchIslandInviteDetail(String inviteCode) async {
    try {
      final island = await service.fetchIslandByInviteCode(inviteCode);
      if (island == null) {
        return null;
      }

      final islandId = island['id']?.toString() ?? '';
      final members = await fetchIslandMembers(islandId);
      return IslandInviteDetail(
        islandId: islandId,
        name: (island['name'] ?? '').toString(),
        inviteCode: (island['invite_code'] ?? inviteCode).toString(),
        bgImageUrl: island['bg_image_url']?.toString(),
        members: members,
      );
    } catch (error) {
      throw StateError('초대 정보를 불러오지 못했어요. $error');
    }
  }

  Future<IslandInviteDetail> joinIslandByInviteCode(String inviteCode) async {
    try {
      final detail = await fetchIslandInviteDetail(inviteCode);
      if (detail == null) {
        throw StateError('유효하지 않은 초대 링크예요.');
      }
      await service.joinIslandByInviteCode(inviteCode);
      return detail;
    } catch (error) {
      throw StateError('기억섬 입장에 실패했어요. $error');
    }
  }

  Future<List<MemoryMemberPreview>> fetchIslandMembers(String islandId) async {
    try {
      final memberRows = await service.fetchIslandMemberRows([islandId]);
      final members = (await _groupMembersByIsland(memberRows))[islandId] ?? const [];
      return members.isEmpty
          ? MemoryDummyAdapter.memberPreviews(islandId)
          : members;
    } catch (error) {
      return MemoryDummyAdapter.memberPreviews(islandId);
    }
  }

  Future<void> inviteMembersToIsland({
    required String islandId,
    required List<String> selectedUserIds,
  }) async {
    try {
      await service.inviteMembersToIsland(
        islandId: islandId,
        selectedUserIds: selectedUserIds,
      );
    } catch (error) {
      throw StateError('멤버를 초대하지 못했어요. $error');
    }
  }

  Future<List<FavoritePhoto>> fetchFavoritePhotos(String islandId) async {
    try {
      final rows = await service.fetchFavoritePhotos(islandId);
      return rows.map(FavoritePhoto.fromMap).toList();
    } catch (error) {
      throw StateError('즐겨찾는 사진을 불러오지 못했어요. $error');
    }
  }

  Future<bool> toggleFavoritePhoto({
    required String islandId,
    required String photoKey,
  }) async {
    try {
      return await service.toggleFavoritePhoto(
        islandId: islandId,
        photoKey: photoKey,
      );
    } catch (error) {
      throw StateError('즐겨찾기 상태를 변경하지 못했어요. $error');
    }
  }

  Future<List<MemoryPhotoSeed>> fetchIslandPhotos(String islandId) async {
    try {
      final rows = await service.fetchFriendPhotos(islandId);
      if (rows.isEmpty) {
        return const [];
      }

      final uploaderIds = rows
          .map((row) => row['uploader_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final profileRows = await service.fetchProfilesByIds(uploaderIds);
      final profileMap = {
        for (final row in profileRows) row['id']?.toString() ?? '': row,
      };

      return rows.map((row) {
        final uploaderId = row['uploader_id']?.toString() ?? '';
        final profile = profileMap[uploaderId] ?? const <String, dynamic>{};
        return MemoryPhotoSeed(
          path: (row['image_url'] ?? '').toString(),
          createdAt:
              DateTime.tryParse((row['created_at'] ?? '').toString()) ??
              DateTime.now(),
          uploaderName: (profile['nickname'] ?? '버블 메이트').toString(),
          profileImagePath: profile['avatar_url']?.toString(),
          takenAt: DateTime.tryParse((row['taken_at'] ?? '').toString()),
          latitude: _toDouble(row['latitude']),
          longitude: _toDouble(row['longitude']),
          locationName: row['location_name']?.toString(),
        );
      }).toList();
    } catch (error) {
      throw StateError('기억 사진을 불러오지 못했어요. $error');
    }
  }

  Future<MemoryPhotoSeed> uploadIslandPhoto({
    required String islandId,
    required XFile imageFile,
    String? description,
  }) async {
    try {
      final row = await service.uploadFriendPhoto(
        islandId: islandId,
        imageFile: imageFile,
        description: description,
      );
      final uploaderId = row['uploader_id']?.toString() ?? '';
      final profileRows = uploaderId.isEmpty
          ? const <Map<String, dynamic>>[]
          : await service.fetchProfilesByIds([uploaderId]);
      final profile = profileRows.isEmpty
          ? const <String, dynamic>{}
          : profileRows.first;

      return MemoryPhotoSeed(
        path: (row['image_url'] ?? '').toString(),
        createdAt:
            DateTime.tryParse((row['created_at'] ?? '').toString()) ??
            DateTime.now(),
        uploaderName: (profile['nickname'] ?? '나').toString(),
        profileImagePath: profile['avatar_url']?.toString(),
        takenAt: DateTime.tryParse((row['taken_at'] ?? '').toString()),
        latitude: _toDouble(row['latitude']),
        longitude: _toDouble(row['longitude']),
        locationName: row['location_name']?.toString(),
      );
    } catch (error) {
      throw StateError('사진 업로드에 실패했어요. $error');
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Future<Map<String, List<MemoryMemberPreview>>> _groupMembersByIsland(
    List<Map<String, dynamic>> rows,
  ) async {
    final grouped = <String, List<MemoryMemberPreview>>{};
    final userIds = rows
        .map((row) => row['user_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    final profileRows = await service.fetchProfilesByIds(userIds);
    final profileMap = {
      for (final row in profileRows) row['id']?.toString() ?? '': row,
    };

    for (final row in rows) {
      final islandId = row['island_id']?.toString();
      final userId = row['user_id']?.toString() ?? '';
      final profileRaw = profileMap[userId];

      if (islandId == null || profileRaw == null) {
        continue;
      }

      final preview = MemoryMemberPreview.fromMap(
        Map<String, dynamic>.from(profileRaw),
      );
      grouped.putIfAbsent(islandId, () => []).add(preview);
    }

    return grouped;
  }
}
