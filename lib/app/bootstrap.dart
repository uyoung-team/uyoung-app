import 'package:flutter/material.dart';
import 'package:uyoung_app/app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UyoungApp());
}
