import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class SelectMemberViewModel extends ChangeNotifier {
  SelectMemberViewModel({required MemoryRepository repository})
    : _repository = repository;

  final MemoryRepository _repository;

  final List<InviteeUser> _searchResults = [];
  Timer? _debounce;
  bool _isLoading = false;
  String? _errorText;
  String _query = '';

  List<InviteeUser> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;
  String get query => _query;

  void scheduleSearch(String keyword) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => search(keyword));
  }

  Future<void> search(String keyword) async {
    _query = keyword;
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      final results = await _repository.searchUsers(keyword);
      _searchResults
        ..clear()
        ..addAll(results);
    } catch (error) {
      _errorText = error.toString();
      _searchResults.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
