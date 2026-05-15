import 'package:uyoung_app/features/attendance/presentation/pages/attendance_page.dart';
import 'package:flutter/material.dart';
import 'package:uyoung_app/features/login/presentation/pages/login_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/invite_island_page.dart';
import 'package:uyoung_app/shared/widgets/main_tab_shell.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';
  static const String attendance = '/attendance';
  static const String inviteIsland = '/memory/invite';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case attendance:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendancePage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case inviteIsland:
        final inviteCode = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(
          builder: (_) => InviteIslandPage(inviteCode: inviteCode),
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
