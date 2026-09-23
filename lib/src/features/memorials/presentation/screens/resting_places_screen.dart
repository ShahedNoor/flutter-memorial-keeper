import 'package:memorial_keeper/src/imports/core_imports.dart';
import 'package:memorial_keeper/src/imports/packages_imports.dart';

class _CemeteryLocation {
  final String name;
  final String area;
  final String city;
  final int soulsCount;
  final List<String> personNames;

  const _CemeteryLocation({
    required this.name,
    required this.area,
    required this.city,
    required this.soulsCount,
    required this.personNames,
  });
}

/// Cemetery and Resting Places directory with directions and plot records.
class RestingPlacesScreen extends StatelessWidget {
  const RestingPlacesScreen({super.key});

  final List<_CemeteryLocation> _cemeteries = const [
    _CemeteryLocation(
      name: 'Azimpur Graveyard',
      area: 'Old Dhaka, Lalbagh',
      city: 'Dhaka',
      soulsCount: 2,
      personNames: ['Haji Abdul Gafur (Plot 14)', 'Begum Rokeya Khatun (Plot 15)'],
    ),
    _CemeteryLocation(
      name: 'Banani Cemetery',
      area: 'Block B, Road 11',
      city: 'Dhaka',
      soulsCount: 1,
      personNames: ['Muhammad Shamsul Huda (Section B)'],
    ),
    _CemeteryLocation(
      name: 'Garibullah Shah Mazar Cemetery',
      area: 'GEC Circle',
      city: 'Chittagong',
      soulsCount: 1,
      personNames: ['Nurul Islam Chowdhury'],
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
          'Resting Places (কবরস্থান)',
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
        itemCount: _cemeteries.length,
        itemBuilder: (context, index) {
          final c = _cemeteries[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: cs.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${c.area}, ${c.city}',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${c.soulsCount} Resting',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: cs.outlineVariant, height: 1),
                SizedBox(height: 10.h),
                Text(
                  'Loved Ones Resting Here:',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                ...c.personNames.map(
                  (name) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        Container(
                          width: 4.r,
                          height: 4.r,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          name,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
