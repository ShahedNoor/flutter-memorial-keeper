import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Sleek Emerald Gradient SliverAppBar header with compact branding and live search toggle.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.isSearchActive,
    required this.onSearchToggle,
  });

  final bool isSearchActive;
  final VoidCallback onSearchToggle;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.primary,
      titleSpacing: 20.w,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF064E3B), // Deep Forest Green
              Color(0xFF0D5C46), // Primary Emerald
              Color(0xFF10B981), // Mint Accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'ذكرى',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'home.home_title'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: AppIcon(
            icon: isSearchActive
                ? HugeIcons.strokeRoundedCancel01
                : HugeIcons.strokeRoundedSearch01,
            color: Colors.white,
            size: 20.sp,
          ),
          tooltip: isSearchActive ? 'Close search' : 'Search memorials',
          onPressed: onSearchToggle,
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
