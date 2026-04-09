import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: '캘린더',
      body: FeaturePlaceholder(
        title: 'Calendar',
        description: '캘린더 feature 기본 골격만 준비된 상태입니다.',
      ),
    );
  }
}
