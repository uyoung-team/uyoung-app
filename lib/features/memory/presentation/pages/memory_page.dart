import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class MemoryPage extends StatelessWidget {
  const MemoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '기억섬',
      body: FeaturePlaceholder(
        title: 'Memory',
        description: '기억섬 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
