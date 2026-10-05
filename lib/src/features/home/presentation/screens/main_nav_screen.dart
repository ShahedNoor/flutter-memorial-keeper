import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import 'package:memorialkeeper/src/features/memorials/presentation/screens/memorial_directory_screen.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/screens/resting_places_screen.dart';
import 'package:memorialkeeper/src/features/dua/presentation/screens/dua_library_screen.dart';
import 'package:memorialkeeper/src/features/settings/presentation/screens/settings_screen.dart';

/// Main navigation shell hosting persistent bottom navigation across features.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    MemorialDirectoryScreen(),
    RestingPlacesScreen(),
    DuaLibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        key: ValueKey('nav_bar_${currentLocale.languageCode}'),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          AppBottomNavItem(
            label: 'nav.home'.tr(context: context),
            icon: HugeIcons.strokeRoundedHome01,
            activeIcon: HugeIcons.strokeRoundedHome01,
          ),
          AppBottomNavItem(
            label: 'nav.memorials'.tr(context: context),
            icon: HugeIcons.strokeRoundedUserGroup,
            activeIcon: HugeIcons.strokeRoundedUserGroup,
          ),
          AppBottomNavItem(
            label: 'nav.places'.tr(context: context),
            icon: HugeIcons.strokeRoundedLocation01,
            activeIcon: HugeIcons.strokeRoundedLocation01,
          ),
          AppBottomNavItem(
            label: 'nav.duas'.tr(context: context),
            icon: HugeIcons.strokeRoundedMosque01,
            activeIcon: HugeIcons.strokeRoundedMosque01,
          ),
          AppBottomNavItem(
            label: 'nav.settings'.tr(context: context),
            icon: HugeIcons.strokeRoundedSettings01,
            activeIcon: HugeIcons.strokeRoundedSettings01,
          ),
        ],
      ),
    );
  }
}
