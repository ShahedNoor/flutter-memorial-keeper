import '../../../imports/imports.dart';

/// ToastCard widget to display decent and rich looking toast.
class ToastCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final Color? shadowColor;
  final void Function()? onTap;

  const ToastCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.color,
    this.shadowColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: color ?? context.theme.dialogTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: context.theme.colorScheme.outline,
          ),
        ),
        elevation: 4,
        shadowColor: shadowColor ?? Colors.black.withValues(alpha: 0.05),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: leading,
          ),
          trailing: trailing,
          subtitle: subtitle,
          title: title,
          onTap: onTap,
        ),
      ),
    );
  }
}

