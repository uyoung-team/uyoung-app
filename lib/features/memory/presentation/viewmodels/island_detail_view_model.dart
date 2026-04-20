import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class IslandDetailViewModel extends ChangeNotifier {
  IslandDetailViewModel({
    required this.islandId,
    required MemoryRepository repository,
  }) : _repository = repository;

  final String islandId;
  final MemoryRepository _repository;

  MemoryIslandItem? _island;
  List<MemoryMemberPreview> _members = const [];
  bool _isLoading = false;
  String? _errorMessage;

  MemoryIslandItem? get island => _island;
  List<MemoryMemberPreview> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final island = await _repository.fetchIsland(islandId);
      _island = island;
      _members = island.members;
    } catch (error) {
      _errorMessage = error.toString();
      _island = null;
      _members = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
