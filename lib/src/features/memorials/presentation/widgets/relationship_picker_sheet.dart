import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

typedef RelationshipOption = ({String key, String label});

/// Shows a modern floating bottom sheet to pick relationship.
Future<String?> showRelationshipPickerSheet(
  BuildContext context, {
  required String currentRelationship,
  required List<RelationshipOption> relationships,
}) {
  final cs = context.colors;
  final tt = context.textTheme;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.55,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Relationship',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: AppIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          size: 18.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  itemCount: relationships.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                  itemBuilder: (ctx, index) {
                    final item = relationships[index];
                    final isSelected = item.key == currentRelationship;
                    return InkWell(
                      onTap: () => Navigator.pop(ctx, item.key),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 13.h,
                        ),
                        color: isSelected
                            ? cs.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? cs.primary
                                      : cs.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              AppIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                size: 18.sp,
                                color: cs.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
