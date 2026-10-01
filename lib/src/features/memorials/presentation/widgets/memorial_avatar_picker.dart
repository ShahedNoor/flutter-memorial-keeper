import 'dart:io';
import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Circular profile avatar picker with camera icon overlay and status label.
class MemorialAvatarPicker extends StatelessWidget {
  const MemorialAvatarPicker({
    super.key,
    required this.photoPath,
    required this.gender,
    required this.onTap,
  });

  final String? photoPath;
  final String gender;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: photoPath != null
                        ? DecorationImage(
                            image: FileImage(File(photoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: photoPath == null
                      ? Center(
                          child: AppIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            size: 40.sp,
                            color: cs.primary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            photoPath == null ? 'Tap to add photo' : 'Tap to change photo',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
