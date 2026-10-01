import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import 'package:memorial_keeper/src/features/memorials/presentation/providers/memorial_bloc.dart';
import '../widgets/widgets.dart';

/// Clean, modular Home Page orchestrating header, dua banner, stats, filters, and memorial records.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final memorialState = context.watch<MemorialBloc>().state;
    final allMemorials = memorialState.memorials;

    final filteredMemorials = allMemorials.where((m) {
      final matchesCategory =
          _selectedCategory == 'all' || m.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          m.fullName.toLowerCase().contains(query) ||
          (m.arabicName?.toLowerCase().contains(query) ?? false) ||
          m.displayRelationship.toLowerCase().contains(query) ||
          m.restingPlaceDisplay.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // 1. Header with Gradient, Arabic Badge & Actions
          HomeHeader(
            isSearchActive: _isSearchActive,
            onSearchToggle: _toggleSearch,
          ),

          // 2. Expandable Search Input
          if (_isSearchActive)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, relationship, or cemetery...',
                    hintStyle: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14.w, right: 10.w),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 20.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 44.w,
                      minHeight: 44.h,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: AppIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              size: 18.sp,
                              color: cs.onSurfaceVariant,
                            ),
                            splashRadius: 18.r,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 44.w,
                      minHeight: 44.h,
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: cs.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 3. Main Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!_isSearchActive) ...[
                  // Daily Dua Banner with live counter
                  const DuaHeroCard(),
                  SizedBox(height: 16.h),

                  // Dynamically compute real stats from all recorded memorials
                  Builder(
                    builder: (context) {
                      // 1. Unique Resting Places count
                      final uniquePlaces = <String>{};
                      for (final m in allMemorials) {
                        final name = m.cemeteryName?.trim();
                        final area = m.cemeteryArea?.trim();
                        if (name != null && name.isNotEmpty) {
                          uniquePlaces.add(name.toLowerCase());
                        } else if (area != null && area.isNotEmpty) {
                          uniquePlaces.add(area.toLowerCase());
                        }
                      }

                      // 2. Family Generations count (based on genealogical tiers)
                      final generationTiers = <int>{};
                      for (final m in allMemorials) {
                        final rel = m.relationship.toLowerCase();
                        if (rel.contains('great_grand') ||
                            rel.contains('great-grand')) {
                          generationTiers.add(3); // Great-grandparents
                        } else if (rel.contains('grand')) {
                          generationTiers.add(2); // Grandparents tier
                        } else if (rel == 'father' ||
                            rel == 'mother' ||
                            rel == 'uncle' ||
                            rel == 'aunt') {
                          generationTiers.add(1); // Parents & aunts/uncles tier
                        } else if (rel == 'son' ||
                            rel == 'daughter' ||
                            rel == 'nephew' ||
                            rel == 'niece') {
                          generationTiers.add(-1); // Children tier
                        } else if (rel.contains('grandson') ||
                            rel.contains('granddaughter') ||
                            rel.contains('grandchild')) {
                          generationTiers.add(-2); // Grandchildren tier
                        } else {
                          // Self, spouse, brother, sister, friends, colleagues tier
                          generationTiers.add(0);
                        }
                      }

                      return SyncAndStatsCard(
                        memorialCount: allMemorials.length,
                        placesCount: uniquePlaces.length,
                        generationsCount: generationTiers.length,
                        onTapMemorials: () {
                          MemorialsPeekSheet.show(context, allMemorials);
                        },
                        onTapPlaces: () {
                          RestingPlacesPeekSheet.show(context, allMemorials);
                        },
                        onTapGenerations: () {
                          GenerationsPeekSheet.show(context, allMemorials);
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],

                // Section Title with Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSearchActive
                          ? 'Search Results'
                          : 'Family Departed Records',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _isSearchActive
                            ? '${filteredMemorials.length} Found'
                            : '${filteredMemorials.length} Recorded',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Category Filter Pills
                CategoryFilterBar(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
                SizedBox(height: 16.h),

                // Memorial List / Empty State
                if (filteredMemorials.isEmpty) ...[
                  if (_isSearchActive)
                    HomeEmptyState(
                      message: _searchQuery.isNotEmpty
                          ? 'No records matching "$_searchQuery"'
                          : 'No records found',
                      subtitle:
                          'Try searching with another name, relationship, or cemetery.',
                    )
                  else
                    const HomeEmptyState(),
                ] else
                  ...filteredMemorials.map(
                    (memorial) => MemorialCard(
                      memorial: memorial,
                      onTap: () {
                        context.push(AppRoutes.addMemorial, extra: memorial);
                      },
                    ),
                  ),

                SizedBox(height: 80.h), // Clearance for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_add_memorial_fab',
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onPressed: () {
          context.push(AppRoutes.addMemorial);
        },
        icon: AppIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'home.add_memorial'.tr(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
