import 'package:flutter/material.dart';
import 'package:uyoung_app/core/theme/app_colors.dart';
import 'package:uyoung_app/shared/services/asset_paths.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomNavItem(
        activeAssetPath: 'homeOn',
        inactiveAssetPath: 'homeOff',
        fallbackIcon: Icons.home_rounded,
      ),
      _BottomNavItem(
        activeAssetPath: 'memoryOn',
        inactiveAssetPath: 'memoryOff',
        fallbackIcon: Icons.landscape_rounded,
      ),
      _BottomNavItem(
        activeAssetPath: 'calendarOn',
        inactiveAssetPath: 'calendarOff',
        fallbackIcon: Icons.calendar_month_rounded,
      ),
      _BottomNavItem(
        activeAssetPath: 'storeOn',
        inactiveAssetPath: 'storeOff',
        fallbackIcon: Icons.storefront_rounded,
      ),
      _BottomNavItem(
        activeAssetPath: 'myPageOn',
        inactiveAssetPath: 'myPageOff',
        fallbackIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      height: 75,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.g05, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final item = items[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(index),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: _BottomNavIcon(
                  item: item,
                  isActive: isActive,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.item,
    required this.isActive,
  });

  final _BottomNavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconPath = switch ((item.activeAssetPath, item.inactiveAssetPath)) {
      (final active?, final inactive?) => isActive
          ? _resolveBottomNavigationPath(active)
          : _resolveBottomNavigationPath(inactive),
      _ => null,
    };

    if (iconPath != null) {
      return Image.asset(
        iconPath,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      item.fallbackIcon,
      size: 28,
      color: isActive ? AppColors.b01 : AppColors.g03,
    );
  }

  String _resolveBottomNavigationPath(String key) {
    final icons = AssetPaths.icons.bottomNavigation;
    switch (key) {
      case 'homeOn':
        return icons.homeOn;
      case 'homeOff':
        return icons.homeOff;
      case 'calendarOn':
        return icons.calendarOn;
      case 'calendarOff':
        return icons.calendarOff;
      case 'memoryOn':
        return icons.memoryOn;
      case 'memoryOff':
        return icons.memoryOff;
      case 'storeOn':
        return icons.storeOn;
      case 'storeOff':
        return icons.storeOff;
      case 'myPageOn':
        return icons.myPageOn;
      case 'myPageOff':
        return icons.myPageOff;
      default:
        return icons.homeOff;
    }
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    this.activeAssetPath,
    this.inactiveAssetPath,
    required this.fallbackIcon,
  });

  final String? activeAssetPath;
  final String? inactiveAssetPath;
  final IconData fallbackIcon;
}
