import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import '../models/sample_memorial.dart';
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

  final List<SampleMemorial> _memorials = SampleMemorial.defaultList;

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

    final filteredMemorials = _memorials.where((m) {
      final matchesCategory =
          _selectedCategory == 'all' || m.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.relationship.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.restingPlace.toLowerCase().contains(_searchQuery.toLowerCase());
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
                  decoration: InputDecoration(
                    hintText: 'Search by name, relationship, or cemetery...',
                    prefixIcon: AppIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 18.sp,
                      color: cs.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: AppIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              size: 16.sp,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cs.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(color: cs.outlineVariant),
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
                // Daily Dua Banner with live counter
                const DuaHeroCard(),
                SizedBox(height: 16.h),

                // Offline Protection Status & Stats Overview
                SyncAndStatsCard(
                  memorialCount: _memorials.length,
                  placesCount: 3,
                  generationsCount: 3,
                ),
                SizedBox(height: 20.h),

                // Section Title with Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Family Departed Records',
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
                        '${filteredMemorials.length} Recorded',
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
                if (filteredMemorials.isEmpty)
                  const HomeEmptyState()
                else
                  ...filteredMemorials.map(
                    (memorial) => MemorialCard(
                      memorial: memorial,
                      onTap: () {
                        showGlobalToast(
                          message: 'Opening ${memorial.fullName} profile...',
                          status: 'info',
                        );
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
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onPressed: () {
          showGlobalToast(
            message: 'Create Memorial feature opening...',
            status: 'info',
          );
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
