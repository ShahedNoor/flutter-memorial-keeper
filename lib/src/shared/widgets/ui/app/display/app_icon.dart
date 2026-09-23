import '../../../../../imports/imports.dart';

/// A wrapper widget that handles different icon libraries.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  /// The icon to display. Supports [IconData] or [HugeIcons] vector list.
  final dynamic icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? context.theme.colorScheme.onSurface;
    final iconSize = size ?? IconTheme.of(context).size ?? 24.0;

    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: iconSize,
        color: iconColor,
      );
    }

    return HugeIcon(
      icon: icon,
      size: iconSize,
      color: iconColor,
    );
  }
}

