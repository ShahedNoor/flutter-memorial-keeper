import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../imports/core_imports.dart';

/// Search result model for OpenStreetMap / Nominatim place queries.
class PlaceSearchResult {
  const PlaceSearchResult({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.type,
  });

  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String? type;

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResult(
      name: ((json['name'] as String?)?.isNotEmpty ?? false)
          ? json['name'] as String
          : (json['display_name'] as String? ?? 'Location').split(',').first,
      displayName: json['display_name'] as String? ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] as String?,
    );
  }
}

/// Service handling GPS hardware positioning and OpenStreetMap Nominatim search.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent': 'MemorialKeeper/1.0 (com.shahednoor.memorialkeeper)',
      },
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  static const String _keyDenialCount = 'location_permission_denial_count';
  static const String _keyPermissionStatus = 'location_permission_status';

  /// Requests current device GPS location using the phone sensor.
  /// Tracks denial attempts in local storage and guides the user to Settings
  /// if permission is permanently disabled.
  Future<Position?> getCurrentLocation() async {
    try {
      // 1. Verify device GPS location services (master switch)
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _promptEnableGps();
        return null;
      }

      // 2. Check current native permission
      LocationPermission permission = await Geolocator.checkPermission();
      final denialCount = StorageService.instance.getInt(_keyDenialCount) ?? 0;

      // 3. If already granted, sync local storage and fetch position
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await StorageService.instance.setInt(_keyDenialCount, 0);
        await StorageService.instance.setString(_keyPermissionStatus, 'granted');
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      }

      // 4. If permanently denied by OS or denied >= 2 times in local storage
      if (permission == LocationPermission.deniedForever || denialCount >= 2) {
        await StorageService.instance.setString(
          _keyPermissionStatus,
          'permanentlyDenied',
        );
        await _promptOpenAppSettings();
        return null;
      }

      // 5. First-time or normal denial - request native permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // User granted on prompt
          await StorageService.instance.setInt(_keyDenialCount, 0);
          await StorageService.instance.setString(_keyPermissionStatus, 'granted');
          return await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 12),
            ),
          );
        }

        if (permission == LocationPermission.deniedForever) {
          // Native OS marked as permanently denied
          await StorageService.instance.setInt(_keyDenialCount, 2);
          await StorageService.instance.setString(
            _keyPermissionStatus,
            'permanentlyDenied',
          );
          await _promptOpenAppSettings();
          return null;
        }

        if (permission == LocationPermission.denied) {
          final newCount = denialCount + 1;
          await StorageService.instance.setInt(_keyDenialCount, newCount);
          await StorageService.instance.setString(_keyPermissionStatus, 'denied');

          if (newCount >= 2) {
            // Reached 2 denials - now permanently disabled
            await StorageService.instance.setString(
              _keyPermissionStatus,
              'permanentlyDenied',
            );
            await _promptOpenAppSettings();
          } else {
            showGlobalToast(
              message: 'Location permission was denied. Tap again to grant.',
              status: 'warning',
            );
          }
          return null;
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to get device position', error: e, category: LogCategory.app);
      return null;
    }
  }

  /// Prompts the user to navigate to App Settings to enable location permission.
  Future<void> _promptOpenAppSettings() async {
    final ctx = rootContext;
    if (ctx == null) {
      await Geolocator.openAppSettings();
      return;
    }

    final cs = ctx.colors;
    final tt = ctx.textTheme;

    await showAppDialog<void>(
      child: AlertDialog(
        backgroundColor: ctx.theme.brightness == Brightness.dark
            ? cs.surfaceContainer
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        icon: Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_off_rounded,
            color: cs.primary,
            size: 26.sp,
          ),
        ),
        title: Text(
          'Location Permission Required',
          textAlign: TextAlign.center,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Location permission is permanently disabled. In the settings screen:',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Tap "Permissions"',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Select "Location" → Allow',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(
              'Not Now',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx, rootNavigator: true).pop();
              await Geolocator.openAppSettings();
            },
            icon: Icon(Icons.settings_outlined, size: 17.sp),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Prompts the user to enable the device master GPS Location toggle.
  Future<void> _promptEnableGps() async {
    final ctx = rootContext;
    if (ctx == null) {
      showGlobalToast(
        message: 'Please enable GPS location service on your device.',
        status: 'warning',
      );
      return;
    }

    final cs = ctx.colors;
    final tt = ctx.textTheme;

    await showAppDialog<void>(
      child: AlertDialog(
        backgroundColor: ctx.theme.brightness == Brightness.dark
            ? cs.surfaceContainer
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        icon: Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.gps_fixed_rounded,
            color: cs.primary,
            size: 26.sp,
          ),
        ),
        title: Text(
          'Enable Device GPS',
          textAlign: TextAlign.center,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'GPS location service is turned off on your device. Please turn it on to find your resting place location.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx, rootNavigator: true).pop();
              await Geolocator.openLocationSettings();
            },
            icon: Icon(Icons.location_on_outlined, size: 17.sp),
            label: const Text('Turn On GPS'),
          ),
        ],
      ),
    );
  }

  /// Opens the device App Settings screen for this application.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Opens the device GPS Location Service master settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Resets the local permission denial history.
  Future<void> resetPermissionHistory() async {
    await StorageService.instance.setInt(_keyDenialCount, 0);
    await StorageService.instance.setString(_keyPermissionStatus, 'unknown');
  }

  /// Returns the current permission status stored in local preferences.
  String getStoredPermissionStatus() {
    return StorageService.instance.getString(_keyPermissionStatus) ?? 'unknown';
  }

  /// Free geocoding search using OpenStreetMap Nominatim.
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query.trim(),
          'format': 'json',
          'limit': '5',
          'addressdetails': '1',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((item) => PlaceSearchResult.fromJson(item as Map<String, dynamic>))
            .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
            .toList();
      }
    } catch (e) {
      AppLogger.error('Place search failed for query: $query', error: e, category: LogCategory.network);
    }
    return [];
  }

  /// Reverse geocode coordinates to get human-readable location address.
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final displayName = response.data!['display_name'] as String?;
        return displayName;
      }
    } catch (e) {
      AppLogger.error('Reverse geocode failed', error: e, category: LogCategory.network);
    }
    return null;
  }

  /// Launch external navigation apps (Google Maps / Apple Maps / Waze) for turn-by-turn directions.
  Future<void> openInMaps(double lat, double lng, {String? label}) async {
    // 1. Android native geo: URI (natively launches Google Maps, Waze, or the user's default navigation app)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    // 2. Google Maps Universal Navigation URL (initiates directions directly to the destination)
    final googleMapsDirUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    // 3. Apple Maps directions URL for iOS
    final appleMapsUri = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
    );

    // 4. Fallback search URL
    final googleMapsSearchUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    final urisToTry = [
      geoUri,
      googleMapsDirUri,
      appleMapsUri,
      googleMapsSearchUri,
    ];

    for (final uri in urisToTry) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {
        // Continue to the next fallback scheme
      }
    }

    // Last resort: try platform default (in-app browser or web view)
    try {
      final launched = await launchUrl(
        googleMapsDirUri,
        mode: LaunchMode.platformDefault,
      );
      if (launched) return;
    } catch (e) {
      AppLogger.error('Failed to open maps', error: e, category: LogCategory.app);
    }

    showGlobalToast(
      message: 'Could not open map application.',
      status: 'error',
    );
  }
}
