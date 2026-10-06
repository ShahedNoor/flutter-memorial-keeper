import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Helper utility for resolving images seamlessly whether they are stored
/// online on Cloudflare R2 (https://) or locally on disk.
class AppImageHelper {
  AppImageHelper._();

  /// Returns `true` if [pathOrUrl] points to a valid remote URL or existing local file.
  static bool hasValidImage(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return false;
    final trimmed = pathOrUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return true;
    }
    return File(trimmed).existsSync();
  }

  /// Resolves an [ImageProvider] supporting both Cloudflare R2 network URLs
  /// (with offline disk caching via [CachedNetworkImageProvider]) and local files ([FileImage]).
  static ImageProvider? resolveImageProvider(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;
    final trimmed = pathOrUrl.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return CachedNetworkImageProvider(trimmed);
    }

    final file = File(trimmed);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return null;
  }
}
