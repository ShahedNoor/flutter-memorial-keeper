import 'dart:io';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Form section managing Cemetery / Resting place details, GPS coordinates, and tombstone photo.
class RestingPlaceSection extends StatelessWidget {
  const RestingPlaceSection({
    super.key,
    required this.cemeteryNameController,
    required this.cemeteryAreaController,
    required this.gravePlotController,
    required this.gravePhotoPath,
    required this.onTapGravePhoto,
    required this.inputDecoration,
    this.latitude,
    this.longitude,
    required this.onTapPickOnMap,
    required this.onTapLocateMe,
    required this.onClearLocation,
  });

  final TextEditingController cemeteryNameController;
  final TextEditingController cemeteryAreaController;
  final TextEditingController gravePlotController;
  final String? gravePhotoPath;
  final VoidCallback onTapGravePhoto;
  final InputDecoration Function({required String hint, dynamic prefixIcon})
      inputDecoration;

  final double? latitude;
  final double? longitude;
  final VoidCallback onTapPickOnMap;
  final VoidCallback onTapLocateMe;
  final VoidCallback onClearLocation;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;
    final hasCoordinates = latitude != null && longitude != null;

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
          SizedBox(height: 12.h),

          // Exact GPS Coordinate Box
          if (hasCoordinates)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? cs.surfaceContainer
                    : cs.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: onTapPickOnMap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
                    child: Row(
                      children: [
                        // Left Pulsing Pin / Radar Icon
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.pin_drop_rounded,
                              size: 21.sp,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 11.w),

                        // Coordinates & Status Label
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'GPS PINNED',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      color: cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${latitude!.toStringAsFixed(6)}°,  ${longitude!.toStringAsFixed(6)}°',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Tap to preview or adjust plot',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons: Edit pill & Clear button
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_location_alt_rounded,
                                    size: 13.sp,
                                    color: cs.primary,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Adjust',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              borderRadius: BorderRadius.circular(14.r),
                              onTap: onClearLocation,
                              child: Padding(
                                padding: EdgeInsets.all(5.r),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 17.sp,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                    ),
                    onPressed: onTapPickOnMap,
                    icon: Icon(Icons.map_outlined, size: 18.sp, color: cs.primary),
                    label: Text(
                      'Pick on Map',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    onPressed: onTapLocateMe,
                    icon: Icon(Icons.my_location, size: 18.sp, color: cs.onSurfaceVariant),
                    label: Text(
                      'Use GPS',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
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
