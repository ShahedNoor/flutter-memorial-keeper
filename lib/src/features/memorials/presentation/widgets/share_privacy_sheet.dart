import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../imports/core_imports.dart';
import '../../domain/entities/memorial.dart';

/// Privacy options for rendering the shareable tribute card.
enum DateSharePrivacy {
  yearsOnly,
  exactDates,
  hideDates,
}

class SharePrivacyOptions {
  const SharePrivacyOptions({
    this.datePrivacy = DateSharePrivacy.yearsOnly,
    this.showAge = true,
    this.showRestingPlace = true,
  });

  final DateSharePrivacy datePrivacy;
  final bool showAge;
  final bool showRestingPlace;

  SharePrivacyOptions copyWith({
    DateSharePrivacy? datePrivacy,
    bool? showAge,
    bool? showRestingPlace,
  }) {
    return SharePrivacyOptions(
      datePrivacy: datePrivacy ?? this.datePrivacy,
      showAge: showAge ?? this.showAge,
      showRestingPlace: showRestingPlace ?? this.showRestingPlace,
    );
  }
}

/// Compact, elegant bottom sheet allowing users to customize privacy
/// on the shared tribute card with a live card format preview.
class SharePrivacySheet extends StatefulWidget {
  const SharePrivacySheet({
    super.key,
    required this.memorial,
    required this.onShareConfirmed,
  });

  final Memorial memorial;
  final Future<void> Function(SharePrivacyOptions options) onShareConfirmed;

  @override
  State<SharePrivacySheet> createState() => _SharePrivacySheetState();
}

class _SharePrivacySheetState extends State<SharePrivacySheet> {
  DateSharePrivacy _datePrivacy = DateSharePrivacy.yearsOnly;
  bool _showAge = true;
  bool _showRestingPlace = true;
  bool _isGenerating = false;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String? _getPreviewDateString() {
    final memorial = widget.memorial;
    switch (_datePrivacy) {
      case DateSharePrivacy.exactDates:
        final b = memorial.dateOfBirth != null
            ? _formatDate(memorial.dateOfBirth)
            : (memorial.birthYear != null ? '${memorial.birthYear}' : '?');
        final d = memorial.dateOfDeath != null
            ? _formatDate(memorial.dateOfDeath)
            : (memorial.passingYear != null ? '${memorial.passingYear}' : '?');
        return '$b   —   $d';
      case DateSharePrivacy.yearsOnly:
        final bYear = memorial.birthYear ?? memorial.dateOfBirth?.year;
        final dYear = memorial.passingYear ?? memorial.dateOfDeath?.year;
        if (bYear == null && dYear == null) return null;
        return '${bYear ?? '?'}   —   ${dYear ?? '?'}';
      case DateSharePrivacy.hideDates:
        return null;
    }
  }

  String _getDatePrivacySubtitle() {
    switch (_datePrivacy) {
      case DateSharePrivacy.yearsOnly:
        return 'Shows years only (e.g. 1935 — 2016) to protect exact day & month.';
      case DateSharePrivacy.exactDates:
        return 'Shows full calendar dates of birth and passing.';
      case DateSharePrivacy.hideDates:
        return 'Keeps all lifespan dates completely private.';
    }
  }

  Future<void> _handleConfirm() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    try {
      final options = SharePrivacyOptions(
        datePrivacy: _datePrivacy,
        showAge: _showAge,
        showRestingPlace: _showRestingPlace,
      );
      await widget.onShareConfirmed(options);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;
    final memorial = widget.memorial;

    final hasCemetery = memorial.cemeteryName != null &&
        memorial.cemeteryName!.trim().isNotEmpty;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomNavPadding = MediaQuery.of(context).padding.bottom;
    final bottomViewPadding = MediaQuery.of(context).viewPadding.bottom;
    final effectiveBottomNav = math.max(bottomNavPadding, bottomViewPadding);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        // Elevated safely above Android 3-button system navigation bar and gesture pill
        16.h + bottomInset + math.max(effectiveBottomNav, 16.h),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Header Row: Title & Close Button
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    color: cs.primary,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share Privacy Settings',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Control what details appear on the card',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: cs.onSurfaceVariant,
                  iconSize: 20.sp,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // 1. Date Format Segmented Control
            Text(
              'Lifespan Dates Format',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 8.h),

            Container(
              height: 42.h,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _buildSegmentItem(
                    label: 'Years Only',
                    value: DateSharePrivacy.yearsOnly,
                    cs: cs,
                  ),
                  _buildSegmentItem(
                    label: 'Full Dates',
                    value: DateSharePrivacy.exactDates,
                    cs: cs,
                  ),
                  _buildSegmentItem(
                    label: 'Hide Dates',
                    value: DateSharePrivacy.hideDates,
                    cs: cs,
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),

            // Dynamic 1-line helper text
            Text(
              _getDatePrivacySubtitle(),
              style: TextStyle(
                fontSize: 11.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),

            // 2. Realistic Live Tribute Card Preview
            _buildLivePreviewCard(memorial),
            SizedBox(height: 12.h),

            // 3. Grouped Detail Toggles Card
            DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  if (memorial.age != null &&
                      _datePrivacy != DateSharePrivacy.hideDates) ...[
                    _buildSwitchItem(
                      icon: Icons.cake_outlined,
                      title: 'Include Age',
                      subtitle: '${memorial.age} years old',
                      value: _showAge,
                      onChanged: (val) => setState(() => _showAge = val),
                      cs: cs,
                    ),
                    if (hasCemetery)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 48.w,
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                      ),
                  ],
                  if (hasCemetery)
                    _buildSwitchItem(
                      icon: Icons.location_on_outlined,
                      title: 'Include Cemetery',
                      subtitle: memorial.cemeteryName!,
                      value: _showRestingPlace,
                      onChanged: (val) =>
                          setState(() => _showRestingPlace = val),
                      cs: cs,
                    ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // 4. Primary Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _isGenerating ? null : _handleConfirm,
                icon: _isGenerating
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.share_rounded, size: 18.sp),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Share Tribute Card',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildLivePreviewCard(Memorial memorial) {
    final dateText = _getPreviewDateString();
    final hasCemetery = memorial.cemeteryName != null &&
        memorial.cemeteryName!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF062319),
            Color(0xFF0F3B2C),
            Color(0xFF071E16),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_red_eye_rounded,
                      size: 11.sp,
                      color: const Color(0xFFD4AF37),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'CARD FORMAT PREVIEW',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Memorial Name
          Text(
            memorial.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),

          // Live Dates Badge
          if (_datePrivacy != DateSharePrivacy.hideDates && dateText != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11.sp,
                    color: const Color(0xFFD4AF37),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_showAge && memorial.age != null) ...[
                    SizedBox(width: 6.w),
                    Text(
                      '(${memorial.age} yrs)',
                      style: TextStyle(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Text(
              'Lifespan dates hidden for privacy',
              style: TextStyle(
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),

          // Resting Place if enabled
          if (_showRestingPlace && hasCemetery) ...[
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 11.5.sp,
                  color: const Color(0xFF6EE7B7),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    memorial.cemeteryName!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required String label,
    required DateSharePrivacy value,
    required ColorScheme cs,
  }) {
    final isSelected = _datePrivacy == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _datePrivacy = value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme cs,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: cs.onSurfaceVariant),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return cs.onSurfaceVariant;
              }),
              trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return cs.primary;
                }
                return cs.surfaceContainerHighest;
              }),
              trackOutlineColor:
                  WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.transparent;
                }
                return cs.outline.withValues(alpha: 0.45);
              }),
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Icon(
                    Icons.check_rounded,
                    size: 13.sp,
                    color: cs.primary,
                  );
                }
                return Icon(
                  Icons.close_rounded,
                  size: 11.sp,
                  color: cs.surfaceContainerHighest,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to show the share privacy options sheet.
Future<void> showSharePrivacySheet({
  required BuildContext context,
  required Memorial memorial,
  required Future<void> Function(SharePrivacyOptions options) onShareConfirmed,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SharePrivacySheet(
      memorial: memorial,
      onShareConfirmed: onShareConfirmed,
    ),
  );
}
