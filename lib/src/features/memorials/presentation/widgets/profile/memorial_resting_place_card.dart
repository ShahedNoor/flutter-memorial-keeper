import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';
import '../grave_map_picker_sheet.dart';

/// Card showing cemetery resting place details, satellite map preview,
/// and directions options.
class MemorialRestingPlaceCard extends StatelessWidget {
  const MemorialRestingPlaceCard({
    super.key,
    required this.memorial,
  });

  final Memorial memorial;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    final hasCoordinates = memorial.latitude != null &&
        memorial.longitude != null &&
        memorial.latitude != 0.0 &&
        memorial.longitude != 0.0;

    final hasCemetery = memorial.cemeteryName != null &&
        memorial.cemeteryName!.trim().isNotEmpty;

    return Container(
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
                  Icons.nature_people_rounded,
                  color: cs.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Resting Place Details',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (hasCoordinates)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, size: 11.sp, color: cs.primary),
                      SizedBox(width: 4.w),
                      Text(
                        'GPS Verified',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // Cemetery info
          Text(
            hasCemetery
                ? memorial.cemeteryName!
                : 'Resting place location not specified',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          if (memorial.cemeteryArea != null &&
              memorial.cemeteryArea!.trim().isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              [
                memorial.cemeteryArea,
                if (memorial.gravePlot != null &&
                    memorial.gravePlot!.trim().isNotEmpty)
                  memorial.gravePlot,
              ].join(' • '),
              style: TextStyle(
                fontSize: 12.5.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 12.h),

          // Mini Satellite Map Preview
          if (hasCoordinates) ...[
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey(
                      'resting_place_preview_${memorial.id}_${memorial.latitude}_${memorial.longitude}_${memorial.mapStyle}',
                    ),
                    options: MapOptions(
                      initialCenter:
                          LatLng(memorial.latitude!, memorial.longitude!),
                      initialZoom: 16.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // Static preview
                      ),
                    ),
                    children: [
                      // Base OpenStreetMap layer (always loaded, used directly for normal/street view)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.shahednoor.memorialkeeper',
                        maxZoom: 19,
                      ),
                      // Satellite imagery layer on top (only when satellite view was selected)
                      if (memorial.mapStyle == 'satellite')
                        TileLayer(
                          key: const ValueKey('preview_satellite_tile_layer'),
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName:
                              'com.shahednoor.memorialkeeper',
                          maxZoom: 19,
                          maxNativeZoom: 18,
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              memorial.latitude!,
                              memorial.longitude!,
                            ),
                            width: 36.r,
                            height: 36.r,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.redAccent,
                              size: 34.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // View style badge (Satellite vs Street Map)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            memorial.mapStyle == 'satellite'
                                ? Icons.satellite_alt_rounded
                                : Icons.map_rounded,
                            size: 11.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            memorial.mapStyle == 'satellite'
                                ? 'Satellite'
                                : 'Street Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap overlay to open full interactive map picker
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showGraveMapPickerSheet(
                          context,
                          initialLat: memorial.latitude,
                          initialLng: memorial.longitude,
                          initialQuery: memorial.cemeteryName,
                          isReadOnly: true,
                          title: memorial.fullName,
                          subtitle: memorial.cemeteryName,
                          initialLayer: memorial.mapStyle == 'satellite'
                              ? MapLayerType.satellite
                              : MapLayerType.streets,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fullscreen_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Expand Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.primary,
                      side: BorderSide(
                        color: cs.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () {
                      LocationService.instance.openInMaps(
                        memorial.latitude!,
                        memorial.longitude!,
                        label: '${memorial.fullName} Resting Place',
                      );
                    },
                    icon: Icon(Icons.navigation_outlined, size: 16.sp),
                    label: Text(
                      'Turn-by-turn Navigation',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
