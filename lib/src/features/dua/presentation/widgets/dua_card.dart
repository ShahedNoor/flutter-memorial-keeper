import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../../domain/entities/dua.dart';
import '../providers/dua_cubit.dart';

class DuaCard extends StatelessWidget {
  const DuaCard({
    super.key,
    required this.dua,
    required this.activeLanguage,
    this.arabicFontSize,
    this.translationFontSize,
  });

  final Dua dua;
  final String activeLanguage;
  final double? arabicFontSize;
  final double? translationFontSize;

  String _categoryLabel(String cat) {
    switch (cat.trim().toLowerCase()) {
      case 'parents':
        return 'duas.parents'.tr();
      case 'ziyarat':
        return 'duas.ziyarat'.tr();
      case 'general':
        return 'duas.general'.tr();
      case 'patience':
        return 'duas.patience'.tr();
      default:
        return cat.isNotEmpty ? cat[0].toUpperCase() + cat.substring(1) : cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final duaState = context.watch<DuaCubit>().state;
    final currentArabicSize = arabicFontSize ?? duaState.arabicFontSize;
    final currentTranslationSize =
        translationFontSize ?? duaState.translationFontSize;

    final title = dua.displayTitle(activeLanguage);
    final translation = dua.displayTranslation(activeLanguage);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Category
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _categoryLabel(dua.category),
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Main Arabic Text Frame
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              dua.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: currentArabicSize.sp,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                height: 1.65,
              ),
            ),
          ),

          // Transliteration (if present)
          if (dua.transliteration.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              dua.transliteration,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
                fontSize: (currentTranslationSize - 1).clamp(9, 18).sp,
                height: 1.4,
              ),
            ),
          ],

          // Translation
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 2.h, right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  activeLanguage == 'bn' ? 'বাংলা' : 'EN',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  translation,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface,
                    height: 1.45,
                    fontSize: currentTranslationSize.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Footer: Reference and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dua.reference,
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: AppIcon(
                      icon: HugeIcons.strokeRoundedCopy01,
                      color: cs.onSurfaceVariant,
                      size: 18.sp,
                    ),
                    tooltip: 'duas.copy_dua'.tr(),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${dua.arabic}\n\n$translation\n— ${dua.reference}',
                        ),
                      );
                      showGlobalToast(
                        message: 'duas.copied_toast'.tr(),
                        status: 'info',
                      );
                    },
                  ),
                  IconButton(
                    icon: AppIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: cs.primary,
                      size: 20.sp,
                    ),
                    tooltip: 'duas.mark_recited'.tr(),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showGlobalToast(
                        message: 'duas.recited_toast'.tr(),
                        status: 'success',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
