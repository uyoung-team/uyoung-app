import 'package:flutter/material.dart';
import 'package:uyoung_app/shared/widgets/app_scaffold.dart';
import 'package:uyoung_app/shared/widgets/feature_placeholder.dart';

class MainTabShell extends StatefulWidget {
  const MainTabShell({super.key});

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  int _currentIndex = 0;

  late final List<_TabItem> _tabs = [
    const _TabItem(
      label: '홈',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      page: _TabPage(
        title: '홈',
        description: '홈 화면 골격이 들어올 자리입니다.',
      ),
    ),
    const _TabItem(
      label: '기억섬',
      icon: Icons.landscape_outlined,
      activeIcon: Icons.landscape,
      page: _TabPage(
        title: '기억섬',
        description: '기억섬 화면 골격이 들어올 자리입니다.',
      ),
    ),
    const _TabItem(
      label: '캘린더',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      page: _TabPage(
        title: '캘린더',
        description: '캘린더 화면 골격이 들어올 자리입니다.',
      ),
    ),
    const _TabItem(
      label: '상점',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      page: _TabPage(
        title: '상점',
        description: '상점 화면 골격이 들어올 자리입니다.',
      ),
    ),
    const _TabItem(
      label: '마이',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      page: _TabPage(
        title: '마이페이지',
        description: '마이페이지 화면 골격이 들어올 자리입니다.',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                activeIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
}

class _TabPage extends StatelessWidget {
  const _TabPage({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: FeaturePlaceholder(
        title: title,
        description: description,
      ),
    );
  }
}
