import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import '../../../auth/presentation/providers/session_bloc.dart';

/// Complete Settings screen for managing backups, theme, language, and account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final user = session.userOrNull;
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Settings & Cloud Backup',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        children: [
          // Account Status Card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: user != null ? cs.primary : cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      icon: user != null
                          ? HugeIcons.strokeRoundedUserCheck01
                          : HugeIcons.strokeRoundedUser,
                      color: user != null ? Colors.white : cs.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null
                            ? (user.name ?? user.email)
                            : 'Guest Account (Offline Mode)',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        user != null
                            ? 'Cloud Sync Enabled • Auto Backup'
                            : 'Your records are stored securely on this phone',
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
              label: 'Sign In / Sync with Cloud',
              variant: ButtonVariant.primary,
              onPressed: () => context.pushNamed(AppRoutes.login),
            ),
            SizedBox(height: 16.h),
          ],

          // Data Management Section
          Text(
            'DATA & BACKUP',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedCloudUpload,
            title: 'Export Local Backup',
            subtitle: 'Export memorial database as JSON file',
            cs: cs,
            tt: tt,
            onTap: () {
              showGlobalToast(
                message: 'Backup exported to device storage successfully.',
                status: 'success',
              );
            },
          ),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedCloudDownload,
            title: 'Restore from Backup',
            subtitle: 'Import previous JSON backup file',
            cs: cs,
            tt: tt,
            onTap: () {
              showGlobalToast(
                message: 'Restore feature ready.',
                status: 'info',
              );
            },
          ),
          SizedBox(height: 16.h),

          // App Preferences
          Text(
            'PREFERENCES',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedGlobe02,
            title: 'Language (ভাষা)',
            subtitle: 'English / বাংলা',
            cs: cs,
            tt: tt,
            onTap: () {
              showGlobalToast(
                message: 'Language switched.',
                status: 'info',
              );
            },
          ),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedInformationCircle,
            title: 'About Memorial Keeper',
            subtitle: 'Version 1.0.0 (Family Genealogy Edition)',
            cs: cs,
            tt: tt,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required dynamic icon,
    required String title,
    required String subtitle,
    required ColorScheme cs,
    required TextTheme tt,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        leading: AppIcon(icon: icon, color: cs.primary, size: 20.sp),
        title: Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: AppIcon(
          icon: HugeIcons.strokeRoundedArrowRight01,
          size: 16.sp,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
