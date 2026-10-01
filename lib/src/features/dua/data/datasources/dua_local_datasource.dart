import 'dart:convert';
import 'package:memorial_keeper/src/services/storage_service.dart';
import '../models/dua_model.dart';

abstract class DuaLocalDataSource {
  Future<List<DuaModel>> getCachedDuas();
  Future<void> cacheDuas(List<DuaModel> duas);
  List<DuaModel> getFallbackDuas();
}

class DuaLocalDataSourceImpl implements DuaLocalDataSource {
  static const String _duasCacheKey = 'cached_duas_v1';

  @override
  Future<List<DuaModel>> getCachedDuas() async {
    final cachedJson = StorageService.instance.getString(_duasCacheKey);
    if (cachedJson != null && cachedJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedJson) as List<dynamic>;
        final list = decoded
            .map((e) => DuaModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          list.sort((a, b) => a.order.compareTo(b.order));
          return list;
        }
      } catch (_) {
        // Fallback gracefully on parsing failure
      }
    }
    return getFallbackDuas();
  }

  @override
  Future<void> cacheDuas(List<DuaModel> duas) async {
    final encoded = jsonEncode(duas.map((d) => d.toJson()).toList());
    await StorageService.instance.setString(_duasCacheKey, encoded);
  }

  @override
  List<DuaModel> getFallbackDuas() {
    return const [
      DuaModel(
        id: 'dua_parents',
        titleEn: 'Dua for Parents',
        titleBn: 'পিতামাতার জন্য দোয়া',
        category: 'Parents',
        arabic:
            'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        transliteration:
            'Rabbi-ghfir lee wa li-waalidayya warhamhuma kama rabbayani sagheera',
        translationEn:
            'My Lord, forgive me and my parents, and have mercy upon them as they brought me up when I was small.',
        translationBn:
            'হে আমার প্রতিপালক! তাদের প্রতি দয়া করুন যেভাবে তারা শৈশবে আমাকে লালন-পালন করেছিলেন।',
        reference: 'Surah Al-Isra (17:24)',
        order: 1,
      ),
      DuaModel(
        id: 'dua_ziyarat',
        titleEn: 'Visiting the Cemetery',
        titleBn: 'কবর জিয়ারতের দোয়া',
        category: 'Ziyarat',
        arabic:
            'السَّلَامُ عَلَيْكُمْ دَارَ قَوْمٍ مُؤْمِنِينَ وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ',
        transliteration:
            'Assalaamu ‘alaykum daara qawmim-mu’mineen, wa innaa in shaa’ Allaahu bikum laahiqoon',
        translationEn:
            'Peace be upon you, O inhabitants of this dwelling of believers. Indeed, we shall, if Allah wills, join you.',
        translationBn:
            'হে মুমিনদের কবরস্থানের অধিবাসীরা! আপনাদের ওপর শান্তি বর্ষিত হোক। নিশ্চয়ই আমরাও আল্লাহর ইচ্ছায় আপনাদের সাথে মিলিত হব।',
        reference: 'Sahih Muslim 249',
        order: 2,
      ),
      DuaModel(
        id: 'dua_general',
        titleEn: 'Comprehensive Forgiveness for All Deceased',
        titleBn: 'সকল মৃতের ক্ষমার দোয়া',
        category: 'General',
        arabic:
            'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا',
        transliteration:
            'Allaahummagh-fir li-hayyinaa wa mayyitinaa wa shaahidinaa wa ghaa’ibinaa wa sagheerinaa wa kabeerinaa',
        translationEn:
            'O Allah, forgive our living and our dead, those present and those absent, our young and our old.',
        translationBn:
            'হে আল্লাহ! আমাদের জীবিত ও মৃত, উপস্থিত ও অনুপস্থিত, এবং আমাদের ছোট ও বড় সবাইকে ক্ষমা করে দিন।',
        reference: 'Sunan Abi Dawud 3201',
        order: 3,
      ),
      DuaModel(
        id: 'dua_patience',
        titleEn: 'Supplication in Bereavement & Loss',
        titleBn: 'শোক ও বিপদে সান্ত্বনার দোয়া',
        category: 'Patience',
        arabic:
            'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
        transliteration:
            'Inna lillahi wa inna ilayhi raji\'un. Allahumma ajirni fi musibati wa akhlif li khayran minha',
        translationEn:
            'Indeed we belong to Allah, and indeed to Him we will return. O Allah, reward me for my affliction and compensate me with something better.',
        translationBn:
            'নিশ্চয়ই আমরা আল্লাহর জন্য এবং নিশ্চয়ই আমরা তাঁরই কাছে ফিরে যাব। হে আল্লাহ! আমার এ বিপদে আমাকে পুরস্কৃত করুন এবং এর চেয়ে উত্তম বিনিময় দান করুন।',
        reference: 'Sahih Muslim 918',
        order: 4,
      ),
    ];
  }
}
