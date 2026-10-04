import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';
import 'memorial_profile_action_bar.dart';
import 'profile_image_viewer.dart';

/// Modern, dignified Facebook-style profile header with full cover photo,
/// overlapping circular avatar, centered name, Arabic calligraphy, bio tags,
/// and primary profile action buttons.
class MemorialProfileHeader extends StatelessWidget {
  const MemorialProfileHeader({
    super.key,
    required this.memorial,
    required this.birthStr,
    required this.passStr,
    required this.timePassed,
    required this.isSharing,
    required this.onShare,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final Memorial memorial;
  final String? birthStr;
  final String? passStr;
  final String timePassed;
  final bool isSharing;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    final hasProfilePhoto = memorial.profilePhotoPath != null &&
        File(memorial.profilePhotoPath!).existsSync();

    final hasGravePhoto = memorial.gravePhotoPath != null &&
        File(memorial.gravePhotoPath!).existsSync();

    return Column(
      children: [
        // 1. Cover Photo with Overlapping Centered Avatar
        // Total height: cover height (215.h) + half avatar overlap (52.r) = 267.h
        SizedBox(
          height: 215.h + 52.r,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Cover Photo Container
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 215.h,
                child: GestureDetector(
                  onTap: () {
                    if (hasGravePhoto) {
                      showFullscreenImage(
                        context,
                        memorial.gravePhotoPath!,
                        '${memorial.fullName} Resting Place',
                      );
                    }
                  },
                  child: ColoredBox(
                    color: cs.surfaceContainerHighest,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hasGravePhoto)
                          Image.file(
                            File(memorial.gravePhotoPath!),
                            fit: BoxFit.cover,
                          )
                        else
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF062319),
                                  Color(0xFF0F3B2C),
                                  Color(0xFF041912),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Opacity(
                                opacity: 0.18,
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 130.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        // Dark gradient vignette for legibility
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),

                        // Floating Top Bar Icons
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                children: [
                                  _buildCircleButton(
                                    icon: Icons.arrow_back_rounded,
                                    tooltip: 'Back',
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  const Spacer(),
                                  _buildCircleButton(
                                    icon: memorial.isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    iconColor: memorial.isFavorite
                                        ? Colors.redAccent
                                        : Colors.white,
                                    tooltip: memorial.isFavorite
                                        ? 'Remove from Favorites'
                                        : 'Add to Favorites',
                                    onPressed: onToggleFavorite,
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildCircleButton(
                                    icon: Icons.delete_outline_rounded,
                                    tooltip: 'Delete Memorial',
                                    iconColor: Colors.white,
                                    onPressed: onDelete,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Centered Overlapping Avatar (Facebook Style)
              // top: 215.h - 52.r, height: 104.r -> fully within Stack bounds for 100% reliable hit testing!
              Positioned(
                top: 215.h - 52.r,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (hasProfilePhoto) {
                      showFullscreenImage(
                        context,
                        memorial.profilePhotoPath!,
                        memorial.fullName,
                      );
                    }
                  },
                  child: Container(
                    width: 104.r,
                    height: 104.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                      border: Border.all(
                        color: cs.surface,
                        width: 4.r,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasProfilePhoto
                          ? Image.file(
                              File(memorial.profilePhotoPath!),
                              fit: BoxFit.cover,
                              width: 104.r,
                              height: 104.r,
                            )
                          : ColoredBox(
                              color: cs.primaryContainer,
                              child: Center(
                                child: Icon(
                                  memorial.gender == 'female'
                                      ? Icons.face_3_rounded
                                      : Icons.person_rounded,
                                  size: 52.sp,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Space below the avatar
        SizedBox(height: 14.h),

        // 2. Profile Details & Metadata (Centered Facebook Layout)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Full Name
              Text(
                memorial.fullName,
                textAlign: TextAlign.center,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),

              // Alternative Name
              if (memorial.arabicName != null &&
                  memorial.arabicName!.trim().isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  memorial.arabicName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ],
              SizedBox(height: 10.h),

              // Time Since Passing Badge
              if (timePassed.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13.sp,
                        color: cs.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Passed $timePassed',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],

              // Badges: Relationship & Lifespan
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      memorial.displayRelationship,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  if (birthStr != null || passStr != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${birthStr ?? '?'} — ${passStr ?? '?'} ${memorial.age != null ? '(${memorial.age} yrs)' : ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 18.h),

              // 3. Facebook-Style Action Buttons
              MemorialProfileActionBar(
                memorial: memorial,
                onShare: onShare,
                isSharing: isSharing,
              ),
              SizedBox(height: 20.h),

              // Subtle section divider
              Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    bool isLoading = false,
  }) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        icon: isLoading
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: iconColor, size: 19.sp),
        onPressed: onPressed,
      ),
    );
  }
}
