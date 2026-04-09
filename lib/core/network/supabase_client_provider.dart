import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/core/network/supabase_initializer.dart';

class SupabaseClientProvider {
  const SupabaseClientProvider._();

  static const SupabaseClientProvider instance = SupabaseClientProvider._();

  bool get isReady => SupabaseInitializer.isInitialized;

  SupabaseClient? get client {
    if (!isReady) {
      return null;
    }

    return Supabase.instance.client;
  }
}
