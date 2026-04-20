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
        .select('island_id, user_id, profiles!user_id(id, nickname, avatar_url)')
        .inFilter('island_id', islandIds);

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
}
