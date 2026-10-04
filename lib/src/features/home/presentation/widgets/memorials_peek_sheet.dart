import 'dart:io';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../../../memorials/domain/entities/memorial.dart';

/// Modal bottom sheet displaying all recorded memorials with instant search.
class MemorialsPeekSheet extends StatefulWidget {
  const MemorialsPeekSheet({
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
      builder: (ctx) => MemorialsPeekSheet(memorials: memorials),
    );
  }

  @override
  State<MemorialsPeekSheet> createState() => _MemorialsPeekSheetState();
}

class _MemorialsPeekSheetState extends State<MemorialsPeekSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final filtered = widget.memorials.where((m) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return m.fullName.toLowerCase().contains(q) ||
          (m.arabicName?.toLowerCase().contains(q) ?? false) ||
          m.displayRelationship.toLowerCase().contains(q);
    }).toList();

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
                        icon: HugeIcons.strokeRoundedUserGroup,
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
                            'Recorded Memorials',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${widget.memorials.length} loved ones recorded',
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

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by name or relation...',
                    hintStyle: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    prefixIcon: AppIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 18.sp,
                      color: cs.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Divider(color: cs.outlineVariant, height: 1),

              // Content List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                size: 40.sp,
                                color: cs.outline,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No Memorials Found',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No records match "$_searchQuery"'
                                    : 'Add your first departed loved one to begin.',
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
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final m = filtered[index];
                          final hasPhoto = m.profilePhotoPath != null &&
                              File(m.profilePhotoPath!).existsSync();

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Material(
                              color: cs.surfaceContainerLow,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                side: BorderSide(color: cs.outlineVariant),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  context.push(AppRoutes.memorialDetail,
                                      extra: m);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: Row(
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 44.r,
                                        height: 44.r,
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          shape: BoxShape.circle,
                                          image: hasPhoto
                                              ? DecorationImage(
                                                  image: FileImage(
                                                      File(m.profilePhotoPath!)),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: !hasPhoto
                                            ? Center(
                                                child: Text(
                                                  m.fullName.isNotEmpty
                                                      ? m.fullName.characters.first
                                                          .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: cs.primary,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 12.w),

                                      // Name & Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    m.fullName,
                                                    style: tt.bodyMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: cs.onSurface,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: cs
                                                        .surfaceContainerHighest,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.r),
                                                  ),
                                                  child: Text(
                                                    m.displayRelationship,
                                                    style: tt.labelSmall
                                                        ?.copyWith(
                                                      fontSize: 10.sp,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3.h),
                                            Text(
                                              m.lifespanDisplay.isNotEmpty
                                                  ? '${m.lifespanDisplay}${(m.cemeteryName?.isNotEmpty ?? false) ? ' • ${m.cemeteryName}' : ''}'
                                                  : (m.cemeteryName ??
                                                      'No resting place recorded'),
                                              style: tt.bodySmall?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 11.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      AppIcon(
                                        icon: HugeIcons
                                            .strokeRoundedArrowRight01,
                                        size: 16.sp,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
}
