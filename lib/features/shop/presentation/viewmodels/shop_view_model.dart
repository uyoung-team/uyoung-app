import 'package:flutter/foundation.dart';
import 'package:uyoung_app/features/shop/data/shop_repository.dart';

class ShopViewModel extends ChangeNotifier {
  ShopViewModel(this.repository);

  final ShopRepository repository;
}
