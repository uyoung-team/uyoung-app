import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '홈',
      body: FeaturePlaceholder(
        title: 'Home',
        description: '홈 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
