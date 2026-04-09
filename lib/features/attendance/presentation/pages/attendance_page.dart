import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '출석체크',
      body: FeaturePlaceholder(
        title: 'Attendance',
        description: '출석체크 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
