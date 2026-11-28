import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_backup_mobile.dart'
    if (dart.library.html) 'token_backup_web.dart';

/// Penyimpanan token JWT.
///
/// Mobile memakai secure storage. Bila platform web gagal menyediakan
/// penyimpanan aman (mis. konteks non-HTTPS), token disimpan di memori agar
/// aplikasi tetap dapat dipakai selama sesi berjalan.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
          );

  static const String _tokenKey = 'caku_token';
  static const String _onboardingKey = 'caku_onboarding_seen';

  final FlutterSecureStorage _storage;
  String? _memoryToken;
  bool _memoryOnboardingSeen = false;
  bool _useMemoryFallback = false;

  static const Duration _timeout = Duration(seconds: 3);

  Future<String?> read() async {
    if (_useMemoryFallback) return _memoryToken;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final token = await _storage
            .read(key: _tokenKey)
            .timeout(_timeout);
        if (token != null && token.isNotEmpty) {
          _memoryToken = token;
          return token;
        }
        final backup = await readTokenBackup();
        if (backup != null && backup.isNotEmpty) {
          _memoryToken = backup;
          return backup;
        }
        _memoryToken = token;
        return token;
      } catch (error) {
        debugPrint('TokenStorage.read attempt $attempt gagal: $error');
        if (attempt == 1) {
          _useMemoryFallback = true;
          final backup = await readTokenBackup();
          if (backup != null && backup.isNotEmpty) {
            _memoryToken = backup;
            return backup;
          }
          return _memoryToken;
        }
      }
    }
    return _memoryToken;
  }

  Future<void> write(String token) async {
    _memoryToken = token;
    if (!_useMemoryFallback) {
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          await _storage
              .write(key: _tokenKey, value: token)
              .timeout(_timeout);
          break;
        } catch (error) {
          debugPrint('TokenStorage.write attempt $attempt gagal: $error');
          if (attempt == 1) {
            _useMemoryFallback = true;
          }
        }
      }
    }
    await writeTokenBackup(token);
  }

  Future<void> clear() async {
    _memoryToken = null;
    if (!_useMemoryFallback) {
      try {
        await _storage.delete(key: _tokenKey).timeout(_timeout);
      } catch (error) {
        debugPrint('TokenStorage.clear gagal: $error');
        _useMemoryFallback = true;
      }
    }
    await deleteTokenBackup();
  }

  /// Membaca flag apakah onboarding sudah pernah dilihat.
  Future<bool> readOnboardingSeen() async {
    if (_useMemoryFallback) return _memoryOnboardingSeen;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final value = await _storage
            .read(key: _onboardingKey)
            .timeout(_timeout);
        _memoryOnboardingSeen = value == 'true';
        return _memoryOnboardingSeen;
      } catch (error) {
        debugPrint('TokenStorage.readOnboardingSeen attempt $attempt gagal: $error');
        if (attempt == 1) {
          _useMemoryFallback = true;
          return _memoryOnboardingSeen;
        }
      }
    }
    return _memoryOnboardingSeen;
  }

  /// Menandai onboarding sebagai sudah dilihat.
  Future<void> writeOnboardingSeen() async {
    _memoryOnboardingSeen = true;
    if (_useMemoryFallback) return;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _storage
            .write(key: _onboardingKey, value: 'true')
            .timeout(_timeout);
        return;
      } catch (error) {
        debugPrint('TokenStorage.writeOnboardingSeen attempt $attempt gagal: $error');
        if (attempt == 1) {
          _useMemoryFallback = true;
        }
      }
    }
  }

  /// Menghapus flag onboarding (dipakai saat logout agar onboarding tampil lagi).
  Future<void> clearOnboardingSeen() async {
    _memoryOnboardingSeen = false;
    if (_useMemoryFallback) return;
    try {
      await _storage.delete(key: _onboardingKey).timeout(_timeout);
    } catch (error) {
      debugPrint('TokenStorage.clearOnboardingSeen gagal: $error');
      _useMemoryFallback = true;
    }
  }

  @visibleForTesting
  bool get usesMemoryFallback => _useMemoryFallback;
}
