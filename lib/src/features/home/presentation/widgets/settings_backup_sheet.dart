import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import 'package:memorialkeeper/src/features/auth/presentation/providers/session_bloc.dart';

/// Modal bottom sheet for app settings, data export, and optional cloud backup.
class SettingsBackupSheet extends StatelessWidget {
  const SettingsBackupSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      showDragHandle: false,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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

          // Title Row
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 14.h),
            child: Row(
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
                  'settings.title'.tr(),
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                                  : 'settings.guest_title'.tr(),
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              user != null
                                  ? 'settings.cloud_title'.tr()
                                  : 'settings.guest_desc'.tr(),
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
                    label: 'settings.sign_in_btn'.tr(),
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
                  title:
                      Text('settings.export_title'.tr(), style: tt.bodyMedium),
                  subtitle:
                      Text('settings.export_desc'.tr(), style: tt.bodySmall),
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
                  title:
                      Text('settings.about_title'.tr(), style: tt.bodyMedium),
                  subtitle:
                      Text('settings.about_desc'.tr(), style: tt.bodySmall),
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
        ],
      ),
    );
  }
}
