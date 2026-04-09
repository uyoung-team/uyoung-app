import 'package:flutter/material.dart';
import 'package:uyoung_app/app/routes/app_router.dart';
import 'package:uyoung_app/core/theme/app_theme.dart';

class UyoungApp extends StatelessWidget {
  const UyoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uyoung App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRouter.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
