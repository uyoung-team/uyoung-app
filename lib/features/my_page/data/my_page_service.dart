import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class MyPageService {
  const MyPageService({
    SupabaseClientProvider? clientProvider,
  }) : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

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
}
