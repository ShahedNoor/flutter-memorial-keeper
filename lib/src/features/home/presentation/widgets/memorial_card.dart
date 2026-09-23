import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import '../models/sample_memorial.dart';

/// Dignified memorial card with avatar frame, relationship badge, lifespan, and resting place pill.
class MemorialCard extends StatelessWidget {
  const MemorialCard({
    super.key,
    required this.memorial,
    this.onTap,
  });

  final SampleMemorial memorial;
  final VoidCallback? onTap;

  void _onSendDua(BuildContext context) {
    HapticFeedback.lightImpact();
    showGlobalToast(
      message: 'Dua sent for ${memorial.fullName}.',
      status: 'success',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Avatar frame
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: AppIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: cs.primary,
                      size: 26.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memorial.fullName,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          memorial.relationship,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '${memorial.birthYear} – ${memorial.passingYear} (${memorial.age} yrs)',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tribute / Dua Button
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: AppIcon(
                    icon: HugeIcons.strokeRoundedFavourite,
                    color: cs.primary,
                    size: 18.sp,
                  ),
                  onPressed: () => _onSendDua(context),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Resting Place Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  AppIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    size: 14.sp,
                    color: cs.primary,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      memorial.restingPlace,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
