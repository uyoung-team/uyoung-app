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

  Future<void> insertCreatedItem(MemoryIslandItem item) async {
    _items = [item, ..._items.where((existing) => existing.id != item.id)];
    notifyListeners();
  }

  Future<void> insertOrUpdateItem(MemoryIslandItem item) async {
    _items = [item, ..._items.where((existing) => existing.id != item.id)];
    notifyListeners();
  }

  Future<void> renameIsland({
    required int index,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || index < 0 || index >= _items.length) {
      return;
    }

    final updated = await repository.renameIsland(
      item: _items[index],
      name: trimmed,
    );
    _items = List<MemoryIslandItem>.from(_items)..[index] = updated;
    notifyListeners();
  }

  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final item = _items[index];
    final updated = await repository.updateIslandSettings(
      item: item,
      isFavorite: !item.isFavorite,
    );
    _items = List<MemoryIslandItem>.from(_items)..[index] = updated;
    _sortItems();
    notifyListeners();
  }

  Future<void> toggleAlarm(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final item = _items[index];
    final updated = await repository.updateIslandSettings(
      item: item,
      isMuted: item.isNotificationOn,
    );
    _items = List<MemoryIslandItem>.from(_items)..[index] = updated;
    notifyListeners();
  }

  Future<void> removeItem(int index) async {
    if (index < 0 || index >= _items.length) {
      return;
    }

    final islandId = _items[index].id;
    await repository.leaveIsland(islandId);
    _items = List<MemoryIslandItem>.from(_items)..removeAt(index);
    notifyListeners();
  }

  void _sortItems() {
    _items = List<MemoryIslandItem>.from(_items)
      ..sort((a, b) {
        if (a.isFavorite != b.isFavorite) {
          return a.isFavorite ? -1 : 1;
        }

        final aUpdatedAt =
            a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bUpdatedAt =
            b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bUpdatedAt.compareTo(aUpdatedAt);
      });
  }
}
