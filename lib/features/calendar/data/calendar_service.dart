import 'dart:ui';

import 'package:uyoung_app/core/network/supabase_client_provider.dart';

class CalendarService {
  const CalendarService({SupabaseClientProvider? clientProvider})
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
        .select('island_id, islands(id, name, theme_color, updated_at)')
        .eq('user_id', userId)
        .order('updated_at', ascending: false, referencedTable: 'islands');

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map(
        (row) => Map<String, dynamic>.from(row as Map),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchMemoriesForMonth(
    DateTime month,
  ) async {
    final client = _clientProvider.client;
    if (client == null) return const [];

    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    // island_memories와 islands 정보를 조인하여 조회
    final response = await client
        .from('island_memories')
        .select('*, islands(id, name, theme_color)')
        .gte('event_date', firstDay.toIso8601String())
        .lte('event_date', lastDay.toIso8601String())
        .order('event_date', ascending: true);

    return List<Map<String, dynamic>>.from(response as List);
  }

  static Color colorFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return const Color(0xFF6EA8EB);
    }

    final normalized = value.replaceAll('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.parse(hex, radix: 16));
  }
}
