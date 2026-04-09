import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class NoticesViewModel extends ChangeNotifier {
  NoticesViewModel(this.repository);

  final MyPageRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<NoticeItem> _items = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NoticeItem> get items => _items;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await repository.fetchNotices();
    } catch (_) {
      _items = const [];
      _errorMessage = '공지사항을 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
