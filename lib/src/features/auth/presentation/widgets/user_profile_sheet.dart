import 'dart:async';
import 'dart:io';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import 'package:memorialkeeper/src/features/auth/domain/entities/user.dart';
import 'package:memorialkeeper/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:memorialkeeper/src/features/auth/presentation/providers/session_bloc.dart';
import '../../../memorials/presentation/widgets/photo_picker_sheet.dart';

/// Bottom sheet allowing users to view and update their profile details
/// (Name, Profile Picture, and optional Date of Birth).
class UserProfileSheet extends StatefulWidget {
  const UserProfileSheet({
    super.key,
    required this.user,
  });

  final AppUser user;

  static Future<void> show(BuildContext context, AppUser user) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => UserProfileSheet(user: user),
    );
  }

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  File? _pickedImage;
  String? _currentPhotoUrl;
  DateTime? _selectedDob;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _currentPhotoUrl = widget.user.photoUrl;

    if (widget.user.dateOfBirth != null &&
        widget.user.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDob = DateTime.parse(widget.user.dateOfBirth!);
      } catch (_) {
        _selectedDob = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null && mounted) {
        final processed = await AppImageCropperScreen.cropAndCompress(
          context,
          imageFile: File(picked.path),
          isCircle: true,
          title: 'Crop Profile Avatar',
          aspectRatio: 1,
        );
        if (processed != null && mounted) {
          setState(() {
            _pickedImage = processed;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        showToast(context, message: 'Could not select image', status: 'error');
      }
    }
  }

  Future<void> _showImagePickerOptions() async {
    final hasPhoto = _pickedImage != null ||
        (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty);

    final action = await showPhotoPickerSheet(
      context,
      isGravePhoto: false,
      hasExistingPhoto: hasPhoto,
    );

    if (action == null) return;

    if (action == 'camera') {
      await _pickImage(ImageSource.camera);
    } else if (action == 'gallery') {
      await _pickImage(ImageSource.gallery);
    } else if (action == 'remove') {
      setState(() {
        _pickedImage = null;
        _currentPhotoUrl = null;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDob ?? DateTime(now.year - 25, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: context.theme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final newName = _nameController.text.trim();
    final dobString = _selectedDob != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDob!)
        : null;

    String? photoUrl = _currentPhotoUrl;

    if (_pickedImage != null) {
      // 1. Ensure compressed then upload new image to Cloudflare R2
      final compressed = await ImageCompressionService.instance.compressImage(
        _pickedImage!,
        quality: 85,
      );
      final uploadRes = await R2StorageService.instance.uploadUserProfilePhoto(
        userId: widget.user.id,
        file: compressed,
      );

      final uploadedUrl = uploadRes.fold(
        (failure) {
          if (mounted) {
            showToast(context, message: 'Upload failed: ${failure.message}', status: 'error');
          }
          return null;
        },
        (result) => result.publicUrl,
      );

      if (uploadedUrl == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      // If user had a previous photo on R2, delete it
      if (widget.user.photoUrl != null &&
          widget.user.photoUrl!.isNotEmpty &&
          widget.user.photoUrl != uploadedUrl) {
        unawaited(R2StorageService.instance.deleteObject(widget.user.photoUrl!));
      }

      photoUrl = uploadedUrl;
    } else if (_currentPhotoUrl == null &&
        widget.user.photoUrl != null &&
        widget.user.photoUrl!.isNotEmpty) {
      // User tapped "remove" photo: delete old photo from R2
      unawaited(R2StorageService.instance.deleteObject(widget.user.photoUrl!));
      photoUrl = null;
    }

    final result = await AuthRepositoryImpl().updateProfile(
      userId: widget.user.id,
      name: newName,
      photoUrl: photoUrl,
      dateOfBirth: dobString,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (updatedUser) {
        context.read<SessionBloc>().add(SessionUserUpdated(updatedUser));
        Navigator.of(context).pop();
        showGlobalToast(
          message: 'auth.profile_updated'.tr(),
          status: 'success',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

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

            // Header Row
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
                            icon: HugeIcons.strokeRoundedUser,
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
                              'auth.profile_title'.tr(),
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'auth.profile_subtitle'.tr(),
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

            SizedBox(height: 24.h),

            // Profile Avatar with Camera Badge
            Center(
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 96.r,
                      height: 96.r,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(cs),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.surface,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 15.sp,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton(
                onPressed: _showImagePickerOptions,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'auth.change_photo'.tr(),
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Name
                  AppTextField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    label: 'auth.name'.tr(),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'auth.name_required'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  // Email (Read-only)
                  AppTextField(
                    controller: _emailController,
                    enabled: false,
                    label: 'auth.email'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: Icon(
                      Icons.lock_outline,
                      size: 18.sp,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Date of Birth (Optional)
                  InkWell(
                    onTap: _isSaving ? null : _selectDateOfBirth,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: cs.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: 20.sp,
                            color: cs.onSurfaceVariant,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'auth.date_of_birth_optional'.tr(),
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _selectedDob != null
                                      ? DateFormat('d MMMM yyyy')
                                          .format(_selectedDob!)
                                      : 'auth.not_specified'.tr(),
                                  style: tt.bodyMedium?.copyWith(
                                    color: _selectedDob != null
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                    fontWeight: _selectedDob != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedDob != null && !_isSaving)
                            IconButton(
                              icon: Icon(Icons.close,
                                  size: 18.sp, color: cs.onSurfaceVariant),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() => _selectedDob = null);
                              },
                            )
                          else
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 20.sp,
                              color: cs.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Save Changes Button
                  AppButton(
                    label: 'auth.save_changes'.tr(),
                    isFullWidth: true,
                    isLoading: _isSaving,
                    height: ButtonSize.large,
                    onPressed: _isSaving ? null : _handleSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(ColorScheme cs) {
    if (_pickedImage != null) {
      return Image.file(
        _pickedImage!,
        fit: BoxFit.cover,
        width: 96.r,
        height: 96.r,
      );
    }

    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      if (_currentPhotoUrl!.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: _currentPhotoUrl!,
          fit: BoxFit.cover,
          width: 96.r,
          height: 96.r,
          placeholder: (_, __) => Center(
            child: AppIcon(
              icon: HugeIcons.strokeRoundedUser,
              size: 40.sp,
              color: cs.primary,
            ),
          ),
          errorWidget: (_, __, ___) => Center(
            child: AppIcon(
              icon: HugeIcons.strokeRoundedUser,
              size: 40.sp,
              color: cs.primary,
            ),
          ),
        );
      } else {
        final localFile = File(_currentPhotoUrl!);
        if (localFile.existsSync()) {
          return Image.file(
            localFile,
            fit: BoxFit.cover,
            width: 96.r,
            height: 96.r,
          );
        }
      }
    }

    return Center(
      child: AppIcon(
        icon: HugeIcons.strokeRoundedUser,
        size: 40.sp,
        color: cs.primary,
      ),
    );
  }
}
