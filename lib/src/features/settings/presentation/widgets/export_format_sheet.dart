import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../imports/core_imports.dart';

/// Modal bottom sheet allowing users to choose their desired export format.
class ExportFormatSheet extends StatelessWidget {
  const ExportFormatSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cs = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const ExportFormatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Pill
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedCloudUpload,
                    size: 20.sp,
                    color: cs.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Memorial Database',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Choose your preferred file format',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            SizedBox(height: 18.h),

            // Option 1: CSV (Google Sheets & Excel) - Recommended
            _ExportOptionTile(
              title: 'Google Sheets & Excel (CSV)',
              subtitle:
                  'Universal spreadsheet table. Opens in Google Sheets on phone & Excel on PC.',
              badge: 'Recommended',
              badgeColor: cs.primary,
              icon: HugeIcons.strokeRoundedTable,
              iconBgColor: cs.primary.withValues(alpha: 0.12),
              iconColor: cs.primary,
              cs: cs,
              tt: tt,
              onTap: () async {
                Navigator.pop(context);
                showGlobalToast(
                  message: 'Generating Google Sheets (CSV) export...',
                  status: 'info',
                );
                final success = await BackupRestoreService.instance.exportToCsv();
                if (success) {
                  showGlobalToast(
                    message: 'CSV file ready to share & save.',
                    status: 'success',
                  );
                }
              },
            ),
            SizedBox(height: 10.h),

            // Option 2: Microsoft Excel (.xlsx)
            _ExportOptionTile(
              title: 'Microsoft Excel (.xlsx)',
              subtitle:
                  'Formatted Excel spreadsheet workbook with styled columns.',
              badge: 'Excel',
              badgeColor: const Color(0xFF107C41), // Excel green
              icon: HugeIcons.strokeRoundedDocumentAttachment,
              iconBgColor: const Color(0xFF107C41).withValues(alpha: 0.12),
              iconColor: const Color(0xFF107C41),
              cs: cs,
              tt: tt,
              onTap: () async {
                Navigator.pop(context);
                showGlobalToast(
                  message: 'Generating Excel (.xlsx) workbook...',
                  status: 'info',
                );
                final success = await BackupRestoreService.instance.exportToExcel();
                if (success) {
                  showGlobalToast(
                    message: 'Excel workbook ready to share & save.',
                    status: 'success',
                  );
                }
              },
            ),
            SizedBox(height: 10.h),

            // Option 3: Full JSON System Backup
            _ExportOptionTile(
              title: 'Full System Backup (JSON)',
              subtitle:
                  'Complete raw database snapshot for archiving or restoring.',
              badge: 'Raw Backup',
              badgeColor: cs.tertiary,
              icon: HugeIcons.strokeRoundedDatabase,
              iconBgColor: cs.tertiary.withValues(alpha: 0.12),
              iconColor: cs.tertiary,
              cs: cs,
              tt: tt,
              onTap: () async {
                Navigator.pop(context);
                showGlobalToast(
                  message: 'Generating full JSON backup...',
                  status: 'info',
                );
                final success = await BackupRestoreService.instance.exportToJson();
                if (success) {
                  showGlobalToast(
                    message: 'JSON backup ready to share & save.',
                    status: 'success',
                  );
                }
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.cs,
    required this.tt,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final dynamic icon;
  final Color iconBgColor;
  final Color iconColor;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: AppIcon(
                  icon: icon,
                  size: 22.sp,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          badge,
                          style: tt.labelSmall?.copyWith(
                            color: badgeColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
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
            SizedBox(width: 8.w),
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
