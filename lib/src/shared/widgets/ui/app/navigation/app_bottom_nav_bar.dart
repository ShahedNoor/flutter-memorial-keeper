import '../../../../../imports/imports.dart';

/// A single destination in [AppBottomNavBar].
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });

  final String label;
  final dynamic icon;
  final dynamic activeIcon;
}

/// Adaptive bottom navigation bar.
///
/// Usage:
/// ```dart
/// AppBottomNavBar(
///   currentIndex: index,
///   onTap: (i) => setState(() => index = i),
///   items: const [
///     AppBottomNavItem(label: 'Home', icon: HugeIcons.strokeRoundedHome01),
///     AppBottomNavItem(label: 'Memorials', icon: HugeIcons.strokeRoundedUserGroup),
///   ],
/// )
/// ```
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.platform,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppPlatformStyle? platform;

  @override
  Widget build(BuildContext context) {
    final useCupertino = platform != null
        ? platform == AppPlatformStyle.cupertino
        : context.isCupertinoUi;
    final colors = context.colors;

    if (useCupertino) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: colors.surfaceContainer,
        activeColor: colors.primary,
        inactiveColor: colors.onSurfaceVariant,
        items: [
          for (final item in items)
            BottomNavigationBarItem(
              icon: AppIcon(icon: item.icon, size: 22.sp),
              activeIcon: AppIcon(
                icon: item.activeIcon ?? item.icon,
                size: 22.sp,
                color: colors.primary,
              ),
              label: item.label,
            ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: colors.surfaceContainerLow,
      elevation: 4,
      indicatorColor: colors.primaryContainer,
      destinations: [
        for (var i = 0; i < items.length; i++)
          NavigationDestination(
            icon: AppIcon(
              icon: items[i].icon,
              size: 22.sp,
              color: currentIndex == i ? colors.primary : colors.onSurfaceVariant,
            ),
            selectedIcon: AppIcon(
              icon: items[i].activeIcon ?? items[i].icon,
              size: 22.sp,
              color: colors.primary,
            ),
            label: items[i].label,
          ),
      ],
    );
  }
}
