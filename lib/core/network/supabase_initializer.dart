import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_config.dart';

class SupabaseInitializer {
  const SupabaseInitializer._();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    _isInitialized = true;
  }
}
