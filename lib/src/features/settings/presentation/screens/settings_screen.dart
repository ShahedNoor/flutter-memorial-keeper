import 'dart:io';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import '../../../auth/presentation/providers/session_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../dua/presentation/providers/dua_cubit.dart';

import '../../../auth/presentation/widgets/auth_bottom_sheet.dart';
import '../../../auth/presentation/widgets/user_profile_sheet.dart';
import '../../../memorials/presentation/providers/memorial_bloc.dart';
import '../widgets/export_format_sheet.dart';

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
          // Account Status Card (Tappable to view/edit profile or sign in)
          InkWell(
            onTap: user != null
                ? () => UserProfileSheet.show(context, user)
                : () => AuthBottomSheet.show(context),
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: user != null ? cs.primary : cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatar(user, cs),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? ((user.name != null && user.name!.isNotEmpty)
                                  ? user.name!
                                  : user.email)
                              : 'settings.guest_title'.tr(),
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          user != null
                              ? (user.email.isNotEmpty
                                  ? user.email
                                  : 'settings.cloud_title'.tr())
                              : 'settings.guest_desc'.tr(),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (user != null &&
                            user.dateOfBirth != null &&
                            user.dateOfBirth!.isNotEmpty) ...[
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(Icons.cake_outlined,
                                  size: 13.sp, color: cs.primary),
                              SizedBox(width: 4.w),
                              Text(
                                user.dateOfBirth!,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          if (user == null) ...[
            AppButton(
              label: 'settings.sign_in_btn'.tr(),
              variant: ButtonVariant.primary,
              onPressed: () => AuthBottomSheet.show(context),
            ),
            SizedBox(height: 16.h),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'auth.edit_profile'.tr(),
                    variant: ButtonVariant.primary,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                    prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => UserProfileSheet.show(context, user),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppButton(
                    label: 'Sign Out',
                    variant: ButtonVariant.outline,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                    onPressed: () {
                      context
                          .read<SessionBloc>()
                          .add(const SessionLogoutRequested());
                      showGlobalToast(
                        message: 'Signed out successfully',
                        status: 'info',
                      );
                    },
                  ),
                ),
              ],
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
            onTap: () => ExportFormatSheet.show(context),
          ),
          _buildSettingsTile(
            icon: HugeIcons.strokeRoundedCloudDownload,
            title: 'settings.restore_title'.tr(),
            subtitle: 'settings.restore_desc'.tr(),
            cs: cs,
            tt: tt,
            onTap: () => _handleRestore(context),
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

  Widget _buildAvatar(AppUser? user, ColorScheme cs) {
    if (user == null) {
      return Center(
        child: AppIcon(
          icon: HugeIcons.strokeRoundedUser,
          color: cs.primary,
          size: 24.sp,
        ),
      );
    }

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      if (user.photoUrl!.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: user.photoUrl!,
          fit: BoxFit.cover,
          placeholder: (_, __) => Center(
            child: AppIcon(
              icon: HugeIcons.strokeRoundedUserCheck01,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          errorWidget: (_, __, ___) => Center(
            child: AppIcon(
              icon: HugeIcons.strokeRoundedUserCheck01,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        );
      } else {
        final localFile = File(user.photoUrl!);
        if (localFile.existsSync()) {
          return Image.file(
            localFile,
            fit: BoxFit.cover,
          );
        }
      }
    }

    return Center(
      child: AppIcon(
        icon: HugeIcons.strokeRoundedUserCheck01,
        color: Colors.white,
        size: 24.sp,
      ),
    );
  }

  Future<void> _handleRestore(BuildContext context) async {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    showGlobalToast(
      message: 'Opening file picker...',
      status: 'info',
    );

    final result = await BackupRestoreService.instance.pickAndRestoreFile();
    if (result == null) return; // user cancelled

    if (!context.mounted) return;

    if (result.errorMessage != null) {
      showGlobalToast(
        message: result.errorMessage!,
        status: 'error',
      );
      return;
    }

    // Refresh MemorialBloc so list, search, and directory immediately update
    context.read<MemorialBloc>().add(const LoadMemorials());

    showGlobalToast(
      message:
          'Restored: ${result.importedCount} new, ${result.updatedCount} updated.',
      status: 'success',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: cs.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Restore Completed',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully restored database from file:',
              style: tt.bodyMedium,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildResultRow('New Records Added', '${result.importedCount}', cs.primary, tt),
                  Divider(height: 14.h),
                  _buildResultRow('Existing Updated', '${result.updatedCount}', cs.onSurface, tt),
                  if (result.failedCount > 0) ...[
                    Divider(height: 14.h),
                    _buildResultRow('Failed / Skipped', '${result.failedCount}', cs.error, tt),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color valueColor, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodySmall),
        Text(
          value,
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
