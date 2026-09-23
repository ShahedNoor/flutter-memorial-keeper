import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Kahf DNS-style status pill & statistics summary card.
class SyncAndStatsCard extends StatelessWidget {
  const SyncAndStatsCard({
    super.key,
    required this.memorialCount,
    required this.placesCount,
    required this.generationsCount,
  });

  final int memorialCount;
  final int placesCount;
  final int generationsCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Status Pill (Kahf Protection Active style)
          Row(
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
                      'Offline ready • Instant local access',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
          SizedBox(height: 14.h),
          Divider(color: cs.outlineVariant, height: 1),
          SizedBox(height: 14.h),
          // 3 Statistics Columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('$memorialCount', 'home.stat_memorials'.tr(), cs, tt),
              Container(
                height: 30.h,
                width: 1,
                color: cs.outlineVariant,
              ),
              _buildStatItem('$placesCount', 'home.stat_places'.tr(), cs, tt),
              Container(
                height: 30.h,
                width: 1,
                color: cs.outlineVariant,
              ),
              _buildStatItem('$generationsCount', 'home.stat_generations'.tr(), cs, tt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.primary,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
