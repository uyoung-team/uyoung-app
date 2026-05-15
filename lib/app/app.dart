import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/app/routes/app_router.dart';
import 'package:uyoung_app/core/theme/app_theme.dart';
import 'package:uyoung_app/features/login/data/login_repository.dart';
import 'package:uyoung_app/features/login/data/login_service.dart';
import 'package:uyoung_app/features/login/presentation/pages/login_page.dart';
import 'package:uyoung_app/features/login/presentation/pages/profile_setup_page.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';
import 'package:uyoung_app/features/my_page/data/my_page_service.dart';
import 'package:uyoung_app/shared/widgets/main_tab_shell.dart';

class UyoungApp extends StatefulWidget {
  const UyoungApp({super.key});

  @override
  State<UyoungApp> createState() => _UyoungAppState();
}

class _UyoungAppState extends State<UyoungApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final Set<String> _handledInviteCodes = <String>{};

  @override
  void initState() {
    super.initState();
    _listenInitialLink();
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  Future<void> _listenInitialLink() async {
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _handleUri(uri);
    }
  }

  void _handleUri(Uri uri) {
    if (_isAuthCallback(uri)) {
      return;
    }

    final inviteCode = _extractInviteCode(uri);
    if (inviteCode == null || _handledInviteCodes.contains(inviteCode)) {
      return;
    }

    _handledInviteCodes.add(inviteCode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        return;
      }
      navigator.pushNamed(
        AppRouter.inviteIsland,
        arguments: inviteCode,
      );
    });
  }

  bool _isAuthCallback(Uri uri) {
    return uri.host == 'login-callback' ||
        uri.pathSegments.contains('login-callback');
  }

  String? _extractInviteCode(Uri uri) {
    final queryCode = uri.queryParameters['code'];
    if (queryCode != null && queryCode.isNotEmpty) {
      return queryCode;
    }

    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments.first == 'invite') {
      return segments[1];
    }

    if (segments.isNotEmpty && segments.last.isNotEmpty) {
      return segments.last;
    }

    return null;
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uyoung App',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light(),
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LoginRepository _repository = const LoginRepository(LoginService());
  final MyPageRepository _myPageRepository = const MyPageRepository(
    MyPageService(),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _repository.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? _repository.currentSession;

        if (session == null) {
          return const LoginPage();
        }

        return FutureBuilder<bool>(
          future: _myPageRepository.needsProfileSetup(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.data == true) {
              return const ProfileSetupPage();
            }

            return const MainTabShell();
          },
        );
      },
    );
  }
}
