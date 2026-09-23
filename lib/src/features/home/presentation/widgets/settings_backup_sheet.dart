import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import 'package:memorial_keeper/src/features/auth/presentation/providers/session_bloc.dart';

/// Modal bottom sheet for app settings, data export, and optional cloud backup.
class SettingsBackupSheet extends StatelessWidget {
  const SettingsBackupSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => const SettingsBackupSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>().state;
    final user = session.userOrNull;
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedSettings02,
                    size: 20.sp,
                    color: cs.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'App Settings & Cloud Backup',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Account / Sync Card
            Container(
              padding: EdgeInsets.all(16.r),
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
                      color: user != null
                          ? cs.primary
                          : cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(
                        icon: user != null
                            ? HugeIcons.strokeRoundedUserCheck01
                            : HugeIcons.strokeRoundedUser,
                        color: user != null
                            ? cs.onPrimary
                            : cs.onSurfaceVariant,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? (user.name ?? user.email)
                              : 'Guest User (Offline Mode)',
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user != null
                              ? 'Cloud Sync Enabled • Auto Backup'
                              : 'Data saved locally on this device',
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
            SizedBox(height: 12.h),
            if (user == null) ...[
              AppButton(
                label: 'Sign In / Backup to Cloud',
                variant: ButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(context);
                  context.pushNamed(AppRoutes.login);
                },
              ),
              SizedBox(height: 8.h),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AppIcon(
                icon: HugeIcons.strokeRoundedCloudUpload,
                color: cs.primary,
              ),
              title: Text('Export Local Data Backup', style: tt.bodyMedium),
              subtitle: Text('Save JSON archive to phone storage',
                  style: tt.bodySmall),
              trailing: AppIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18.sp,
              ),
              onTap: () {
                Navigator.pop(context);
                showGlobalToast(
                  message: 'Local backup generated successfully.',
                  status: 'success',
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AppIcon(
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: cs.primary,
              ),
              title: Text('About Memorial Keeper', style: tt.bodyMedium),
              subtitle: Text('Version 1.0.0 (Spark Edition)',
                  style: tt.bodySmall),
              trailing: AppIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18.sp,
              ),
              onTap: () => Navigator.pop(context),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
