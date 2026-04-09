import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/home/data/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this.repository);

  final HomeRepository repository;
}
