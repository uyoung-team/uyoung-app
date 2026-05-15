import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class MemoryService {
  const MemoryService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  Future<List<Map<String, dynamic>>> fetchIslandRows() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('island_members')
        .select(
          'island_id, is_favorite, is_muted, islands(id, name, bg_image_url, theme_color, invite_code, updated_at)',
        )
        .eq('user_id', userId)
        .order('is_favorite', ascending: false)
        .order('updated_at', ascending: false, referencedTable: 'islands');

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchIslandMemberRows(
    List<String> islandIds,
  ) async {
    final client = _clientProvider.client;
    if (client == null || islandIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('island_members')
        .select('island_id, user_id')
        .inFilter('island_id', islandIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchProfilesByIds(
    List<String> userIds,
  ) async {
    final client = _clientProvider.client;
    if (client == null || userIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, avatar_url, user_code')
        .inFilter('id', userIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchUsers(String keyword) async {
    final client = _clientProvider.client;
    if (client == null) {
      return const [];
    }

    final response = await client.rpc(
      'search_users',
      params: {'search_term': keyword},
    );

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<String> createIslandWithMembers({
    required String islandName,
    required String color,
    String? bgUrl,
    List<String> inviteeIds = const [],
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'create_island_with_members',
      params: {
        'island_name': islandName,
        'color': color,
        'bg_url': bgUrl,
        'invitee_ids': inviteeIds,
      },
    );

    return response as String;
  }

  Future<String?> fetchInviteCode(String islandId) async {
    final client = _clientProvider.client;
    if (client == null || islandId.isEmpty) {
      return null;
    }

    final response = await client
        .from('islands')
        .select('invite_code')
        .eq('id', islandId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['invite_code']?.toString();
  }

  Future<void> updateIslandMemberSettings({
    required String islandId,
    bool? isFavorite,
    bool? isMuted,
  }) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final updates = <String, dynamic>{};
    if (isFavorite != null) {
      updates['is_favorite'] = isFavorite;
    }
    if (isMuted != null) {
      updates['is_muted'] = isMuted;
    }

    if (updates.isEmpty) {
      return;
    }

    await client
        .from('island_members')
        .update(updates)
        .eq('island_id', islandId)
        .eq('user_id', userId);
  }

  Future<void> updateIslandName({
    required String islandId,
    required String name,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    await client.from('islands').update({'name': name}).eq('id', islandId);
  }

  Future<void> leaveIsland(String islandId) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    await client.rpc(
      'leave_island',
      params: {'target_island_id': islandId},
    );
  }

  Future<List<Map<String, dynamic>>> fetchIslandByIds(List<String> islandIds) async {
    final client = _clientProvider.client;
    if (client == null || islandIds.isEmpty) {
      return const [];
    }

    final response = await client
        .from('islands')
        .select('id, name, bg_image_url, invite_code, updated_at')
        .inFilter('id', islandIds);

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchIsland(String islandId) async {
    final rows = await fetchIslandByIds([islandId]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> fetchIslandByInviteCode(String inviteCode) async {
    final client = _clientProvider.client;
    if (client == null || inviteCode.isEmpty) {
      return null;
    }

    final response = await client
        .from('islands')
        .select('id, name, bg_image_url, invite_code, updated_at')
        .eq('invite_code', inviteCode)
        .maybeSingle();

    return response == null ? null : Map<String, dynamic>.from(response);
  }

  Future<void> joinIslandByInviteCode(String inviteCode) async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      throw StateError('로그인 후 입장할 수 있어요.');
    }

    final island = await fetchIslandByInviteCode(inviteCode);
    if (island == null) {
      throw StateError('유효하지 않은 초대 링크예요.');
    }

    final islandId = island['id']?.toString();
    if (islandId == null || islandId.isEmpty) {
      throw StateError('기억섬 정보를 찾을 수 없어요.');
    }

    final existingMembership = await client
        .from('island_members')
        .select('id')
        .eq('island_id', islandId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMembership == null) {
      await client.from('island_members').insert({
        'island_id': islandId,
        'user_id': userId,
        'role': 'member',
        'is_favorite': false,
        'is_muted': false,
      });
    }
  }

  Future<void> inviteMembersToIsland({
    required String islandId,
    required List<String> selectedUserIds,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    if (selectedUserIds.isEmpty) {
      return;
    }

    await client.rpc(
      'invite_members_to_island',
      params: {
        'target_island_id': islandId,
        'target_user_ids': selectedUserIds,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavoritePhotos(String islandId) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'get_my_favorite_photos',
      params: {'target_island_id': islandId},
    );

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<bool> toggleFavoritePhoto({
    required String islandId,
    required String photoKey,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc(
      'toggle_favorite_photo',
      params: {
        'target_island_id': islandId,
        'target_photo_key': photoKey,
      },
    );

    return response == true;
  }
}
