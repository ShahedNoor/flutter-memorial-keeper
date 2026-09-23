import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

import '../../../home/presentation/models/sample_memorial.dart';
import '../../../home/presentation/widgets/home_empty_state.dart';
import '../../../home/presentation/widgets/memorial_card.dart';

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

  // Master sample data
  final List<SampleMemorial> _familyList = const [
    SampleMemorial(
      id: '1',
      fullName: 'Haji Abdul Gafur',
      relationship: 'Paternal Grandfather (দাদা)',
      category: 'grandparents',
      birthYear: '1935',
      passingYear: '2016',
      age: 81,
      restingPlace: 'Azimpur Graveyard, Plot 14, Dhaka',
    ),
    SampleMemorial(
      id: '2',
      fullName: 'Begum Rokeya Khatun',
      relationship: 'Paternal Grandmother (দাদী)',
      category: 'grandparents',
      birthYear: '1942',
      passingYear: '2020',
      age: 78,
      restingPlace: 'Azimpur Graveyard, Plot 15, Dhaka',
    ),
    SampleMemorial(
      id: '3',
      fullName: 'Muhammad Shamsul Huda',
      relationship: 'Father (বাবা)',
      category: 'parents',
      birthYear: '1961',
      passingYear: '2023',
      age: 62,
      restingPlace: 'Banani Cemetery, Section B, Dhaka',
    ),
    SampleMemorial(
      id: '4',
      fullName: 'Nurul Islam Chowdhury',
      relationship: 'Maternal Uncle (মামা)',
      category: 'relatives',
      birthYear: '1955',
      passingYear: '2019',
      age: 64,
      restingPlace: 'Garibullah Shah Mazar Cemetery, Chittagong',
    ),
  ];

  final List<SampleMemorial> _othersList = const [
    SampleMemorial(
      id: '5',
      fullName: 'Prof. Dr. Jamaluddin Ahmed',
      relationship: 'Beloved University Mentor (শিক্ষক)',
      category: 'teachers',
      birthYear: '1948',
      passingYear: '2022',
      age: 74,
      restingPlace: 'Mirpur Martyred Intellectuals Graveyard, Dhaka',
    ),
    SampleMemorial(
      id: '6',
      fullName: 'Shafiqur Rahman',
      relationship: 'Childhood Best Friend (বন্ধু)',
      category: 'friends',
      birthYear: '1970',
      passingYear: '2021',
      age: 51,
      restingPlace: 'Rayer Bazar Graveyard, Dhaka',
    ),
    SampleMemorial(
      id: '7',
      fullName: 'Maulana Abdul Hai',
      relationship: 'Neighborhood Mosque Imam (ইমাম সাহেব)',
      category: 'elders',
      birthYear: '1938',
      passingYear: '2018',
      age: 80,
      restingPlace: 'Uttara Sector 4 Cemetery, Dhaka',
    ),
  ];

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

  List<SampleMemorial> _filterList(List<SampleMemorial> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((m) {
      return m.fullName.toLowerCase().contains(query) ||
          m.relationship.toLowerCase().contains(query) ||
          m.restingPlace.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final filteredFamily = _filterList(_familyList);
    final filteredOthers = _filterList(_othersList);

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
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          size: 16.sp,
                          color: _tabController.index == 0
                              ? Colors.white
                              : cs.onSurfaceVariant,
                        ),
                        SizedBox(width: 8.w),
                        Text('Family (${_familyList.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          size: 16.sp,
                          color: _tabController.index == 1
                              ? Colors.white
                              : cs.onSurfaceVariant,
                        ),
                        SizedBox(width: 8.w),
                        Text('Others & Friends (${_othersList.length})'),
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
              decoration: InputDecoration(
                hintText: 'Search by name, role, or cemetery...',
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
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
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
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        onPressed: () {
          final isFamily = _tabController.index == 0;
          showGlobalToast(
            message:
                'Adding new ${isFamily ? "Family Member" : "Acquaintance"}...',
            status: 'info',
          );
        },
        icon: AppIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          _tabController.index == 0 ? 'Add Family Member' : 'Add Acquaintance',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMemorialListView({
    required List<SampleMemorial> memorials,
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
            showGlobalToast(
              message: 'Opening ${memorial.fullName} profile...',
              status: 'info',
            );
          },
        );
      },
    );
  }
}
