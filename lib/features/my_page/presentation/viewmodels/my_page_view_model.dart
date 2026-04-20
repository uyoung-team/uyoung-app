import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0+1',
  );

  MyPageViewModel(this.repository);

  final MyPageRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  MyPageProfile _profile = MyPageProfile.empty();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MyPageProfile get profile => _profile;
  String get displayName {
    final trimmed = _profile.nickname.trim();
    return trimmed.isEmpty ? '이름 없음' : trimmed;
  }

  String get userCode {
    final trimmed = _profile.userCode.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await repository.fetchMyPageProfile();
    } catch (_) {
      _errorMessage = '마이페이지 정보를 불러오지 못했습니다.';
      _profile = MyPageProfile.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
