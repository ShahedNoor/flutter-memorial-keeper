import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../../../dua/domain/entities/dua.dart';
import '../../../dua/presentation/providers/dua_cubit.dart';

/// Serene Emerald Dua Card on Home Screen.
/// Rotates automatically daily from the synced Firebase [duas] collection,
/// adapting seamlessly to the user's active language (English / Bengali),
/// and offering a personal daily digital Tasbih recitation counter.
class DuaHeroCard extends StatefulWidget {
  const DuaHeroCard({super.key});

  @override
  State<DuaHeroCard> createState() => _DuaHeroCardState();
}

class _DuaHeroCardState extends State<DuaHeroCard> {
  int _todayRecitations = 0;

  static const String _fallbackArabic =
      'رَّبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا';
  static const String _fallbackTranslationEn =
      'My Lord, have mercy upon them as they brought me up when I was small.';
  static const String _fallbackTranslationBn =
      'হে আমার প্রতিপালক! তাদের উভয়ের প্রতি দয়া কর যেমন তারা শৈশবে আমাকে লালন-পালন করেছিলেন।';

  String get _todayStorageKey {
    final now = DateTime.now();
    return 'daily_dua_count_${now.year}_${now.month}_${now.day}';
  }

  @override
  void initState() {
    super.initState();
    _loadTodayCount();
  }

  void _loadTodayCount() {
    final saved = StorageService.instance.getInt(_todayStorageKey) ?? 0;
    setState(() {
      _todayRecitations = saved;
    });
  }

  Future<void> _incrementDua(String? duaId, String activeLanguage) async {
    HapticFeedback.lightImpact();
    setState(() {
      _todayRecitations++;
    });

    // Save to persistent storage so count survives app restarts today
    await StorageService.instance.setInt(_todayStorageKey, _todayRecitations);

    if (duaId != null && mounted) {
      context.read<DuaCubit>().markRecited(duaId);
    }

    final toastMessage = activeLanguage == 'bn'
        ? 'আল্লাহ আপনার দোয়া কবুল করুন এবং তাদের জান্নাত নসীব করুন।'
        : 'May Allah accept your Dua & grant them Jannah.';

    showGlobalToast(
      message: toastMessage,
      status: 'success',
    );
  }

  @override
  Widget build(BuildContext context) {
    final duaState = context.watch<DuaCubit>().state;
    final duas = duaState.duas;

    // Detect active language (en vs bn)
    final localeLang = context.locale.languageCode;
    final activeLanguage = duaState.activeLanguage.isNotEmpty
        ? duaState.activeLanguage
        : (localeLang == 'bn' ? 'bn' : 'en');

    // Deterministic daily rotation based on day of the year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final Dua? dailyDua =
        duas.isNotEmpty ? duas[dayOfYear % duas.length] : null;

    final String titleText =
        dailyDua != null && dailyDua.displayTitle(activeLanguage).isNotEmpty
            ? dailyDua.displayTitle(activeLanguage)
            : 'home.dua_title'.tr();

    final String arabicText = dailyDua != null && dailyDua.arabic.isNotEmpty
        ? dailyDua.arabic
        : _fallbackArabic;

    final String translationText = dailyDua != null
        ? dailyDua.displayTranslation(activeLanguage)
        : (activeLanguage == 'bn'
            ? _fallbackTranslationBn
            : _fallbackTranslationEn);

    final String? reference = (dailyDua?.reference.isNotEmpty ?? false)
        ? dailyDua!.reference
        : null;

    // Language-aware badge text
    final String badgeText = activeLanguage == 'bn'
        ? 'আজ $_todayRecitations বার পঠিত'
        : '$_todayRecitations Recited Today';

    // Button label
    final String buttonLabel = activeLanguage == 'bn'
        ? 'দোয়া পাঠ করুন'
        : 'Recite Dua';

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
          // Header row: Icon + Title + Duas count badge
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
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  titleText,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _todayRecitations > 0
                      ? const Color(0xFF10B981).withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _todayRecitations > 0
                        ? const Color(0xFF6EE7B7).withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badgeText,
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

          // Main Arabic Text
          Text(
            arabicText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 19.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),

          SizedBox(height: 8.h),

          // Translation (English or Bengali according to preferences)
          Text(
            '"$translationText"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFE2EBE7),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),

          if (reference != null) ...[
            SizedBox(height: 6.h),
            Text(
              reference,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: const Color(0xFF98DFBE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Action Button: Recite Dua
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
              onPressed: () => _incrementDua(dailyDua?.id, activeLanguage),
              icon: AppIcon(
                icon: HugeIcons.strokeRoundedFavourite,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                buttonLabel,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
