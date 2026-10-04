import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';

/// Primary action bar with Facebook-style buttons: Edit Profile, Share Card,
/// and Turn-by-turn Navigation.
class MemorialProfileActionBar extends StatelessWidget {
  const MemorialProfileActionBar({
    super.key,
    required this.memorial,
    required this.onShare,
    this.isSharing = false,
  });

  final Memorial memorial;
  final VoidCallback onShare;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasCoordinates = memorial.latitude != null &&
        memorial.longitude != null &&
        memorial.latitude != 0.0 &&
        memorial.longitude != 0.0;

    return Row(
      children: [
        // Edit Profile Button
        Expanded(
          flex: 5,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              context.push(
                AppRoutes.addMemorial,
                extra: memorial,
              );
            },
            icon: Icon(Icons.edit_rounded, size: 16.sp),
            label: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Share Tribute Card Button
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface,
              side: BorderSide(
                color: cs.outlineVariant,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: isSharing ? null : onShare,
            icon: isSharing
                ? SizedBox(
                    width: 14.sp,
                    height: 14.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : Icon(Icons.share_rounded, size: 16.sp),
            label: Text(
              isSharing ? 'Sharing...' : 'Share Card',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Navigation directions shortcut
        if (hasCoordinates) ...[
          SizedBox(width: 8.w),
          Container(
            height: 44.h,
            width: 44.h,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              tooltip: 'Open in Maps',
              icon: Icon(
                Icons.directions_rounded,
                color: cs.primary,
                size: 20.sp,
              ),
              onPressed: () {
                LocationService.instance.openInMaps(
                  memorial.latitude!,
                  memorial.longitude!,
                  label: '${memorial.fullName} Resting Place',
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
