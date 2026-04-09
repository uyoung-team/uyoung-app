import 'package:flutter/material.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:uyoung_app/features/home/presentation/pages/home_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/my_page_page.dart';
import 'package:uyoung_app/features/shop/presentation/pages/shop_page.dart';

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
      page: HomePage(),
    ),
    const _TabItem(
      label: '기억섬',
      icon: Icons.landscape_outlined,
      activeIcon: Icons.landscape,
      page: MemoryPage(),
    ),
    const _TabItem(
      label: '캘린더',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      page: CalendarPage(),
    ),
    const _TabItem(
      label: '상점',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      page: ShopPage(),
    ),
    const _TabItem(
      label: '마이',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      page: MyPagePage(),
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
