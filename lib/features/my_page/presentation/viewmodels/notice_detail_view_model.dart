import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class NoticeDetailViewModel extends ChangeNotifier {
  NoticeDetailViewModel(this.repository);

  final MyPageRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  NoticeItem? _notice;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NoticeItem? get notice => _notice;

  Future<void> load(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notice = await repository.fetchNoticeDetail(id);
      if (_notice == null) {
        _errorMessage = '공지사항을 찾을 수 없습니다.';
      }
    } catch (_) {
      _errorMessage = '공지사항 상세를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
