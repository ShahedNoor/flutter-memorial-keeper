import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';
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

    // Determine current language: use active language in cubit, defaulting to locale
    final localeLang = context.locale.languageCode;
    final activeLanguage = duaState.activeLanguage.isNotEmpty
        ? duaState.activeLanguage
        : (localeLang == 'bn' ? 'bn' : 'en');

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
          'Duas & Remembrance',
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
              icon: HugeIcons.strokeRoundedRefresh,
              size: 20.sp,
              color: cs.onSurfaceVariant,
            ),
            tooltip: 'Sync from Cloud',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<DuaCubit>().loadDuas(forceRefresh: true);
              showGlobalToast(
                message: 'Checking cloud for new Duas...',
                status: 'info',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Bar: Language Switcher & Category Filter
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Translation Language:',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  padding: EdgeInsets.all(3.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLangPill(
                        label: 'English',
                        code: 'en',
                        isActive: activeLanguage == 'en',
                        cs: cs,
                        onTap: () {
                          context.read<DuaCubit>().switchLanguage('en');
                        },
                      ),
                      _buildLangPill(
                        label: 'বাংলা',
                        code: 'bn',
                        isActive: activeLanguage == 'bn',
                        cs: cs,
                        onTap: () {
                          context.read<DuaCubit>().switchLanguage('bn');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
                  final label = cat == 'all'
                      ? 'All'
                      : cat[0].toUpperCase() + cat.substring(1);

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
                        color: isSelected
                            ? cs.primary
                            : cs.surfaceContainerLow,
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
                        'No Duas found in this category',
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

  Widget _buildLangPill({
    required String label,
    required String code,
    required bool isActive,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isActive ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
