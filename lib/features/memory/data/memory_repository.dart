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
      final membersByIsland = _groupMembersByIsland(memberRows);

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

      return items;
    } catch (error) {
      throw StateError('기억섬 목록을 불러오지 못했어요. $error');
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
      final members = _groupMembersByIsland(memberRows)[islandId] ?? const [];

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

  Map<String, List<MemoryMemberPreview>> _groupMembersByIsland(
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <String, List<MemoryMemberPreview>>{};

    for (final row in rows) {
      final islandId = row['island_id']?.toString();
      final profileRaw = row['profiles'];

      if (islandId == null || profileRaw is! Map) {
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
