import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import 'package:memorialkeeper/src/features/memorials/domain/entities/memorial.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/providers/memorial_bloc.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/widgets/delete_memorial_sheet.dart';

/// Dignified memorial card with avatar frame, relationship badge, lifespan, and resting place pill.
class MemorialCard extends StatelessWidget {
  const MemorialCard({
    super.key,
    required this.memorial,
    this.onTap,
  });

  final Memorial memorial;
  final VoidCallback? onTap;

  void _onToggleFavorite(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<MemorialBloc>().add(ToggleFavoriteEvent(memorial.id));
    showGlobalToast(
      message: memorial.isFavorite
          ? 'Removed ${memorial.fullName} from favorites'
          : 'Added ${memorial.fullName} to favorites',
      status: 'info',
    );
  }

  Future<void> _onLongPressDelete(BuildContext context) async {
    final confirmed = await showDeleteMemorialSheet(
      context,
      fullName: memorial.fullName,
    );

    if (confirmed && context.mounted) {
      context.read<MemorialBloc>().add(DeleteMemorialEvent(memorial.id));
      showGlobalToast(
        message: 'Deleted record for ${memorial.fullName}',
        status: 'info',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final imageProvider =
        AppImageHelper.resolveImageProvider(memorial.profilePhotoPath);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap ??
            () => context.push(AppRoutes.memorialDetail, extra: memorial),
        onLongPress: () => _onLongPressDelete(context),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: memorial.isFavorite
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Avatar frame
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      image: imageProvider != null
                          ? DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageProvider == null
                        ? Center(
                            child: AppIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              color: cs.primary,
                              size: 26.sp,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: memorial.fullName,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                              fontSize: 15.sp,
                              height: 1.25,
                            ),
                            children: [
                              if (memorial.arabicName != null &&
                                  memorial.arabicName!.trim().isNotEmpty) ...[
                                TextSpan(
                                  text: '  ${memorial.arabicName!}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            memorial.displayRelationship,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        if (memorial.lifespanDisplay.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            memorial.lifespanDisplay,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Favorite / Tribute Button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: memorial.isFavorite
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: AppIcon(
                      icon: memorial.isFavorite
                          ? Icons.favorite
                          : HugeIcons.strokeRoundedFavourite,
                      color: memorial.isFavorite
                          ? cs.primary
                          : cs.onSurfaceVariant,
                      size: 18.sp,
                    ),
                    onPressed: () => _onToggleFavorite(context),
                  ),
                ],
              ),
              if (memorial.restingPlaceDisplay.isNotEmpty) ...[
                SizedBox(height: 12.h),
                // Resting Place Pill
                InkWell(
                  onTap: (memorial.latitude != null && memorial.longitude != null)
                      ? () => LocationService.instance.openInMaps(
                            memorial.latitude!,
                            memorial.longitude!,
                            label: memorial.cemeteryName ?? memorial.fullName,
                          )
                      : null,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          icon: HugeIcons.strokeRoundedLocation01,
                          size: 14.sp,
                          color: cs.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            memorial.restingPlaceDisplay,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurface,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (memorial.latitude != null &&
                            memorial.longitude != null) ...[
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.navigation_rounded,
                                    size: 10.sp, color: cs.primary),
                                SizedBox(width: 2.w),
                                Text(
                                  'GPS',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
