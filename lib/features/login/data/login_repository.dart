import 'package:uyoung_app/features/login/data/login_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginRepository {
  const LoginRepository(this.service);

  final LoginService service;

  Stream<AuthState> get onAuthStateChange => service.onAuthStateChange;

  Session? get currentSession => service.currentSession;

  Future<void> signInWithSocial(OAuthProvider provider) {
    return service.signInWithSocial(provider);
  }

  Future<void> signOut() => service.signOut();
}
