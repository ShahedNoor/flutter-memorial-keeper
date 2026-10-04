import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

/// Shows a respectful confirmation bottom sheet to delete a memorial record,
/// requiring the user to type 'delete' to prevent accidental loss.
Future<bool> showDeleteMemorialSheet(
  BuildContext context, {
  required String fullName,
}) async {
  HapticFeedback.mediumImpact();

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (ctx) => _DeleteMemorialModal(fullName: fullName),
  );

  return confirmed ?? false;
}

class _DeleteMemorialModal extends StatefulWidget {
  const _DeleteMemorialModal({required this.fullName});

  final String fullName;

  @override
  State<_DeleteMemorialModal> createState() => _DeleteMemorialModalState();
}

class _DeleteMemorialModalState extends State<_DeleteMemorialModal> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final matches = _confirmController.text.trim().toLowerCase() == 'delete';
    if (matches != _isValid) {
      setState(() => _isValid = matches);
    }
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tt = context.textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    size: 26.sp,
                    color: cs.error,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Delete Memorial Record?',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to delete the record for "${widget.fullName}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: cs.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    AppIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      size: 16.sp,
                      color: cs.error,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Type ',
                          children: [
                            TextSpan(
                              text: 'delete',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.error,
                              ),
                            ),
                            const TextSpan(text: ' below to confirm:'),
                          ],
                        ),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _confirmController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_isValid) Navigator.pop(context, true);
                },
                decoration: InputDecoration(
                  hintText: 'Type "delete" here',
                  hintStyle: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: _isValid
                          ? cs.error
                          : cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: cs.error,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: _isValid
                      ? Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: AppIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            size: 20.sp,
                            color: cs.error,
                          ),
                        )
                      : null,
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 32.w,
                    minHeight: 32.h,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: tt.labelLarge),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        disabledForegroundColor:
                            cs.onSurfaceVariant.withValues(alpha: 0.4),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isValid
                          ? () => Navigator.pop(context, true)
                          : null,
                      child: Text(
                        'Delete',
                        style: tt.labelLarge?.copyWith(
                          color: _isValid
                              ? Colors.white
                              : cs.onSurfaceVariant
                                  .withValues(alpha: 0.4),
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
  }
}
