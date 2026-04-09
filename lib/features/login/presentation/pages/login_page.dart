import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '로그인',
      body: FeaturePlaceholder(
        title: 'Login',
        description: '로그인 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
