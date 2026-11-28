import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../data/auth_service.dart';
import '../models/user.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  AuthController({required ApiClient client, required this.storage})
    : _client = client,
      _service = AuthService(client);

  final ApiClient _client;
  final TokenStorage storage;
  final AuthService _service;

  AuthStatus _status = AuthStatus.initializing;
  User? _user;
  bool _sessionExpired = false;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get sessionExpired => _sessionExpired;

  Future<void> initialize() async {
    final token = await storage.read();
    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _client.token = token;
    try {
      _user = await _service.me();
      _status = AuthStatus.authenticated;
    } on ApiException catch (error) {
      // Token kedaluwarsa atau pengguna sudah tidak ada.
      if (error.isUnauthorized || error.isForbidden) {
        await storage.clear();
        _client.token = null;
      }
      _status = AuthStatus.unauthenticated;
    } catch (error) {
      debugPrint('Gagal memulihkan sesi: $error');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<User> login({required String email, required String password}) async {
    final result = await _service.login(email: email, password: password);
    await _applySession(result);
    return result.user;
  }

  Future<User> register({
    required String nama,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final result = await _service.register(
      nama: nama,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    await _applySession(result);
    return result.user;
  }

  /// Menyegarkan data pengguna, mis. setelah role berubah.
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    try {
      _user = await _service.me();
      notifyListeners();
    } on ApiException {
      // Abaikan: sesi akan ditangani oleh pemanggil bila perlu.
    }
  }

  /// Memperbarui data user dari response backend (mis. setelah upload foto profil).
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _sessionExpired = false;
    _user = null;
    _status = AuthStatus.unauthenticated;
    _client.token = null;
    await storage.clear();
    await storage.clearOnboardingSeen();
    notifyListeners();
  }

  /// Dipanggil otomatis oleh [ApiClient] saat menerima `401`.
  Future<void> handleUnauthorized() async {
    if (_status == AuthStatus.unauthenticated) return;
    _sessionExpired = true;
    _user = null;
    _status = AuthStatus.unauthenticated;
    _client.token = null;
    await storage.clear();
    notifyListeners();
  }

  Future<void> _applySession(AuthResult result) async {
    _client.token = result.token;
    await storage.write(result.token);
    _user = result.user;
    _status = AuthStatus.authenticated;
    _sessionExpired = false;
    notifyListeners();
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return _service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
