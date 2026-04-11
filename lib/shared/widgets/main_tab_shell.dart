import 'package:flutter/material.dart';
import 'package:uyoung_app/features/calendar/presentation/pages/calendar_page.dart';
import 'package:uyoung_app/features/home/presentation/pages/home_page.dart';
import 'package:uyoung_app/features/memory/presentation/pages/memory_page.dart';
import 'package:uyoung_app/features/my_page/presentation/pages/my_page_page.dart';
import 'package:uyoung_app/features/shop/presentation/pages/shop_page.dart';
import 'package:uyoung_app/shared/widgets/app_bottom_nav_bar.dart';

class MainTabShell extends StatefulWidget {
  const MainTabShell({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainTabShell> createState() => _MainTabShellState();
}

class _MainTabShellState extends State<MainTabShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomePage(),
    MemoryPage(),
    CalendarPage(),
    ShopPage(),
    MyPagePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
