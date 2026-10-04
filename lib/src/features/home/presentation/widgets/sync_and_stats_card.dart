import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import 'settings_backup_sheet.dart';

/// Kahf DNS-style status pill & statistics summary card.
class SyncAndStatsCard extends StatelessWidget {
  const SyncAndStatsCard({
    super.key,
    required this.memorialCount,
    required this.placesCount,
    required this.generationsCount,
    this.onTapMemorials,
    this.onTapPlaces,
    this.onTapGenerations,
  });

  final int memorialCount;
  final int placesCount;
  final int generationsCount;
  final VoidCallback? onTapMemorials;
  final VoidCallback? onTapPlaces;
  final VoidCallback? onTapGenerations;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Status Pill (Kahf Protection Active style)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              onTap: () => SettingsBackupSheet.show(context),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppIcon(
                          icon: HugeIcons.strokeRoundedSecurityCheck,
                          size: 16.sp,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Storage Protected',
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            'Offline ready • Tap to manage cloud sync',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Divider(color: cs.outlineVariant, height: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  value: '$memorialCount',
                  label: 'home.stat_memorials'.tr(),
                  cs: cs,
                  tt: tt,
                  onTap: onTapMemorials,
                ),
                Container(
                  height: 30.h,
                  width: 1,
                  color: cs.outlineVariant,
                ),
                _buildStatItem(
                  value: '$placesCount',
                  label: 'home.stat_places'.tr(),
                  cs: cs,
                  tt: tt,
                  onTap: onTapPlaces,
                ),
                Container(
                  height: 30.h,
                  width: 1,
                  color: cs.outlineVariant,
                ),
                _buildStatItem(
                  value: '$generationsCount',
                  label: 'home.stat_generations'.tr(),
                  cs: cs,
                  tt: tt,
                  onTap: onTapGenerations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required ColorScheme cs,
    required TextTheme tt,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            if (onTap != null) {
              HapticFeedback.lightImpact();
              onTap();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
