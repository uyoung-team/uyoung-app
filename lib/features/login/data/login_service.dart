import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  const LoginService();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;

  Future<void> signInWithSocial(OAuthProvider provider) {
    return _auth.signInWithOAuth(
      provider,
      redirectTo: 'uyoung://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
