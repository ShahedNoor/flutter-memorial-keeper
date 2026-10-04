import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Shows an interactive OpenStreetMap picker or read-only map sheet.
Future<GraveLocationResult?> showGraveMapPickerSheet(
  BuildContext context, {
  double? initialLat,
  double? initialLng,
  String? initialQuery,
  bool isReadOnly = false,
  String? title,
  String? subtitle,
  MapLayerType? initialLayer,
}) {
  return showModalBottomSheet<GraveLocationResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (context) => GraveMapPickerSheet(
      initialLat: initialLat,
      initialLng: initialLng,
      initialQuery: initialQuery,
      isReadOnly: isReadOnly,
      title: title,
      subtitle: subtitle,
      initialLayer: initialLayer,
    ),
  );
}

class GraveLocationResult {
  const GraveLocationResult({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.areaName,
    this.mapStyle = 'streets',
  });

  final double latitude;
  final double longitude;
  final String? placeName;
  final String? areaName;
  final String mapStyle; // 'satellite' | 'streets'
}

class GraveMapPickerSheet extends StatefulWidget {
  const GraveMapPickerSheet({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialQuery,
    this.isReadOnly = false,
    this.title,
    this.subtitle,
    this.initialLayer,
  });

  final double? initialLat;
  final double? initialLng;
  final String? initialQuery;
  final bool isReadOnly;
  final String? title;
  final String? subtitle;
  final MapLayerType? initialLayer;

  @override
  State<GraveMapPickerSheet> createState() => _GraveMapPickerSheetState();
}

enum MapLayerType {
  streets,
  satellite,
}

class _GraveMapPickerSheetState extends State<GraveMapPickerSheet> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  late LatLng _currentCenter;
  MapLayerType _currentLayer = MapLayerType.streets;
  bool _isLocating = false;
  bool _isSearching = false;
  List<PlaceSearchResult> _searchResults = [];
  Timer? _debounceTimer;

  // Default coordinate: Azimpur Graveyard, Dhaka or provided initial
  static const LatLng _defaultLocation = LatLng(23.7295, 90.3822);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _defaultLocation;
    if (widget.initialLayer != null) {
      _currentLayer = widget.initialLayer!;
    }

    if (!widget.isReadOnly &&
        widget.initialQuery != null &&
        widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!.trim();
      _performSearch(widget.initialQuery!.trim());
    } else if (!widget.isReadOnly &&
        widget.initialLat == null &&
        widget.initialLng == null) {
      // Auto-locate current GPS position on initial open
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _locateDevice(animate: true, silent: true);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await LocationService.instance.searchPlaces(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _performSearch(value);
    });
  }

  Future<void> _locateDevice({bool animate = true, bool silent = false}) async {
    setState(() => _isLocating = true);
    final pos = await LocationService.instance.getCurrentLocation();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (pos != null) {
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentCenter = target);
      if (animate) {
        _mapController.move(target, 17);
      }
      if (!silent) {
        showGlobalToast(
            message: 'Centered on your GPS location', status: 'success');
      }
    }
  }

  void _selectSearchResult(PlaceSearchResult result) {
    final target = LatLng(result.latitude, result.longitude);
    setState(() {
      _currentCenter = target;
      _searchResults = [];
      _searchController.text = result.name;
    });
    FocusScope.of(context).unfocus();
    _mapController.move(target, 17);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      height: 0.92.sh,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Map Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 16.5,
              maxZoom: 19,
              minZoom: 4,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && !widget.isReadOnly) {
                  setState(() {
                    _currentCenter = camera.center;
                  });
                }
              },
            ),
            children: [
              // 1. OpenStreetMap base layer (guarantees complete worldwide coverage without black tile voids)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shahednoor.memorialkeeper',
                maxZoom: 19,
              ),
              // 2. High-res Satellite layer on top when satellite view is toggled
              if (_currentLayer == MapLayerType.satellite)
                TileLayer(
                  key: const ValueKey('satellite_tile_layer'),
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.shahednoor.memorialkeeper',
                  maxZoom: 19,
                  maxNativeZoom: 18,
                ),
              // 3. Permanent Resting Place Pin Marker (for read-only view mode)
              if (widget.isReadOnly &&
                  widget.initialLat != null &&
                  widget.initialLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.initialLat!, widget.initialLng!),
                      width: 44.r,
                      height: 44.r,
                      alignment: Alignment.topCenter,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 42.sp,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Fixed Center Marker / Pin (Only when editing / picking a plot)
          if (!widget.isReadOnly)
            Center(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 34.r), // Pin tip alignment
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: cs.inverseSurface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Target Plot',
                        style: TextStyle(
                          color: cs.onInverseSurface,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 42.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Top Floating Search Bar & Header
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: widget.isReadOnly
                  ? _buildReadOnlyHeader(context, cs, tt)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Pill & Close Row
                        Row(
                          children: [
                            Container(
                              width: 44.h,
                              height: 44.h,
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22.h),
                            onTap: () => Navigator.of(context).pop(),
                            child: Center(
                              child: Icon(Icons.close,
                                  size: 20.sp, color: cs.onSurface),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 44.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  size: 20.sp, color: cs.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: _performSearch,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search cemetery, city, or area...',
                                    hintStyle: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                      fontSize: 13.sp,
                                    ),
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_isSearching)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              else if (_searchController.text.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() => _searchResults = []);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(4.r),
                                      child: Icon(Icons.clear,
                                          size: 18.sp,
                                          color: cs.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Suggestions List
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? cs.surfaceContainer
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.7),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(maxHeight: 280.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.r),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Suggestions Header
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
                                child: Row(
                                  children: [
                                    Text(
                                      'SUGGESTIONS',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: cs.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${_searchResults.length} found',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                        color: cs.onSurfaceVariant
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.8,
                                color: cs.outlineVariant.withValues(alpha: 0.4),
                              ),
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: _searchResults.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 62.w,
                                    endIndent: 16.w,
                                    color: cs.outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = _searchResults[index];
                                    final isCemetery = item.type == 'cemetery';

                                    return InkWell(
                                      onTap: () => _selectSearchResult(item),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 10.h,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36.r,
                                              height: 36.r,
                                              decoration: BoxDecoration(
                                                color: isCemetery
                                                    ? cs.primary
                                                        .withValues(alpha: 0.12)
                                                    : cs.onSurface.withValues(
                                                        alpha: 0.06),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                isCemetery
                                                    ? Icons
                                                        .account_balance_rounded
                                                    : Icons.location_on_rounded,
                                                color: isCemetery
                                                    ? cs.primary
                                                    : cs.onSurfaceVariant,
                                                size: 19.sp,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13.5.sp,
                                                            color: cs.onSurface,
                                                            letterSpacing: -0.2,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      if (isCemetery) ...[
                                                        SizedBox(width: 6.w),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            horizontal: 6.w,
                                                            vertical: 2.h,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: cs.primary
                                                                .withValues(
                                                                    alpha:
                                                                        0.12),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.r),
                                                          ),
                                                          child: Text(
                                                            'Cemetery',
                                                            style: TextStyle(
                                                              fontSize: 9.5.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: cs.primary,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    item.displayName,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      height: 1.25,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.all(5.r),
                                              decoration: BoxDecoration(
                                                color: cs.onSurface
                                                    .withValues(alpha: 0.04),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.north_west_rounded,
                                                size: 13.sp,
                                                color: cs.onSurfaceVariant
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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

          // 4. Bottom Controls & Confirmation (FABs + Card aligned above System Navigation Bar)
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: (math.max(
                      MediaQuery.of(context).padding.bottom,
                      MediaQuery.of(context).viewPadding.bottom,
                    ) >
                    0
                ? math.max(
                    MediaQuery.of(context).padding.bottom,
                    MediaQuery.of(context).viewPadding.bottom,
                  )
                : 12.h) +
                8.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Layer Switcher Button
                FloatingActionButton.small(
                  heroTag: 'map_layer_toggle_fab',
                  backgroundColor: cs.surface,
                  foregroundColor: _currentLayer == MapLayerType.satellite
                      ? Colors.amber[800]
                      : cs.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: BorderSide(
                      color: _currentLayer == MapLayerType.satellite
                          ? Colors.amber.withValues(alpha: 0.5)
                          : cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  tooltip: _currentLayer == MapLayerType.streets
                      ? 'Switch to Satellite View'
                      : 'Switch to Streets View',
                  onPressed: () {
                    setState(() {
                      _currentLayer = _currentLayer == MapLayerType.streets
                          ? MapLayerType.satellite
                          : MapLayerType.streets;
                    });
                  },
                  child: Icon(
                    _currentLayer == MapLayerType.streets
                        ? Icons.satellite_alt_rounded
                        : Icons.map_rounded,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 10.h),

                // Locate Me / Center on Grave Button
                FloatingActionButton.small(
                  heroTag: 'map_locate_me_fab',
                  backgroundColor: cs.surface,
                  foregroundColor: cs.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  tooltip: widget.isReadOnly
                      ? 'Center on Resting Place'
                      : 'My GPS Location',
                  onPressed: widget.isReadOnly
                      ? () {
                          if (widget.initialLat != null &&
                              widget.initialLng != null) {
                            _mapController.move(
                              LatLng(widget.initialLat!, widget.initialLng!),
                              16.5,
                            );
                          }
                        }
                      : (_isLocating ? null : () => _locateDevice(animate: true)),
                  child: widget.isReadOnly
                      ? Icon(Icons.gps_fixed_rounded, size: 20.sp)
                      : (_isLocating
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            )
                          : Icon(Icons.my_location, size: 20.sp)),
                ),
                SizedBox(height: 12.h),

                // Bottom Card: Read-Only Info vs Picker Confirmation
                if (widget.isReadOnly)
                  _buildReadOnlyBottomCard(context, cs, tt)
                else
                  _buildPickerBottomCard(context, cs, tt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clean, compact top header for read-only view mode.
  Widget _buildReadOnlyHeader(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Row(
      children: [
        Container(
          width: 44.h,
          height: 44.h,
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22.h),
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Icon(Icons.close, size: 20.sp, color: cs.onSurface),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 20.sp,
                  color: Colors.redAccent,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title != null && widget.title!.trim().isNotEmpty
                            ? '${widget.title}\'s Resting Place'
                            : 'Resting Place Map',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null &&
                          widget.subtitle!.trim().isNotEmpty) ...[
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Informational bottom card for read-only mode with turn-by-turn navigation button.
  Widget _buildReadOnlyBottomCard(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final lat = widget.initialLat;
    final lng = widget.initialLng;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? cs.surfaceContainer
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Icons.location_on_rounded,
                  size: 20.sp,
                  color: cs.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subtitle != null && widget.subtitle!.trim().isNotEmpty
                          ? widget.subtitle!
                          : (widget.title != null
                              ? '${widget.title}\'s Resting Place'
                              : 'Resting Place Location'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lat != null && lng != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '${lat.toStringAsFixed(6)}°,  ${lng.toStringAsFixed(6)}°',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (lat != null && lng != null) ...[
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 2,
              ),
              onPressed: () {
                LocationService.instance.openInMaps(
                  lat,
                  lng,
                  label: widget.title != null
                      ? '${widget.title} Resting Place'
                      : null,
                );
              },
              icon: Icon(Icons.navigation_rounded, size: 18.sp),
              label: Text(
                'Open Turn-by-turn Navigation',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Interactive bottom confirmation card for coordinate picker mode.
  Widget _buildPickerBottomCard(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? cs.surfaceContainer
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.location_searching,
                    size: 18.sp, color: cs.primary),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Coordinates',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${_currentCenter.latitude.toStringAsFixed(6)}°,  ${_currentCenter.longitude.toStringAsFixed(6)}°',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.of(context).pop(
                GraveLocationResult(
                  latitude: _currentCenter.latitude,
                  longitude: _currentCenter.longitude,
                  placeName: _searchController.text.trim().isNotEmpty
                      ? _searchController.text.trim()
                      : null,
                  mapStyle: _currentLayer == MapLayerType.satellite
                      ? 'satellite'
                      : 'streets',
                ),
              );
            },
            child: Text(
              'Confirm Resting Place Location',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
