import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

/// Service responsible for compressing images while preserving visual quality
/// and original resolution.
class ImageCompressionService {
  ImageCompressionService._();
  static final ImageCompressionService instance = ImageCompressionService._();

  /// Compresses the given [file] with high perceptual quality (default quality 85),
  /// stripping bloat and optimizing encoding without downscaling the resolution.
  ///
  /// Returns a new compressed [File] (typically in temp directory).
  /// If compression fails or produces a larger file, returns the original [file].
  Future<File> compressImage(
    File file, {
    int quality = 85,
    CompressFormat format = CompressFormat.jpeg,
    int maxDimension = 4096,
  }) async {
    try {
      final originalLength = await file.length();
      if (originalLength <= 0) return file;

      final tempDir = await getTemporaryDirectory();
      final ext = format == CompressFormat.webp
          ? '.webp'
          : (format == CompressFormat.png ? '.png' : '.jpg');
      final targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(file.path)}$ext',
      );

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
        format: format,
        keepExif: false, // Strips bloated EXIF data while preserving correct orientation
        autoCorrectionAngle: true,
      );

      if (compressedXFile == null) {
        AppLogger.warning('Image compression returned null, using original file');
        return file;
      }

      final compressedFile = File(compressedXFile.path);
      final newLength = await compressedFile.length();

      AppLogger.info(
        'Image compressed: ${(originalLength / 1024).toStringAsFixed(1)} KB -> '
        '${(newLength / 1024).toStringAsFixed(1)} KB '
        '(-${((1 - newLength / originalLength) * 100).toStringAsFixed(1)}%)',
      );

      // If for any rare reason compressed size is larger, retain original
      if (newLength >= originalLength) {
        return file;
      }

      return compressedFile;
    } catch (e, stack) {
      AppLogger.error(
        'Failed to compress image, falling back to original: $e',
        error: e,
        stackTrace: stack,
      );
      return file;
    }
  }
}
