import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/memory/data/memory_repository.dart';

class MemoryViewModel extends ChangeNotifier {
  MemoryViewModel(this.repository);

  final MemoryRepository repository;
}
