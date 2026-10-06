import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';

import '../imports/core_imports.dart';

/// Result object returned by Cloudflare R2 upload operations.
class R2UploadResult {
  const R2UploadResult({
    required this.publicUrl,
    required this.storageKey,
    required this.bytesLength,
    required this.contentType,
  });

  /// The public HTTPS URL to access and render the uploaded object.
  final String publicUrl;

  /// The internal S3 / R2 storage key path (used for deletion and tracking).
  final String storageKey;

  /// Byte size of the uploaded file.
  final int bytesLength;

  /// MIME content type (e.g. image/jpeg, image/png).
  final String contentType;

  @override
  String toString() =>
      'R2UploadResult(publicUrl: $publicUrl, storageKey: $storageKey, size: $bytesLength)';
}

/// Service for managing Cloudflare R2 object storage via AWS SigV4 S3 protocol.
///
/// Multi-project ready:
/// All objects are namespaced by project (default: `memorialkeeper/`), owner user ID,
/// and resource type, ensuring clean multi-tenant isolation within a shared bucket.
class R2StorageService {
  R2StorageService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
  }

  static final R2StorageService instance = R2StorageService._();

  late final Dio _dio;

  /// Project namespace prefix to avoid bucket key collisions across projects.
  static const String projectNamespace = 'memorialkeeper';

  String get _accountId =>
      dotenv.get('R2_ACCOUNT_ID', fallback: '08cb6e9bc0279cf05048e9cea5e29103');

  String get _bucketName =>
      dotenv.get('R2_BUCKET_NAME', fallback: 'memorial-keeper');

  String get _accessKeyId =>
      dotenv.get('R2_ACCESS_KEY_ID', fallback: 'cdb0e997891bf6856d288c1347b9f863');

  String get _secretAccessKey => dotenv.get(
        'R2_SECRET_ACCESS_KEY',
        fallback: 'e3d2f3ab2e33f8f0017777c69e4a4932de0064f66a8f5530d976da1505aa556e',
      );

  String get _publicBaseUrl {
    final raw = dotenv.get(
      'R2_PUBLIC_URL',
      fallback: 'https://pub-18cf0928a89b4c3ca67bee142cc602ad.r2.dev',
    );
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  String get _s3Host => '$_accountId.r2.cloudflarestorage.com';

  /// Generates a standardized storage key for a user avatar.
  /// Format: `memorialkeeper/users/{userId}/avatar/profile_{timestamp}.{ext}`
  String generateUserAvatarKey(String userId, String extension) {
    final ext = extension.replaceAll('.', '').toLowerCase();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '$projectNamespace/users/$userId/avatar/profile_$ts.$ext';
  }

  /// Generates a standardized storage key for a memorial photo.
  /// Format: `memorialkeeper/users/{userId}/memorials/{memorialId}/{person|grave}_{timestamp}.{ext}`
  String generateMemorialPhotoKey({
    required String userId,
    required String memorialId,
    required String extension,
    bool isGrave = false,
  }) {
    final ext = extension.replaceAll('.', '').toLowerCase();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final prefix = isGrave ? 'grave' : 'person';
    return '$projectNamespace/users/$userId/memorials/$memorialId/${prefix}_$ts.$ext';
  }

  /// Extracts the R2 storage key from a full public or S3 URL.
  String? keyFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();

    // Check public URL prefix
    if (trimmed.startsWith(_publicBaseUrl)) {
      final key = trimmed.substring(_publicBaseUrl.length);
      return key.startsWith('/') ? key.substring(1) : key;
    }

    // Check S3 host path style: https://<host>/<bucket>/<key>
    final s3Prefix = 'https://$_s3Host/$_bucketName/';
    if (trimmed.startsWith(s3Prefix)) {
      return trimmed.substring(s3Prefix.length);
    }

    // If it doesn't look like an HTTP URL, assume it's already a relative storage key
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return trimmed;
    }

    return null;
  }

  /// High-level method: Uploads a user's profile avatar to R2.
  FutureEither<R2UploadResult> uploadUserProfilePhoto({
    required String userId,
    required File file,
  }) async {
    final ext = _resolveExtension(file.path);
    final key = generateUserAvatarKey(userId, ext);
    final contentType = _resolveContentType(ext);

    return uploadFile(
      key: key,
      file: file,
      contentType: contentType,
      operationName: 'uploadUserProfilePhoto',
    );
  }

  /// High-level method: Uploads a memorial photo (person or grave) to R2.
  FutureEither<R2UploadResult> uploadMemorialPhoto({
    required String userId,
    required String memorialId,
    required File file,
    bool isGrave = false,
  }) async {
    final ext = _resolveExtension(file.path);
    final key = generateMemorialPhotoKey(
      userId: userId,
      memorialId: memorialId,
      extension: ext,
      isGrave: isGrave,
    );
    final contentType = _resolveContentType(ext);

    return uploadFile(
      key: key,
      file: file,
      contentType: contentType,
      operationName: isGrave ? 'uploadGravePhoto' : 'uploadMemorialPhoto',
    );
  }

  /// Uploads a local file to R2 at the specified storage [key].
  FutureEither<R2UploadResult> uploadFile({
    required String key,
    required File file,
    String? contentType,
    String operationName = 'uploadFile',
  }) async {
    return runTask(
      () async {
        final bytes = await file.readAsBytes();
        final mime = contentType ?? _resolveContentType(_resolveExtension(file.path));
        return _performUpload(key: key, bytes: bytes, contentType: mime);
      },
      operation: 'r2.$operationName',
      category: LogCategory.backend,
      context: {'key': key, 'size': file.lengthSync()},
      requiresNetwork: true,
    );
  }

  /// Uploads raw bytes to R2 at the specified storage [key].
  FutureEither<R2UploadResult> uploadBytes({
    required String key,
    required Uint8List bytes,
    required String contentType,
    String operationName = 'uploadBytes',
  }) async {
    return runTask(
      () => _performUpload(key: key, bytes: bytes, contentType: contentType),
      operation: 'r2.$operationName',
      category: LogCategory.backend,
      context: {'key': key, 'size': bytes.length},
      requiresNetwork: true,
    );
  }

  /// Deletes an object from R2 given its storage key or full public URL.
  FutureEither<bool> deleteObject(String keyOrUrl) async {
    final key = keyFromUrl(keyOrUrl);
    if (key == null || key.isEmpty) {
      return right(true);
    }

    return runTask(
      () => _performDelete(key: key),
      operation: 'r2.deleteObject',
      category: LogCategory.backend,
      context: {'key': key},
      requiresNetwork: true,
    );
  }

  // ---------------------------------------------------------------------------
  // AWS Signature Version 4 (SigV4) Implementation
  // ---------------------------------------------------------------------------

  Future<R2UploadResult> _performUpload({
    required String key,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final host = _s3Host;
    final bucket = _bucketName;
    final encodedKey = key.split('/').map(Uri.encodeComponent).join('/');
    final canonicalUri = '/$bucket/$encodedKey';

    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDateStamp(now);
    final payloadHash = sha256.convert(bytes).toString();

    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';
    final canonicalHeaders =
        'content-type:$contentType\nhost:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';

    final canonicalRequest = [
      'PUT',
      canonicalUri,
      '', // empty query string
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _getSignatureKey(_secretAccessKey, dateStamp, 'auto', 's3');
    final signature = Hmac(sha256, signingKey)
        .convert(utf8.encode(stringToSign))
        .toString();

    final authHeader =
        'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final response = await _dio.put<void>(
      'https://$host$canonicalUri',
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Host': host,
          'x-amz-date': amzDate,
          'x-amz-content-sha256': payloadHash,
          'Authorization': authHeader,
          'Content-Length': bytes.length.toString(),
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure('R2 upload failed with status ${response.statusCode}');
    }

    final publicUrl = '$_publicBaseUrl/$key';

    return R2UploadResult(
      publicUrl: publicUrl,
      storageKey: key,
      bytesLength: bytes.length,
      contentType: contentType,
    );
  }

  Future<bool> _performDelete({required String key}) async {
    final host = _s3Host;
    final bucket = _bucketName;
    final encodedKey = key.split('/').map(Uri.encodeComponent).join('/');
    final canonicalUri = '/$bucket/$encodedKey';

    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDateStamp(now);
    final payloadHash = sha256.convert(const []).toString();

    const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';
    final canonicalHeaders =
        'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';

    final canonicalRequest = [
      'DELETE',
      canonicalUri,
      '',
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _getSignatureKey(_secretAccessKey, dateStamp, 'auto', 's3');
    final signature = Hmac(sha256, signingKey)
        .convert(utf8.encode(stringToSign))
        .toString();

    final authHeader =
        'AWS4-HMAC-SHA256 Credential=$_accessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

    final response = await _dio.delete<void>(
      'https://$host$canonicalUri',
      options: Options(
        headers: {
          'Host': host,
          'x-amz-date': amzDate,
          'x-amz-content-sha256': payloadHash,
          'Authorization': authHeader,
        },
      ),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  String _formatAmzDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }

  String _formatDateStamp(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  List<int> _hmacSha256(List<int> key, List<int> data) {
    return Hmac(sha256, key).convert(data).bytes;
  }

  List<int> _getSignatureKey(
    String key,
    String dateStamp,
    String regionName,
    String serviceName,
  ) {
    final kDate = _hmacSha256(utf8.encode('AWS4$key'), utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode(regionName));
    final kService = _hmacSha256(kRegion, utf8.encode(serviceName));
    return _hmacSha256(kService, utf8.encode('aws4_request'));
  }

  String _resolveExtension(String path) {
    final dotIdx = path.lastIndexOf('.');
    if (dotIdx != -1 && dotIdx < path.length - 1) {
      return path.substring(dotIdx + 1).toLowerCase();
    }
    return 'jpg';
  }

  String _resolveContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
