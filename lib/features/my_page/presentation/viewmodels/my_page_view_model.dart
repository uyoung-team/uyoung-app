import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  MyPageViewModel(this.repository);

  final MyPageRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  MyPageProfile _profile = MyPageProfile.empty();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MyPageProfile get profile => _profile;

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
