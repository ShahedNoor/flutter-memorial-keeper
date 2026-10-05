import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../providers/dua_cubit.dart';
import '../widgets/widgets.dart';

/// Authentic Islamic Duas & Remembrance for departed souls,
/// synced directly from Firebase Firestore with offline-first fallback.
class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Sync latest from Firebase on screen visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DuaCubit>();
      if (cubit.state.duas.isEmpty) {
        cubit.loadDuas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final duaState = context.watch<DuaCubit>().state;
    final duas = duaState.filteredDuas;

    // Translation language strictly follows global app locale (en / bn)
    final activeLanguage = context.locale.languageCode == 'bn' ? 'bn' : 'en';

    // Extract categories
    final allCategories = ['all'];
    for (final d in duaState.duas) {
      final cat = d.category.toLowerCase();
      if (!allCategories.contains(cat)) {
        allCategories.add(cat);
      }
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'duas.title'.tr(),
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
        actions: [
          IconButton(
            icon: AppIcon(
              icon: Icons.format_size_rounded,
              size: 22.sp,
              color: cs.onSurfaceVariant,
            ),
            tooltip: 'duas.adjust_font_size'.tr(),
            onPressed: () {
              HapticFeedback.lightImpact();
              DuaFontSizeSheet.show(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 6.h),
          // Categories Bar
          if (allCategories.length > 2) ...[
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                scrollDirection: Axis.horizontal,
                itemCount: allCategories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  final isSelected = duaState.selectedCategory == cat;
                  final String label;
                  switch (cat) {
                    case 'all':
                      label = 'duas.all'.tr();
                      break;
                    case 'parents':
                      label = 'duas.parents'.tr();
                      break;
                    case 'ziyarat':
                      label = 'duas.ziyarat'.tr();
                      break;
                    case 'general':
                      label = 'duas.general'.tr();
                      break;
                    case 'patience':
                      label = 'duas.patience'.tr();
                      break;
                    default:
                      label = cat[0].toUpperCase() + cat.substring(1);
                  }

                  return InkWell(
                    onTap: () {
                      context.read<DuaCubit>().selectCategory(cat);
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? cs.primary
                              : cs.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : cs.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],

          // Dua Cards List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  context.read<DuaCubit>().loadDuas(forceRefresh: true),
              color: cs.primary,
              child: duas.isEmpty
                  ? Center(
                      child: Text(
                        'duas.empty'.tr(),
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                      itemCount: duas.length,
                      itemBuilder: (context, index) {
                        final dua = duas[index];
                        return DuaCard(
                          dua: dua,
                          activeLanguage: activeLanguage,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
