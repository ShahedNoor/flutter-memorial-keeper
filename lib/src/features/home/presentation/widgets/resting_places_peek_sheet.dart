import 'dart:io';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../../../memorials/domain/entities/memorial.dart';

/// Modal bottom sheet displaying resting places and cemetery groupings.
class RestingPlacesPeekSheet extends StatelessWidget {
  const RestingPlacesPeekSheet({
    super.key,
    required this.memorials,
  });

  final List<Memorial> memorials;

  static Future<void> show(BuildContext context, List<Memorial> memorials) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => RestingPlacesPeekSheet(memorials: memorials),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

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

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              // Top Bar: Centered Drag Handle with Close Button on the Right
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 0),
                child: Row(
                  children: [
                    SizedBox(width: 40.w), // Balance to keep pill centered
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 38.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: AppIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 20.sp,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Sheet Title Row
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        size: 22.sp,
                        color: cs.primary,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resting Places & Cemeteries',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            cemeteryList.isEmpty
                                ? 'No resting places recorded'
                                : '${cemeteryList.length} unique cemeteries recorded',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: cs.outlineVariant, height: 1),

              // Content List
              Expanded(
                child: cemeteryList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                size: 48.sp,
                                color: cs.outline,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No Resting Places Recorded Yet',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Add cemetery names and grave plot details when recording loved ones.',
                                textAlign: TextAlign.center,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        itemCount: cemeteryList.length,
                        itemBuilder: (context, index) {
                          final entry = cemeteryList[index];
                          final cemeteryName = entry.key;
                          final residents = entry.value;

                          return _buildCemeteryCard(
                            context: context,
                            cemeteryName: cemeteryName,
                            residents: residents,
                            cs: cs,
                            tt: tt,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCemeteryCard({
    required BuildContext context,
    required String cemeteryName,
    required List<Memorial> residents,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final firstArea = residents
        .map((m) => m.cemeteryArea?.trim())
        .firstWhere((a) => a != null && a.isNotEmpty, orElse: () => null);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cemetery Header
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedMosque01,
                    size: 18.sp,
                    color: cs.primary,
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
                      if (firstArea != null && firstArea != cemeteryName) ...[
                        SizedBox(height: 2.h),
                        Text(
                          firstArea,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${residents.length} resting here',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: cs.outlineVariant, height: 1),

          // Resident members list
          ...residents.map(
            (m) => ListTile(
              dense: true,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.memorialDetail, extra: m);
              },
              leading: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  image: m.profilePhotoPath != null &&
                          File(m.profilePhotoPath!).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(m.profilePhotoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: m.profilePhotoPath == null
                    ? Center(
                        child: Text(
                          m.fullName.isNotEmpty
                              ? m.fullName.characters.first.toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              title: Text(
                m.fullName,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                (m.gravePlot?.isNotEmpty ?? false)
                    ? '${m.displayRelationship} • Plot: ${m.gravePlot}'
                    : m.displayRelationship,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              trailing: AppIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 16.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
