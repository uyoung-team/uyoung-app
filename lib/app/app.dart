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

class UyoungApp extends StatelessWidget {
  const UyoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uyoung App',
      debugShowCheckedModeBanner: false,
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
