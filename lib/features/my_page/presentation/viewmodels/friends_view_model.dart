import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_models.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class FriendsViewModel extends ChangeNotifier {
  FriendsViewModel(this.repository);

  final MyPageRepository repository;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String? _searchMessage;
  List<FriendItem> _friends = const [];
  FriendItem? _searchResult;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String? get searchMessage => _searchMessage;
  List<FriendItem> get friends => _friends;
  FriendItem? get searchResult => _searchResult;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _friends = await repository.fetchFriends();
    } catch (_) {
      _errorMessage = '친구 목록을 불러오지 못했습니다.';
      _friends = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchByCode(String userCode) async {
    final trimmed = userCode.trim();
    if (trimmed.isEmpty) {
      _searchResult = null;
      _searchMessage = '친구 코드를 입력해주세요.';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchMessage = null;
    _searchResult = null;
    notifyListeners();

    try {
      final result = await repository.findFriendByCode(trimmed);
      if (result == null) {
        _searchMessage = '일치하는 친구를 찾지 못했습니다.';
      } else {
        _searchResult = result;
        _searchMessage = '친구 추가 흐름은 다음 단계에서 연결됩니다.';
      }
    } catch (_) {
      _searchMessage = '친구 코드를 확인하는 중 문제가 발생했습니다.';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<String?> addFoundUser() async {
    final result = _searchResult;
    if (result == null) {
      return null;
    }

    _isSearching = true;
    _searchMessage = null;
    notifyListeners();

    try {
      await repository.addFriendByCode(result.userCode);
      _searchMessage = '${result.nickname}님을 친구로 추가했어요.';
      await load();
      return _searchMessage;
    } catch (_) {
      _searchMessage = '친구 추가 중 문제가 발생했습니다.';
      return _searchMessage;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> deleteFriend(String friendId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.deleteFriend(friendId);
      _friends = _friends.where((friend) => friend.id != friendId).toList();
    } catch (_) {
      _errorMessage = '친구 삭제에 실패했어요.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResult = null;
    _searchMessage = null;
    notifyListeners();
  }
}
