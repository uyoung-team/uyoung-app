import 'package:flutter/material.dart';
import 'package:uyoung_app/app/app.dart';
import 'package:uyoung_app/core/network/supabase_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseInitializer.initialize();
  runApp(const UyoungApp());
}
