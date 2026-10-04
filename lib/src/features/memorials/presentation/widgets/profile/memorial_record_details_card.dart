import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../imports/core_imports.dart';
import '../../../domain/entities/memorial.dart';
import 'profile_formatters.dart';

/// Card displaying detailed biographical information and record timeline.
class MemorialRecordDetailsCard extends StatelessWidget {
  const MemorialRecordDetailsCard({
    super.key,
    required this.memorial,
    required this.birthStr,
    required this.passStr,
  });

  final Memorial memorial;
  final String? birthStr;
  final String? passStr;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: cs.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Personal Record',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildDetailRow('Full Name', memorial.fullName, cs),
          if (memorial.arabicName != null &&
              memorial.arabicName!.trim().isNotEmpty)
            _buildDetailRow('Alt Name', memorial.arabicName!, cs),
          _buildDetailRow('Relationship', memorial.displayRelationship, cs),
          _buildDetailRow('Gender', memorial.gender.toUpperCase(), cs),
          _buildDetailRow('Category', memorial.category.toUpperCase(), cs),
          if (birthStr != null) _buildDetailRow('Date of Birth', birthStr!, cs),
          if (passStr != null) _buildDetailRow('Date of Passing', passStr!, cs),
          if (memorial.age != null)
            _buildDetailRow('Age at Passing', '${memorial.age} years', cs),
          _buildDetailRow(
            'Recorded in App',
            formatMemorialDate(memorial.createdAt),
            cs,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
