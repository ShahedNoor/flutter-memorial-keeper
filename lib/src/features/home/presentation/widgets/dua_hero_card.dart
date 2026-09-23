import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

/// Serene Emerald Dua Card for daily Quranic prayers for departed parents & ancestors.
class DuaHeroCard extends StatefulWidget {
  const DuaHeroCard({
    super.key,
    this.initialDuaCount = 7,
  });

  final int initialDuaCount;

  @override
  State<DuaHeroCard> createState() => _DuaHeroCardState();
}

class _DuaHeroCardState extends State<DuaHeroCard> {
  late int _duaCount;

  @override
  void initState() {
    super.initState();
    _duaCount = widget.initialDuaCount;
  }

  void _incrementDua() {
    HapticFeedback.lightImpact();
    setState(() {
      _duaCount++;
    });
    showGlobalToast(
      message: 'May Allah accept your Dua & grant them Jannah.',
      status: 'success',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A4D3B), // Deep Islamic Green
            Color(0xFF0F6E54), // Forest Emerald
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C46).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  icon: HugeIcons.strokeRoundedMosque01,
                  size: 16.sp,
                  color: const Color(0xFF6EE7B7),
                ),
              ),
              Expanded(
                child: Text(
                  'home.dua_title'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFD1FAE5),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$_duaCount Duas Today',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'home.dua_arabic'.tr(),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'home.dua_translation'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFE2EBE7),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 40.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: _incrementDua,
              icon: AppIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                'home.recite_dua'.tr(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
