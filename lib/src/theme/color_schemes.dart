import 'package:flutter/material.dart';

/// App-specific colors that aren't part of the standard [ColorScheme].
/// Access via `context.appColors` (defined in `context_extension.dart`).
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    this.successContainer,
    this.onSuccessContainer,
    this.warningContainer,
    this.onWarningContainer,
    this.infoContainer,
    this.onInfoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color? successContainer;
  final Color? onSuccessContainer;
  final Color? warningContainer;
  final Color? onWarningContainer;
  final Color? infoContainer;
  final Color? onInfoContainer;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t),
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t),
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t),
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t),
    );
  }
  }

/// Helper class to define the actual color palettes
class AppPalettes {
  AppPalettes._();

  static const light = AppColorsExtension(
    success: Color(0xFF0D5C46),
    onSuccess: Colors.white,
    successContainer: Color(0xFFD4EDE4),
    onSuccessContainer: Color(0xFF04382A),
    warning: Color(0xFFD97706),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFEF3C7),
    onWarningContainer: Color(0xFF92400E),
    info: Color(0xFF0284C7),
    onInfo: Colors.white,
    infoContainer: Color(0xFFE0F2FE),
    onInfoContainer: Color(0xFF075985),
  );

  static const dark = AppColorsExtension(
    success: Color(0xFF34D399),
    onSuccess: Color(0xFF04382A),
    successContainer: Color(0xFF0D5C46),
    onSuccessContainer: Color(0xFFD4EDE4),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF78350F),
    warningContainer: Color(0xFF78350F),
    onWarningContainer: Color(0xFFFEF3C7),
    info: Color(0xFF38BDF8),
    onInfo: Color(0xFF075985),
    infoContainer: Color(0xFF0C4A6E),
    onInfoContainer: Color(0xFFE0F2FE),
  );
}

/// Access semantic colors via `context.appColors` from `context_extension.dart`.
/// Example: `context.appColors.success`