import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_client_provider.dart';

import 'attendance_models.dart';

class AttendanceService {
  const AttendanceService({SupabaseClientProvider? clientProvider})
    : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  SupabaseClient? get _client => _clientProvider.client;

  String? get _userId => _client?.auth.currentUser?.id;

  Future<AttendanceResult> checkInAndDraw() async {
    final client = _client;
    final userId = _userId;

    if (client == null) {
      throw StateError('Supabase가 초기화되지 않았어요.');
    }
    if (userId == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final response = await client.rpc('daily_check_in_and_draw');
    return AttendanceResult.fromRpc(response);
  }

  Future<List<AttendanceLogEntry>> fetchAttendanceLogs() async {
    final client = _client;
    final userId = _userId;

    if (client == null || userId == null) {
      return const [];
    }

    final response = await client
        .from('attendance_logs')
        .select('reward_item')
        .eq('user_id', userId)
        .limit(7);

    final rows = List<Map<String, dynamic>>.from(response);
    return rows.map(AttendanceLogEntry.fromMap).toList();
  }

  Future<int> fetchPearlCount() async {
    final client = _client;
    final userId = _userId;

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
}
