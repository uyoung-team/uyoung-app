import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_client_provider.dart';
import 'package:uyoung_app/features/home/data/home_models.dart';

class HomeService {
  const HomeService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  SupabaseClient? get _client => _clientProvider.client;

  String? get _currentUserId => _client?.auth.currentUser?.id;

  Future<int> fetchPearlCount() async {
    final client = _client;
    final userId = _currentUserId;

    if (client == null || userId == null) {
      return 0;
    }

    final response = await client
        .from('user_assets')
        .select('pearl_count')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      await _ensureUserAssetsRow(client, userId);
      return 0;
    }

    final value = Map<String, dynamic>.from(response)['pearl_count'];
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> _ensureUserAssetsRow(
    SupabaseClient client,
    String userId,
  ) async {
    await client.from('user_assets').upsert({
      'user_id': userId,
      'pearl_count': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<List<HomeNotification>> fetchNotifications() async {
    final client = _client;
    final userId = _currentUserId;

    if (client == null || userId == null) {
      return const [];
    }

    try {
      final response = await client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (row) =>
                HomeNotification.fromMap(Map<String, dynamic>.from(row as Map)),
          )
          .toList();
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST205') {
        rethrow;
      }

      final response = await client
          .from('notices')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        map['type'] ??= 'notice';
        map['is_read'] ??= true;
        map['user_id'] ??= userId;
        return HomeNotification.fromMap(map);
      }).toList();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final client = _client;
    final userId = _currentUserId;

    if (client == null || userId == null || notificationId.isEmpty) {
      return;
    }

    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST205') {
        rethrow;
      }
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final client = _client;
    final userId = _currentUserId;

    if (client == null || userId == null) {
      return;
    }

    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST205') {
        rethrow;
      }
    }
  }
}
