import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class AttendanceService {
  const AttendanceService({
    SupabaseClientProvider? clientProvider,
  }) : _clientProvider = clientProvider ?? SupabaseClientProvider.instance;

  final SupabaseClientProvider _clientProvider;

  bool get isReady => _clientProvider.client != null;

  Future<List<Map<String, dynamic>>> fetchAttendanceLogs({
    int limit = 14,
  }) async {
    final client = _clientProvider.client;
    if (client == null) {
      return const [];
    }

    final response = await client
        .from('attendance_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> runDailyCheckInAndDraw() async {
    final client = _clientProvider.client;
    if (client == null) {
      return const {
        'status': 'not_ready',
        'message': 'Supabase is not initialized.',
      };
    }

    final response = await client.rpc('daily_check_in_and_draw');

    if (response is Map<String, dynamic>) {
      return response;
    }

    return {
      'status': 'completed',
      'result': response,
    };
  }
}
