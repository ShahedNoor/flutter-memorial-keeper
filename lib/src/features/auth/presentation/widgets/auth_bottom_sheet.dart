import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import '../providers/auth_bloc.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'google_logo.dart';

/// Interactive modal bottom sheet providing unified Sign In and Sign Up
/// with both Google Sign-In and Email/Password authentication.
class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({
    super.key,
    this.initialIsSignUp = false,
  });

  final bool initialIsSignUp;

  static Future<bool?> show(
    BuildContext context, {
    bool initialIsSignUp = false,
  }) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => AuthBottomSheet(initialIsSignUp: initialIsSignUp),
    );
  }

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  late bool _isSignUp;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
    // Reset any lingering failure state
    context.read<AuthBloc>().add(const AuthResetRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() {
    setState(() => _isGoogleLoading = true);
    context.read<AuthBloc>().add(GoogleSignInRequested(context: context));
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isSignUp) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              context: context,
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            LoginRequested(
              context: context,
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    bool isSending = false;

    showDialog<void>(
      context: context,
      barrierDismissible: !isSending,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cs.surface,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: AppIcon(
                  icon: HugeIcons.strokeRoundedLockKey,
                  size: 20.sp,
                  color: cs.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'auth.forgot_password_title'.tr(),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'auth.forgot_password_subtitle'.tr(),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: 16.h),
              AppTextField(
                controller: resetEmailController,
                enabled: !isSending,
                label: 'auth.email'.tr(),
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'common.cancel'.tr(),
                    variant: ButtonVariant.outline,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                    onPressed:
                        isSending ? null : () => Navigator.of(dialogCtx).pop(),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'auth.send_reset_link'.tr(),
                    height: ButtonSize.medium,
                    isFullWidth: true,
                    isLoading: isSending,
                    onPressed: isSending
                        ? null
                        : () async {
                            final email = resetEmailController.text.trim();
                            if (email.isEmpty ||
                                !AppUtils.isValidEmail(email)) {
                              showToast(
                                context,
                                message: 'auth.email_invalid'.tr(),
                                status: 'error',
                              );
                              return;
                            }

                            setDialogState(() => isSending = true);

                            final result = await AuthRepositoryImpl()
                                .forgotPassword(email: email);

                            if (!dialogCtx.mounted) return;

                            result.fold(
                              (failure) {
                                setDialogState(() => isSending = false);
                                showToast(
                                  dialogCtx,
                                  message: failure.message,
                                  status: 'error',
                                );
                              },
                              (_) async {
                                // 1. Dismiss the dialog first
                                Navigator.of(dialogCtx).pop();

                                // 2. Brief delay for dialog exit animation to finish
                                await Future<void>.delayed(
                                  const Duration(milliseconds: 250),
                                );

                                // 3. Dismiss the bottom sheet
                                if (!mounted) return;
                                Navigator.of(context).pop();

                                // 4. Display confirmation toast on the host screen
                                showGlobalToast(
                                  message: 'auth.reset_link_sent'.tr(),
                                  status: 'success',
                                );
                              },
                            );
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthLoading) {
          setState(() => _isGoogleLoading = false);
        }
        if (state is AuthSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading || _isGoogleLoading;

        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Header with Motif, Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: AppIcon(
                                icon: HugeIcons.strokeRoundedUserCheck01,
                                color: cs.primary,
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
                                  _isSignUp
                                      ? 'auth.create_account'.tr()
                                      : 'auth.log_in'.tr(),
                                  style: tt.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _isSignUp
                                      ? 'auth.sign_up_subtitle'.tr()
                                      : 'auth.log_in_subtitle'.tr(),
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

                // Segmented Tab Switcher (Sign In vs Create Account)
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AuthTabButton(
                          label: 'auth.sign_in'.tr(),
                          isSelected: !_isSignUp,
                          onTap: () {
                            if (_isSignUp) {
                              setState(() {
                                _isSignUp = false;
                                _formKey.currentState?.reset();
                              });
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthResetRequested());
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: _AuthTabButton(
                          label: 'auth.sign_up'.tr(),
                          isSelected: _isSignUp,
                          onTap: () {
                            if (!_isSignUp) {
                              setState(() {
                                _isSignUp = true;
                                _formKey.currentState?.reset();
                              });
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthResetRequested());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // 1. Continue with Google Button
                InkWell(
                  onTap: isLoading ? null : _handleGoogleSignIn,
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: cs.outlineVariant,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isGoogleLoading)
                          SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primary,
                            ),
                          )
                        else
                          const GoogleLogo(size: 20),
                        SizedBox(width: 12.w),
                        Text(
                          'auth.continue_with_google'.tr(),
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                // Divider ("or continue with email")
                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outlineVariant)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'auth.or_continue_with_email'.tr(),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: cs.outlineVariant)),
                  ],
                ),

                SizedBox(height: 16.h),

                // 2. Email & Password Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isSignUp) ...[
                        AppTextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          label: 'auth.name'.tr(),
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) {
                            if (AppUtils.isBlank(v)) {
                              return 'auth.name_required'.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                      ],
                      AppTextField(
                        controller: _emailController,
                        enabled: !isLoading,
                        label: 'auth.email'.tr(),
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.email_required'.tr();
                          }
                          if (!AppUtils.isValidEmail(v!)) {
                            return 'auth.email_invalid'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        label: 'auth.password'.tr(),
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20.sp,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.password_required'.tr();
                          }
                          if (v!.length < 6) {
                            return 'auth.password_too_short'.tr();
                          }
                          return null;
                        },
                      ),
                      if (_isSignUp) ...[
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: _confirmPasswordController,
                          enabled: !isLoading,
                          label: 'auth.confirm_password'.tr(),
                          obscureText: _obscureConfirm,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.sp,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          validator: (v) {
                            if (AppUtils.isBlank(v)) {
                              return 'auth.confirm_password_required'.tr();
                            }
                            if (v != _passwordController.text) {
                              return 'auth.passwords_do_not_match'.tr();
                            }
                            return null;
                          },
                        ),
                      ],
                      if (!_isSignUp) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed:
                                isLoading ? null : _showForgotPasswordDialog,
                            child: Text(
                              'auth.forgot_password'.tr(),
                              style: tt.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: _isSignUp ? 18.h : 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: _isSignUp
                              ? 'auth.create_account'.tr()
                              : 'auth.log_in'.tr(),
                          isLoading: isLoading && !_isGoogleLoading,
                          onPressed: isLoading ? null : _handleSubmit,
                          width: ButtonSize.large,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuthTabButton extends StatelessWidget {
  const _AuthTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: tt.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
