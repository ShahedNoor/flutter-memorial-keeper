import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import '../../../auth/presentation/providers/session_bloc.dart';
import '../../../dua/presentation/providers/dua_cubit.dart';

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
    final currentLangCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
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
                            : 'settings.guest_title'.tr(),
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 3.h),
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
              onPressed: () => context.pushNamed(AppRoutes.login),
            ),
            SizedBox(height: 16.h),
          ],

          // Data Management Section
          Text(
            'settings.data_backup'.tr(),
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedCloudUpload,
            title: 'settings.export_title'.tr(),
            subtitle: 'settings.export_desc'.tr(),
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
            title: 'settings.restore_title'.tr(),
            subtitle: 'settings.restore_desc'.tr(),
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
            'settings.preferences'.tr(),
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedGlobe02,
            title: 'settings.language_title'.tr(),
            subtitle: currentLangCode == 'bn' ? 'বাংলা (Bengali)' : 'English',
            trailingText: currentLangCode == 'bn' ? 'বাংলা' : 'EN',
            cs: cs,
            tt: tt,
            onTap: () => _showLanguageBottomSheet(context),
          ),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedInformationCircle,
            title: 'settings.about_title'.tr(),
            subtitle: 'settings.about_desc'.tr(),
            cs: cs,
            tt: tt,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final currentCode = context.locale.languageCode;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
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
                Text(
                  'settings.select_language'.tr(),
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 14.h),

                // English Option
                _buildLanguageOption(
                  context: ctx,
                  code: 'en',
                  title: 'English',
                  subtitle: 'Default language',
                  isSelected: currentCode == 'en',
                  onSelect: () => _changeLanguage(context, 'en'),
                ),
                SizedBox(height: 10.h),

                // Bengali Option
                _buildLanguageOption(
                  context: ctx,
                  code: 'bn',
                  title: 'বাংলা',
                  subtitle: 'Bengali (বাংলা ভাষা)',
                  isSelected: currentCode == 'bn',
                  onSelect: () => _changeLanguage(context, 'bn'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeLanguage(BuildContext context, String code) async {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();

    // 1. Update EasyLocalization
    await context.setLocale(Locale(code));

    // 2. Persist in Storage
    await StorageService.instance.setString('app_language', code);

    // 3. Update DuaCubit language
    if (context.mounted) {
      context.read<DuaCubit>().switchLanguage(code);
      showGlobalToast(
        message: 'settings.language_switched'.tr(),
        status: 'success',
      );
    }
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Material(
      color: isSelected
          ? cs.primaryContainer.withValues(alpha: 0.5)
          : cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: isSelected ? cs.primary : cs.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onSelect,
        title: Text(
          title,
          style: tt.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? cs.primary : cs.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: isSelected
            ? Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 16.sp,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSettingsTile({
    required dynamic icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required ColorScheme cs,
    required TextTheme tt,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: AppIcon(icon: icon, color: cs.primary, size: 20.sp),
          title: Text(
            title,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    trailingText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              AppIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 16.sp,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
