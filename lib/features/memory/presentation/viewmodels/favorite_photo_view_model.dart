import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_models.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class FavoritePhotoViewModel extends ChangeNotifier {
  FavoritePhotoViewModel({
    required this.islandId,
    required MemoryRepository repository,
  }) : _repository = repository;

  final String islandId;
  final MemoryRepository _repository;

  List<FavoritePhoto> _photos = const [];
  bool _isLoading = false;
  String? _errorText;

  List<FavoritePhoto> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  String? get errorText => _errorText;

  Future<void> load() async {
    _isLoading = true;
    _errorText = null;
    notifyListeners();

    try {
      _photos = await _repository.fetchFavoritePhotos(islandId);
    } catch (error) {
      _photos = const [];
      _errorText = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String photoKey) async {
    try {
      final isFavorite = await _repository.toggleFavoritePhoto(
        islandId: islandId,
        photoKey: photoKey,
      );

      if (!isFavorite) {
        _photos = _photos.where((photo) => photo.photoKey != photoKey).toList();
        notifyListeners();
      } else {
        await load();
      }

      return isFavorite;
    } catch (error) {
      _errorText = error.toString();
      notifyListeners();
      rethrow;
    }
  }
}
