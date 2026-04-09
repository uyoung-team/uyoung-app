import 'package:flutter/material.dart';
import 'package:uyoung_app/features/login/presentation/pages/login_page.dart';
import 'package:uyoung_app/shared/widgets/main_tab_shell.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case root:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const MainTabShell(),
          settings: settings,
        );
    }
  }
}
