import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Safe wrappers around [FlutterSecureStorage] for Android keystore corruption.
///
/// A `BadPaddingException` / decrypt failure on read must not abort API calls
/// (e.g. login). Treat the key as empty and delete the corrupted entry.
abstract final class SecureStorageSafe {
  static Future<String?> read(
    FlutterSecureStorage storage, {
    required String key,
  }) async {
    try {
      return await storage.read(key: key);
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[SecureStorageSafe] read failed for "$key": '
          '${error.code} ${error.message}',
        );
      }
      await _deleteQuietly(storage, key);
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SecureStorageSafe] read failed for "$key": $error');
      }
      await _deleteQuietly(storage, key);
      return null;
    }
  }

  static Future<void> write(
    FlutterSecureStorage storage, {
    required String key,
    required String? value,
  }) async {
    try {
      if (value == null || value.isEmpty) {
        await storage.delete(key: key);
        return;
      }
      await storage.write(key: key, value: value);
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[SecureStorageSafe] write failed for "$key": '
          '${error.code} ${error.message}',
        );
      }
      await _deleteQuietly(storage, key);
      if (value == null || value.isEmpty) {
        return;
      }
      // One retry after clearing a corrupted keystore entry.
      await storage.write(key: key, value: value);
    }
  }

  static Future<void> delete(
    FlutterSecureStorage storage, {
    required String key,
  }) =>
      _deleteQuietly(storage, key);

  static Future<void> _deleteQuietly(
    FlutterSecureStorage storage,
    String key,
  ) async {
    try {
      await storage.delete(key: key);
    } catch (_) {}
  }
}
