import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class MemoryViewModel extends ChangeNotifier {
  MemoryViewModel(this.repository);

  final MemoryRepository repository;

  List<MemoryIslandItem> _items = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MemoryIslandItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await repository.loadItems();
    } catch (error) {
      _items = const [];
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
