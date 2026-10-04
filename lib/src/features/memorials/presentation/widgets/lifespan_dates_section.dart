import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Form section managing Lifespan & Dates with Year-only toggle, Date pickers and Age calculation.
class LifespanDatesSection extends StatelessWidget {
  const LifespanDatesSection({
    super.key,
    required this.isYearOnly,
    required this.birthYearController,
    required this.passingYearController,
    required this.ageController,
    required this.dateOfBirth,
    required this.dateOfDeath,
    required this.onToggleYearOnly,
    required this.onPickBirthDate,
    required this.onPickDeathDate,
    required this.onYearChanged,
    required this.inputDecoration,
  });

  final bool isYearOnly;
  final TextEditingController birthYearController;
  final TextEditingController passingYearController;
  final TextEditingController ageController;
  final DateTime? dateOfBirth;
  final DateTime? dateOfDeath;
  final ValueChanged<bool> onToggleYearOnly;
  final VoidCallback onPickBirthDate;
  final VoidCallback onPickDeathDate;
  final VoidCallback onYearChanged;
  final InputDecoration Function({required String hint, dynamic prefixIcon})
      inputDecoration;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lifespan & Dates',
              style: tt.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => onToggleYearOnly(!isYearOnly),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isYearOnly
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isYearOnly
                        ? cs.primary.withValues(alpha: 0.35)
                        : cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Year only',
                      style: tt.labelMedium?.copyWith(
                        color: isYearOnly ? cs.primary : cs.onSurfaceVariant,
                        fontWeight:
                            isYearOnly ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      height: 22.h,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: isYearOnly,
                          activeTrackColor: cs.primary,
                          thumbColor: Colors.white,
                          onChanged: onToggleYearOnly,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (isYearOnly) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: birthYearController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onYearChanged(),
                  decoration: inputDecoration(hint: 'Birth Year (e.g. 1935)'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextFormField(
                  controller: passingYearController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onYearChanged(),
                  decoration: inputDecoration(hint: 'Death Year (e.g. 2016)'),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: onPickBirthDate,
                  child: Text(
                    dateOfBirth == null
                        ? 'Pick Birth Date'
                        : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
                    style: tt.bodySmall,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: onPickDeathDate,
                  child: Text(
                    dateOfDeath == null
                        ? 'Pick Death Date'
                        : '${dateOfDeath!.day}/${dateOfDeath!.month}/${dateOfDeath!.year}',
                    style: tt.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: inputDecoration(
              hint: 'Age (e.g. 81)',
              prefixIcon: HugeIcons.strokeRoundedClock01,
            ),
          ),
        ],
      ],
    );
  }
}
