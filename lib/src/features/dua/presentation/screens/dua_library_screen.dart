import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

class _DuaItem {
  final String title;
  final String category;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  const _DuaItem({
    required this.title,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });
}

/// Authentic Islamic Duas & Remembrance for departed souls.
class DuaLibraryScreen extends StatelessWidget {
  const DuaLibraryScreen({super.key});

  final List<_DuaItem> _duas = const [
    _DuaItem(
      title: 'Dua for Parents (পিতামাতার জন্য দোয়া)',
      category: 'Parents',
      arabic: 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration: 'Rabbi-ghfir lee wa li-waalidayya warhamhuma kama rabbayani sagheera',
      translation: 'My Lord, forgive me and my parents, and have mercy upon them as they brought me up when I was small.',
      reference: 'Surah Al-Isra (17:24)',
    ),
    _DuaItem(
      title: 'Visiting the Cemetery (কবর জিয়ারতের দোয়া)',
      category: 'Ziyarat',
      arabic: 'السَّلَامُ عَلَيْكُمْ دَارَ قَوْمٍ مُؤْمِنِينَ وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ',
      transliteration: 'Assalaamu ‘alaykum daara qawmim-mu’mineen, wa innaa in shaa’ Allaahu bikum laahiqoon',
      translation: 'Peace be upon you, O inhabitants of this dwelling of believers. Indeed, we shall, if Allah wills, join you.',
      reference: 'Sahih Muslim 249',
    ),
    _DuaItem(
      title: 'Comprehensive Forgiveness for All Deceased',
      category: 'General',
      arabic: 'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا',
      transliteration: 'Allaahummagh-fir li-hayyinaa wa mayyitinaa wa shaahidinaa wa ghaa’ibinaa wa sagheerinaa wa kabeerinaa',
      translation: 'O Allah, forgive our living and our dead, those present and those absent, our young and our old.',
      reference: 'Sunan Abi Dawud 3201',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Duas & Remembrance (দোয়া ও জিকির)',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        itemCount: _duas.length,
        itemBuilder: (context, index) {
          final dua = _duas[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dua.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        dua.category,
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    dua.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  dua.translation,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dua.reference,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: AppIcon(
                        icon: HugeIcons.strokeRoundedFavourite,
                        color: cs.primary,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showGlobalToast(
                          message: 'Dua recited & prayer sent.',
                          status: 'success',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
