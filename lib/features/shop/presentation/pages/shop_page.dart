import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '상점',
      body: FeaturePlaceholder(
        title: 'Shop',
        description: '상점 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
