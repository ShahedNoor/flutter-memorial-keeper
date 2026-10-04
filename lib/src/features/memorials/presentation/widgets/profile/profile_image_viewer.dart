import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';

/// Shows a full-screen interactive zoomable image dialog with responsive dismissal.
void showFullscreenImage(BuildContext context, String path, String title) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dismiss on tapping dark background outside the image
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          InteractiveViewer(
            child: Image.file(
              File(path),
              fit: BoxFit.contain,
            ),
          ),
          // Large, responsive close button
          Positioned(
            top: 44.h,
            right: 20.w,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  minimumSize: Size(44.r, 44.r),
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
