import 'dart:io';
import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Form section managing Cemetery / Resting place details and tombstone photo.
class RestingPlaceSection extends StatelessWidget {
  const RestingPlaceSection({
    super.key,
    required this.cemeteryNameController,
    required this.cemeteryAreaController,
    required this.gravePlotController,
    required this.gravePhotoPath,
    required this.onTapGravePhoto,
    required this.inputDecoration,
  });

  final TextEditingController cemeteryNameController;
  final TextEditingController cemeteryAreaController;
  final TextEditingController gravePlotController;
  final String? gravePhotoPath;
  final VoidCallback onTapGravePhoto;
  final InputDecoration Function({required String hint, dynamic prefixIcon})
      inputDecoration;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 20.sp,
                color: cs.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Resting Place Details',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          TextFormField(
            controller: cemeteryNameController,
            decoration: inputDecoration(
              hint: 'Cemetery Name (e.g. Azimpur Graveyard)',
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cemeteryAreaController,
                  decoration: inputDecoration(
                    hint: 'Area / City (e.g. Dhaka)',
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextFormField(
                  controller: gravePlotController,
                  decoration: inputDecoration(
                    hint: 'Plot / Line (e.g. Plot 14)',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: onTapGravePhoto,
            child: Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
                image: gravePhotoPath != null
                    ? DecorationImage(
                        image: FileImage(File(gravePhotoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: gravePhotoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedCamera01,
                          size: 24.sp,
                          color: cs.primary,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Add Resting Place / Tombstone Photo',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.all(8.r),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Tap to change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
