import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/login/data/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this.repository);

  final LoginRepository repository;
}
