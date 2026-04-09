import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class MyPagePage extends StatelessWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '마이페이지',
      body: FeaturePlaceholder(
        title: 'My Page',
        description: '마이페이지 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
