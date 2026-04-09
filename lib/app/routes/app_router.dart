import 'package:flutter/material.dart';

class AppRouter {
  static const String root = '/';
  static const String login = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const _RoutePlaceholderPage(title: 'Login'),
          settings: settings,
        );
      case root:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _RoutePlaceholderPage(title: 'Home'),
          settings: settings,
        );
    }
  }
}

class _RoutePlaceholderPage extends StatelessWidget {
  const _RoutePlaceholderPage({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title),
      ),
    );
  }
}
