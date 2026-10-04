import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import 'package:memorialkeeper/src/features/memorials/domain/entities/memorial.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/providers/memorial_bloc.dart';
import 'package:memorialkeeper/src/features/home/presentation/widgets/home_empty_state.dart';

/// Cemetery and Resting Places directory dynamically aggregated from user-added memorial records.
class RestingPlacesScreen extends StatelessWidget {
  const RestingPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final memorialState = context.watch<MemorialBloc>().state;
    final memorials = memorialState.memorials;

    // Group memorials dynamically by cemetery or recorded area
    final Map<String, List<Memorial>> cemeteryMap = {};
    for (final m in memorials) {
      final name = m.cemeteryName?.trim();
      final area = m.cemeteryArea?.trim();
      if ((name != null && name.isNotEmpty) ||
          (area != null && area.isNotEmpty)) {
        final key = (name != null && name.isNotEmpty) ? name : area!;
        cemeteryMap.putIfAbsent(key, () => []).add(m);
      }
    }

    final cemeteryList = cemeteryMap.entries.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Resting Places',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: cemeteryList.isEmpty
          ? const Center(
              child: HomeEmptyState(
                message: 'No Resting Places Recorded Yet',
                subtitle:
                    'Add cemetery name, area, or plot details when adding or editing a memorial to see them mapped here.',
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              itemCount: cemeteryList.length,
              itemBuilder: (context, index) {
                final entry = cemeteryList[index];
                final cemeteryName = entry.key;
                final residents = entry.value;

                final areas = residents
                    .map((m) => m.cemeteryArea?.trim())
                    .where((a) => a != null && a.isNotEmpty)
                    .toSet()
                    .join(' • ');

                return Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: AppIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: cs.primary,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cemeteryName,
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                if (areas.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    areas,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${residents.length} ${residents.length == 1 ? 'Resting' : 'Resting'}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                        height: 1,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Departed Loved Ones Here:',
                        style: tt.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          fontSize: 11.5.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ...residents.map(
                        (m) => InkWell(
                          onTap: () {
                            context.push(AppRoutes.memorialDetail, extra: m);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 2.w,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 5.r,
                                  height: 5.r,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    m.fullName,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (m.gravePlot != null &&
                                    m.gravePlot!.trim().isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      m.gravePlot!.trim(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 4.w),
                                AppIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  size: 14.sp,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
