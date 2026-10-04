import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Shows a modern floating bottom sheet to pick or remove a photo.
Future<String?> showPhotoPickerSheet(
  BuildContext context, {
  required bool isGravePhoto,
  required bool hasExistingPhoto,
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
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24.r),
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
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isGravePhoto
                          ? 'Attach Resting Place Photo'
                          : 'Select Profile Photo',
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
                SizedBox(height: 14.h),
                _PhotoOptionCard(
                  title: 'Take Photo',
                  subtitle: 'Use camera to capture directly',
                  icon: HugeIcons.strokeRoundedCamera01,
                  cs: cs,
                  tt: tt,
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
                SizedBox(height: 10.h),
                _PhotoOptionCard(
                  title: 'Choose from Gallery',
                  subtitle: 'Select from saved photos & albums',
                  icon: HugeIcons.strokeRoundedImage01,
                  cs: cs,
                  tt: tt,
                  onTap: () => Navigator.pop(ctx, 'gallery'),
                ),
                if (hasExistingPhoto) ...[
                  SizedBox(height: 10.h),
                  _PhotoOptionCard(
                    title: 'Remove Photo',
                    subtitle: 'Remove current photo attachment',
                    icon: HugeIcons.strokeRoundedDelete02,
                    iconColor: cs.error,
                    titleColor: cs.error,
                    iconBgColor: cs.error.withValues(alpha: 0.12),
                    cs: cs,
                    tt: tt,
                    onTap: () => Navigator.pop(ctx, 'remove'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _PhotoOptionCard extends StatelessWidget {
  const _PhotoOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cs,
    required this.tt,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.iconBgColor,
  });

  final String title;
  final String subtitle;
  final dynamic icon;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: iconBgColor ?? cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: AppIcon(
                  icon: icon,
                  size: 22.sp,
                  color: iconColor ?? cs.primary,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            AppIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16.sp,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
