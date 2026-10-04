import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import 'package:memorialkeeper/src/features/memorials/domain/entities/memorial.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/providers/memorial_bloc.dart';
import 'package:memorialkeeper/src/features/home/presentation/widgets/home_empty_state.dart';
import 'package:memorialkeeper/src/features/home/presentation/widgets/memorial_card.dart';

/// Comprehensive Memorial Directory with dedicated Family and Others tabs.
class MemorialDirectoryScreen extends StatefulWidget {
  const MemorialDirectoryScreen({super.key});

  @override
  State<MemorialDirectoryScreen> createState() =>
      _MemorialDirectoryScreenState();
}

class _MemorialDirectoryScreenState extends State<MemorialDirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Memorial> _filterList(List<Memorial> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((m) {
      return m.fullName.toLowerCase().contains(query) ||
          (m.arabicName?.toLowerCase().contains(query) ?? false) ||
          m.displayRelationship.toLowerCase().contains(query) ||
          m.restingPlaceDisplay.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final memorialState = context.watch<MemorialBloc>().state;
    final filteredFamily = _filterList(memorialState.familyMemorials);
    final filteredOthers = _filterList(memorialState.othersMemorials);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Memorial Directory',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: cs.surface,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                indicator: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          size: 15.sp,
                          color: _tabController.index == 0
                              ? Colors.white
                              : cs.onSurfaceVariant,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'Family (${filteredFamily.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          size: 15.sp,
                          color: _tabController.index == 1
                              ? Colors.white
                              : cs.onSurfaceVariant,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'Others & Friends (${filteredOthers.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name, role, or cemetery...',
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

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Family Tab
                _buildMemorialListView(
                  memorials: filteredFamily,
                  emptyMessage: 'No family records found',
                  emptySubtitle: 'Add your close relatives and ancestors.',
                  cs: cs,
                  tt: tt,
                ),

                // 2. Others & Acquaintances Tab
                _buildMemorialListView(
                  memorials: filteredOthers,
                  emptyMessage: 'No acquaintances or friends found',
                  emptySubtitle: 'Add teachers, mentors, or dear friends.',
                  cs: cs,
                  tt: tt,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'directory_add_memorial_fab',
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
          _tabController.index == 0 ? 'Add Family Member' : 'Add Person Record',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMemorialListView({
    required List<Memorial> memorials,
    required String emptyMessage,
    required String emptySubtitle,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    if (memorials.isEmpty) {
      return HomeEmptyState(
        message: emptyMessage,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 80.h),
      itemCount: memorials.length,
      itemBuilder: (context, index) {
        final memorial = memorials[index];
        return MemorialCard(
          memorial: memorial,
          onTap: () {
            context.push(AppRoutes.memorialDetail, extra: memorial);
          },
        );
      },
    );
  }
}
