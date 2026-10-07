import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

import '../../imports/core_imports.dart';

/// Service/Helper to crop images natively using Android uCrop and iOS TOCropViewController,
/// and immediately compress them preserving crisp resolution and reducing file size.
class AppImageCropperScreen {
  AppImageCropperScreen._();

  /// Launches the native hardware-accelerated cropper.
  ///
  /// * For avatars/profiles: Uses [CropStyle.circle] with 1:1 ratio.
  /// * For resting places/graves: Uses [CropStyle.rectangle] with freeform and standard aspect presets.
  ///
  /// After cropping, the image is automatically compressed by [ImageCompressionService]
  /// at high perceptual quality (85) preserving exact resolution.
  ///
  /// Returns the processed [File], or `null` if the user cancelled.
  static Future<File?> cropAndCompress(
    BuildContext context, {
    required File imageFile,
    bool isCircle = false,
    String? title,
    double? aspectRatio,
  }) async {
    final cs = context.colors;
    final displayTitle = title ?? (isCircle ? 'Crop Profile Photo' : 'Frame Photo');

    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: displayTitle,
          toolbarColor: cs.surface,
          toolbarWidgetColor: cs.onSurface,
          statusBarLight: Theme.of(context).brightness == Brightness.light,
          backgroundColor: cs.surface,
          activeControlsWidgetColor: cs.primary,
          dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
          cropFrameColor: cs.primary,
          cropGridColor: cs.primary.withValues(alpha: 0.4),
          initAspectRatio: isCircle
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.original,
          lockAspectRatio: isCircle,
          cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
          aspectRatioPresets: isCircle
              ? [CropAspectRatioPreset.square]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
        IOSUiSettings(
          title: displayTitle,
          cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
          aspectRatioLockEnabled: isCircle,
          resetAspectRatioEnabled: !isCircle,
          aspectRatioPickerButtonHidden: isCircle,
          aspectRatioPresets: isCircle
              ? [CropAspectRatioPreset.square]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
      ],
    );

    if (cropped == null) {
      return null;
    }

    final croppedFile = File(cropped.path);

    // Compress resulting cropped image to guarantee lightweight file size with crisp quality
    return ImageCompressionService.instance.compressImage(
      croppedFile,
      quality: 85,
    );
  }
}
