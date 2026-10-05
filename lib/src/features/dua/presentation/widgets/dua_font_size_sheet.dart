import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import '../providers/dua_cubit.dart';

/// Modal bottom sheet allowing users to customize font sizes for Arabic text
/// and translations in the Duas & Remembrance feature, with real-time live preview.
class DuaFontSizeSheet extends StatelessWidget {
  const DuaFontSizeSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cs = context.theme.colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => const DuaFontSizeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return BlocBuilder<DuaCubit, DuaState>(
      builder: (context, state) {
        final cubit = context.read<DuaCubit>();
        final arabicSize = state.arabicFontSize;
        final translationSize = state.translationFontSize;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Header with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.format_size_rounded,
                              size: 20.sp,
                              color: cs.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'duas.font_size_title'.tr(),
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                'duas.font_size_subtitle'.tr(),
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  SizedBox(height: 16.h),

                  // Live Preview Box
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'duas.live_preview'.tr(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: cs.primary,
                              ),
                            ),
                            Text(
                              'Quran 17:24',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: arabicSize.sp,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                              height: 1.65,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Rabbir hamhuma kama rabbayani sagheera',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                            fontSize: (translationSize - 1).clamp(9, 18).sp,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          state.activeLanguage == 'bn'
                              ? 'হে আমার প্রতিপালক! তাদের প্রতি দয়া করুন যেভাবে তারা শৈশবে আমাকে লালনপালন করেছিলেন।'
                              : 'My Lord, have mercy upon them as they brought me up [when I was] small.',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface,
                            height: 1.45,
                            fontSize: translationSize.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // 1. Arabic Text Size Section
                  _buildSliderSection(
                    context: context,
                    title: 'duas.arabic_size'.tr(),
                    currentSizeLabel: '${arabicSize.toInt()} pt',
                    value: arabicSize,
                    min: 15,
                    max: 32,
                    divisions: 17,
                    onChanged: (val) {
                      cubit.setArabicFontSize(val);
                    },
                    onDecrease: () {
                      final newVal = (arabicSize - 1).clamp(15, 32).toDouble();
                      cubit.setArabicFontSize(newVal);
                    },
                    onIncrease: () {
                      final newVal = (arabicSize + 1).clamp(15, 32).toDouble();
                      cubit.setArabicFontSize(newVal);
                    },
                    presets: [
                      (label: 'duas.small'.tr(), size: 16),
                      (label: 'duas.normal'.tr(), size: 19),
                      (label: 'duas.large'.tr(), size: 24),
                      (label: 'duas.extra'.tr(), size: 28),
                    ],
                    onSelectPreset: (size) => cubit.setArabicFontSize(size),
                  ),

                  SizedBox(height: 18.h),

                  // 2. Translation Text Size Section
                  _buildSliderSection(
                    context: context,
                    title: 'duas.translation_size'.tr(),
                    currentSizeLabel: '${translationSize.toInt()} pt',
                    value: translationSize,
                    min: 11,
                    max: 20,
                    divisions: 9,
                    onChanged: (val) {
                      cubit.setTranslationFontSize(val);
                    },
                    onDecrease: () {
                      final newVal =
                          (translationSize - 1).clamp(11, 20).toDouble();
                      cubit.setTranslationFontSize(newVal);
                    },
                    onIncrease: () {
                      final newVal =
                          (translationSize + 1).clamp(11, 20).toDouble();
                      cubit.setTranslationFontSize(newVal);
                    },
                    presets: [
                      (label: 'duas.compact'.tr(), size: 11),
                      (label: 'duas.normal'.tr(), size: 13),
                      (label: 'duas.medium'.tr(), size: 15),
                      (label: 'duas.large'.tr(), size: 18),
                    ],
                    onSelectPreset: (size) => cubit.setTranslationFontSize(size),
                  ),

                  SizedBox(height: 20.h),

                  // Bottom Action Buttons: Reset & Done
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            cubit.resetFontSizes();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurfaceVariant,
                            side: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'duas.reset_default'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'duas.done'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderSection({
    required BuildContext context,
    required String title,
    required String currentSizeLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required List<({String label, double size})> presets,
    required ValueChanged<double> onSelectPreset,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Value Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  currentSizeLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Stepper & Slider Row
          Row(
            children: [
              // Decrease Button (A-)
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDecrease();
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'A-',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Slider
              Expanded(
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  activeColor: cs.primary,
                  inactiveColor: cs.surfaceContainerHighest,
                  onChanged: (newVal) {
                    HapticFeedback.selectionClick();
                    onChanged(newVal);
                  },
                ),
              ),

              // Increase Button (A+)
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onIncrease();
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'A+',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Presets Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: presets.map((preset) {
              final isSelected = (value - preset.size).abs() < 0.6;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectPreset(preset.size);
                },
                borderRadius: BorderRadius.circular(8.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : cs.surfaceContainerHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    preset.label,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
