import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import 'settings_backup_sheet.dart';

/// Emerald Gradient SliverAppBar header with branding, live search toggle, and settings button.
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
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: cs.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        title: Row(
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
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Memorial Keeper',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        background: DecoratedBox(
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
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                top: -10.h,
                child: Container(
                  width: 140.r,
                  height: 140.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: 20.w,
                top: 48.h,
                child: Text(
                  'home.app_tagline'.tr(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          onPressed: onSearchToggle,
        ),
        IconButton(
          icon: AppIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => SettingsBackupSheet.show(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
