import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';
import 'profile_image_viewer.dart';

/// Card showing distinct family memory photos with thumbnails and fullscreen viewer.
/// Automatically hides itself if no distinct memory photos exist.
class MemorialPhotoGalleryCard extends StatelessWidget {
  const MemorialPhotoGalleryCard({
    super.key,
    required this.memorial,
  });

  final Memorial memorial;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    // Filter to distinct memory photos only (excluding cover & avatar photos)
    final memoryPhotos = memorial.memoryPhotoPaths.where((p) {
      if (p == memorial.gravePhotoPath || p == memorial.profilePhotoPath) {
        return false;
      }
      return File(p).existsSync();
    }).toList();

    if (memoryPhotos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: cs.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Memory Photos (${memoryPhotos.length})',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Photo Thumbnails Horizontal List
            SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: memoryPhotos.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final photoPath = memoryPhotos[index];
                  return GestureDetector(
                    onTap: () => showFullscreenImage(
                      context,
                      photoPath,
                      memorial.fullName,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        File(photoPath),
                        width: 100.h,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
