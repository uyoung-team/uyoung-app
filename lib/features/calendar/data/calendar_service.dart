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

  static Color colorFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return const Color(0xFF6EA8EB);
    }

    final normalized = value.replaceAll('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.parse(hex, radix: 16));
  }
}
