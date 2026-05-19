import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uyoung_app/features/login/data/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this.repository);

  final LoginRepository repository;

  bool _isLoading = false;
  String? _errorText;

  bool get isLoading => _isLoading;
  String? get errorText => _errorText;

  Stream<AuthState> get onAuthStateChange => repository.onAuthStateChange;
  Session? get currentSession => repository.currentSession;

  Future<void> signInWithSocial(OAuthProvider provider) async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      await repository.signInWithSocial(provider);
    } catch (error) {
      _errorText = '로그인 중 오류가 발생했어요. $error';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    notifyListeners();
  }
}
