import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<String?> read() async {
    if (_useMemoryFallback) return _memoryToken;
    try {
      final token = await _storage
          .read(key: _tokenKey)
          .timeout(const Duration(milliseconds: 500));
      _memoryToken = token;
      return token;
    } catch (error) {
      debugPrint('TokenStorage.read fallback ke memori: $error');
      _useMemoryFallback = true;
      return _memoryToken;
    }
  }

  Future<void> write(String token) async {
    _memoryToken = token;
    if (_useMemoryFallback) return;
    try {
      await _storage
          .write(key: _tokenKey, value: token)
          .timeout(const Duration(milliseconds: 500));
    } catch (error) {
      debugPrint('TokenStorage.write fallback ke memori: $error');
      _useMemoryFallback = true;
    }
  }

  Future<void> clear() async {
    _memoryToken = null;
    if (_useMemoryFallback) return;
    try {
      await _storage
          .delete(key: _tokenKey)
          .timeout(const Duration(milliseconds: 500));
    } catch (error) {
      debugPrint('TokenStorage.clear fallback ke memori: $error');
      _useMemoryFallback = true;
    }
  }

  /// Membaca flag apakah onboarding sudah pernah dilihat.
  Future<bool> readOnboardingSeen() async {
    if (_useMemoryFallback) return _memoryOnboardingSeen;
    try {
      final value = await _storage
          .read(key: _onboardingKey)
          .timeout(const Duration(milliseconds: 500));
      _memoryOnboardingSeen = value == 'true';
      return _memoryOnboardingSeen;
    } catch (error) {
      debugPrint('TokenStorage.readOnboardingSeen fallback ke memori: $error');
      _useMemoryFallback = true;
      return _memoryOnboardingSeen;
    }
  }

  /// Menandai onboarding sebagai sudah dilihat.
  Future<void> writeOnboardingSeen() async {
    _memoryOnboardingSeen = true;
    if (_useMemoryFallback) return;
    try {
      await _storage
          .write(key: _onboardingKey, value: 'true')
          .timeout(const Duration(milliseconds: 500));
    } catch (error) {
      debugPrint('TokenStorage.writeOnboardingSeen fallback ke memori: $error');
      _useMemoryFallback = true;
    }
  }

  @visibleForTesting
  bool get usesMemoryFallback => _useMemoryFallback;
}
