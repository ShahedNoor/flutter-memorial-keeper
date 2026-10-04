import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/memorial.dart';
import 'share_privacy_sheet.dart';

/// Dignified, high-resolution tribute card rendered for sharing on social apps (WhatsApp, Facebook, etc.).
class MemorialShareCard extends StatelessWidget {
  const MemorialShareCard({
    super.key,
    required this.memorial,
    this.privacyOptions = const SharePrivacyOptions(),
  });

  final Memorial memorial;
  final SharePrivacyOptions privacyOptions;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = memorial.profilePhotoPath != null &&
        File(memorial.profilePhotoPath!).existsSync();

    final birthStr = memorial.dateOfBirth != null
        ? _formatDate(memorial.dateOfBirth)
        : (memorial.birthYear != null ? '${memorial.birthYear}' : null);

    final passStr = memorial.dateOfDeath != null
        ? _formatDate(memorial.dateOfDeath)
        : (memorial.passingYear != null ? '${memorial.passingYear}' : null);

    final hasLifespan = birthStr != null || passStr != null;

    final String? displayLifespanText;
    switch (privacyOptions.datePrivacy) {
      case DateSharePrivacy.exactDates:
        displayLifespanText = hasLifespan
            ? '${birthStr ?? '?'}   —   ${passStr ?? '?'}'
            : null;
      case DateSharePrivacy.yearsOnly:
        final bYear = memorial.birthYear ?? memorial.dateOfBirth?.year;
        final dYear = memorial.passingYear ?? memorial.dateOfDeath?.year;
        displayLifespanText = (bYear != null || dYear != null)
            ? '${bYear ?? '?'}   —   ${dYear ?? '?'}'
            : null;
      case DateSharePrivacy.hideDates:
        displayLifespanText = null;
    }

    return Container(
      width: 380.w,
      padding: EdgeInsets.all(24.r),
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
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Decorative Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32.w,
                height: 1.h,
                color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  'IN LOVING MEMORY',
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
              Container(
                width: 32.w,
                height: 1.h,
                color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 2. Arabic Calligraphy
          Text(
            'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),

          // 3. Profile Photo with Frame
          Center(
            child: Container(
              width: 108.r,
              height: 108.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasPhoto
                    ? Image.file(
                        File(memorial.profilePhotoPath!),
                        fit: BoxFit.cover,
                        width: 108.r,
                        height: 108.r,
                      )
                    : ColoredBox(
                        color: const Color(0xFF163E30),
                        child: Center(
                          child: Icon(
                            memorial.gender == 'female'
                                ? Icons.face_3_rounded
                                : Icons.person_rounded,
                            size: 54.sp,
                            color: const Color(0xFF6EE7B7),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // 4. Name & Alternative Name
          Text(
            memorial.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          if (memorial.arabicName != null &&
              memorial.arabicName!.trim().isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              memorial.arabicName!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6EE7B7),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: 8.h),

          // 5. Relationship Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              memorial.displayRelationship,
              style: TextStyle(
                color: const Color(0xFFD1FAE5),
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // 6. Lifespan Banner
          if (displayLifespanText != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13.sp,
                    color: const Color(0xFFD4AF37),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    displayLifespanText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (privacyOptions.showAge && memorial.age != null) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '(${memorial.age} yrs)',
                      style: TextStyle(
                        color: const Color(0xFF6EE7B7),
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // 7. Resting Place
          if (privacyOptions.showRestingPlace &&
              memorial.cemeteryName != null &&
              memorial.cemeteryName!.trim().isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 15.sp,
                  color: const Color(0xFF6EE7B7),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    [
                      memorial.cemeteryName,
                      if (memorial.cemeteryArea != null &&
                          memorial.cemeteryArea!.trim().isNotEmpty)
                        memorial.cemeteryArea,
                      if (memorial.gravePlot != null &&
                          memorial.gravePlot!.trim().isNotEmpty)
                        memorial.gravePlot,
                    ].join(', '),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
          ],

          // 8. Heartfelt Dua
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2E22).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              memorial.notesOrDua != null &&
                      memorial.notesOrDua!.trim().isNotEmpty
                  ? '"${memorial.notesOrDua!.trim()}"'
                  : '"May Allah forgive their shortcomings, illuminate their grave, and grant them the highest gardens of Jannatul Firdaus. Ameen."',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFECFDF5),
                fontSize: 11.sp,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 16.h),

          // 9. Footer Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.spa_rounded,
                size: 13.sp,
                color: const Color(0xFFD4AF37),
              ),
              SizedBox(width: 6.w),
              Text(
                'Preserved on Memorial Keeper',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
