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
}
