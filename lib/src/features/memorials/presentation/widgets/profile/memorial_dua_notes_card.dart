import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';

/// Card showing the Quranic remembrance verse, family memorial notes, and
/// an interactive prayer / Salawat counter with haptic feedback.
class MemorialDuaNotesCard extends StatefulWidget {
  const MemorialDuaNotesCard({
    super.key,
    required this.memorial,
  });

  final Memorial memorial;

  @override
  State<MemorialDuaNotesCard> createState() => _MemorialDuaNotesCardState();
}

class _MemorialDuaNotesCardState extends State<MemorialDuaNotesCard> {
  int _duaCount = 0;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;
    final memorial = widget.memorial;

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
                  Icons.menu_book_rounded,
                  color: cs.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Dua & Remembrance',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Quranic Verse Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.08),
                  cs.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '"Indeed to Allah we belong, and to Him we return."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          if (memorial.notesOrDua != null &&
              memorial.notesOrDua!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Family Memorial Notes:',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              memorial.notesOrDua!.trim(),
              style: TextStyle(
                fontSize: 13.sp,
                color: cs.onSurface,
                height: 1.45,
              ),
            ),
          ],
          SizedBox(height: 14.h),

          // Send Dua / Salawat interactive button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _duaCount++);
              showGlobalToast(
                message:
                    'May Allah accept your prayer for ${memorial.fullName}',
                status: 'success',
              );
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 18.sp,
                    color: cs.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Send silent prayer for their soul',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (_duaCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$_duaCount sent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16.sp,
                      color: cs.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
