import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Clean empty state placeholder for search and category filtering.
class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({
    super.key,
    this.message = 'No records found in this category',
    this.subtitle = 'Tap the button below to add a family member.',
  });

  final String message;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                icon: HugeIcons.strokeRoundedInbox,
                size: 32.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
