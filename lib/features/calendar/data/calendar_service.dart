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
    final userId = client?.auth.currentUser?.id;

    if (client == null || userId == null) {
      return const [];
    }

    final islandRows = await fetchIslandRows();
    final islandIds = islandRows
        .map((row) => row['island_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    if (islandIds.isEmpty) {
      return const [];
    }

    final firstDay = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final response = await client
        .from('friend_photos')
        .select('id, island_id, uploader_id, image_url, description, created_at')
        .inFilter('island_id', islandIds)
        .gte('created_at', firstDay.toIso8601String())
        .lt('created_at', nextMonth.toIso8601String())
        .order('created_at', ascending: true);

    final islandMetaById = <String, Map<String, dynamic>>{
      for (final row in islandRows)
        row['island_id']?.toString() ?? '': Map<String, dynamic>.from(
          (row['islands'] as Map?) ?? const <String, dynamic>{},
        ),
    };

    return List<Map<String, dynamic>>.from(
      (response as List<dynamic>).map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final islandId = row['island_id']?.toString() ?? '';
        final island = islandMetaById[islandId] ?? const <String, dynamic>{};
        return {
          ...row,
          'title': (island['name'] ?? '기억섬').toString(),
          'event_date': row['taken_at'] ?? row['created_at'],
          'type': 'memory',
        };
      }),
    );
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
