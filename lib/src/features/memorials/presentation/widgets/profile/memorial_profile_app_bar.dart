import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';

/// SliverAppBar for the Memorial Profile screen with cover photo, back button,
/// share shortcut, and quick favorite/delete actions.
class MemorialProfileAppBar extends StatelessWidget {
  const MemorialProfileAppBar({
    super.key,
    required this.memorial,
    required this.isSharing,
    required this.onShare,
    required this.onToggleFavorite,
    required this.onDelete,
  });

  final Memorial memorial;
  final bool isSharing;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasGravePhoto = memorial.gravePhotoPath != null &&
        File(memorial.gravePhotoPath!).existsSync();

    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      foregroundColor: Colors.white,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: Center(
          child: Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 19.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      actions: [
        // Share Tribute Button
        Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Share Tribute Card',
            icon: isSharing
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
            onPressed: onShare,
          ),
        ),

        // Favorite Toggle Button
        Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: memorial.isFavorite
                ? 'Remove from Favorites'
                : 'Add to Favorites',
            icon: Icon(
              memorial.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: memorial.isFavorite ? Colors.redAccent : Colors.white,
              size: 19.sp,
            ),
            onPressed: onToggleFavorite,
          ),
        ),

        // More Options Popup Menu
        Container(
          margin: EdgeInsets.only(right: 12.w),
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Delete Memorial',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
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
                      size: 140.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // Subtle dark gradient vignette
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            // Arabic remembrance watermark
            Positioned(
              bottom: 16.h,
              right: 20.w,
              child: Text(
                'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
