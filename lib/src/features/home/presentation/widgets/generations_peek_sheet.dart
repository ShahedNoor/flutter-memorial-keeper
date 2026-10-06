import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../../../memorials/domain/entities/memorial.dart';

/// Modal bottom sheet displaying the family root line and generational ladder.
class GenerationsPeekSheet extends StatelessWidget {
  const GenerationsPeekSheet({
    super.key,
    required this.memorials,
  });

  final List<Memorial> memorials;

  static Future<void> show(BuildContext context, List<Memorial> memorials) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => GenerationsPeekSheet(memorials: memorials),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    // Group memorials into ordered generational tiers (Oldest ancestors first)
    final Map<int, List<Memorial>> tiers = {};
    for (final m in memorials) {
      final rel = m.relationship.toLowerCase();
      final int tier;
      if (rel.contains('great_grand') || rel.contains('great-grand')) {
        tier = 3;
      } else if (rel.contains('grand')) {
        tier = 2;
      } else if (rel == 'father' ||
          rel == 'mother' ||
          rel == 'uncle' ||
          rel == 'aunt') {
        tier = 1;
      } else if (rel == 'son' ||
          rel == 'daughter' ||
          rel == 'nephew' ||
          rel == 'niece') {
        tier = -1;
      } else if (rel.contains('grandson') ||
          rel.contains('granddaughter') ||
          rel.contains('grandchild')) {
        tier = -2;
      } else {
        tier = 0; // Siblings, spouse, cousins, friends
      }
      tiers.putIfAbsent(tier, () => []).add(m);
    }

    // Sort tiers from highest (oldest ancestors) to lowest (descendants)
    final sortedTierKeys = tiers.keys.toList()..sort((a, b) => b.compareTo(a));

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              // Top Bar: Centered Drag Handle with Close Button on the Right
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 12.w, 0),
                child: Row(
                  children: [
                    SizedBox(width: 40.w), // Balance to keep pill centered
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 38.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: AppIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 20.sp,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Sheet Title Row
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: AppIcon(
                        icon: HugeIcons.strokeRoundedGitFork,
                        size: 22.sp,
                        color: cs.primary,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Family Lineage & Roots',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            sortedTierKeys.isEmpty
                                ? 'No family records recorded yet'
                                : 'Preserved across ${sortedTierKeys.length} Generations',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: cs.outlineVariant, height: 1),

              // Content List
              Expanded(
                child: sortedTierKeys.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                icon: HugeIcons.strokeRoundedUserGroup,
                                size: 48.sp,
                                color: cs.outline,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No Generational Records Yet',
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Add grandparents, parents, and siblings to view your family tree roots.',
                                textAlign: TextAlign.center,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        itemCount: sortedTierKeys.length,
                        itemBuilder: (context, index) {
                          final tier = sortedTierKeys[index];
                          final members = tiers[tier]!;
                          final isLastTier =
                              index == sortedTierKeys.length - 1;

                          return _buildGenerationalTierRow(
                            context: context,
                            tier: tier,
                            members: members,
                            isLastTier: isLastTier,
                            cs: cs,
                            tt: tt,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTierTitle(int tier) {
    return switch (tier) {
      3 => '1st Generation • Great-Grandparents (প্রপিতামহ/প্রপিতামহী)',
      2 => 'Grandparents Tier • Roots (দাদা/দাদী, নানা/নানী)',
      1 => 'Parents & Elders Tier (পিতামাতা ও অগ্রজ)',
      0 => 'Contemporary Tier (ভাইবোন ও সমসাময়িক)',
      -1 => 'Children & Descendants (সন্তান ও উত্তরসূরি)',
      -2 => 'Grandchildren (নাতি/নাতনি)',
      _ => 'Family Branch',
    };
  }

  Widget _buildGenerationalTierRow({
    required BuildContext context,
    required int tier,
    required List<Memorial> members,
    required bool isLastTier,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Lineage Connector
          Column(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedTree01,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLastTier)
                Expanded(
                  child: Container(
                    width: 2,
                    color: cs.primary.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),

          // Tier Card & Member Badges
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLastTier ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generation Tier Title Pill
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      _getTierTitle(tier),
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Members in this Tier
                  ...members.map((m) => _buildMemberCard(context, m, cs, tt)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Memorial m,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final imageProvider =
        AppImageHelper.resolveImageProvider(m.profilePhotoPath);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.memorialDetail, extra: m);
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
                      ? Center(
                          child: Text(
                            m.fullName.isNotEmpty
                                ? m.fullName.characters.first.toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),

                // Name & Relation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              m.fullName,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              m.displayRelationship,
                              style: tt.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (m.lifespanDisplay.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        Text(
                          m.lifespanDisplay,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                AppIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 16.sp,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
