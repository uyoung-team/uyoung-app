import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/my_page/data/my_page_repository.dart';

class MyPageViewModel extends ChangeNotifier {
  MyPageViewModel(this.repository);

  final MyPageRepository repository;
}
