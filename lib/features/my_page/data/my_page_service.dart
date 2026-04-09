import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class MyPageService {
  const MyPageService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  Future<Map<String, dynamic>?> fetchProfile() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return null;
    }

    final response = await client
        .from('profiles')
        .select('nickname, user_code, profile_image_url')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchUserAssets() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('user_assets')
        .select('asset_type, amount, quantity, count, name')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchNotices() async {
    final client = _clientProvider.client;
    if (client == null) {
      return const [];
    }

    final response = await client
        .from('notices')
        .select('id, title, content, is_important, created_at')
        .order('is_important', ascending: false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchNoticeDetail(String id) async {
    final client = _clientProvider.client;
    if (client == null || id.isEmpty) {
      return null;
    }

    final response = await client
        .from('notices')
        .select('id, title, content, is_important, created_at')
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchFriendRows() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    try {
      final response = await client
          .from('friends')
          .select('id, friend_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProfilesByIds(
    List<String> ids,
  ) async {
    final client = _clientProvider.client;
    if (client == null || ids.isEmpty) {
      return const [];
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, user_code, profile_image_url')
        .inFilter('id', ids);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchProfileByUserCode(String userCode) async {
    final client = _clientProvider.client;
    final currentUserId = client?.auth.currentUser?.id;

    if (client == null || userCode.isEmpty) {
      return null;
    }

    final response = await client
        .from('profiles')
        .select('id, nickname, user_code, profile_image_url')
        .eq('user_code', userCode)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final profile = Map<String, dynamic>.from(response);
    if (profile['id']?.toString() == currentUserId) {
      return null;
    }

    return profile;
  }

  Future<List<Map<String, dynamic>>> fetchInquiries() async {
    final client = _clientProvider.client;
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('inquiries')
        .select('id, title, created_at, status, answer')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
