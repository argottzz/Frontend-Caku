import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      body: {'email': email.trim().toLowerCase(), 'password': password},
      auth: false,
    );
    final token = response.token;
    if (token == null || token.isEmpty) {
      throw StateError('Token tidak diterima dari server.');
    }
    return AuthResult(user: User.fromJson(response.dataMap), token: token);
  }

  Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final response = await _client.post(
      '/auth/register',
      body: {
        'nama': nama.trim(),
        'email': email.trim().toLowerCase(),
        'phone_number': phoneNumber.trim(),
        'password': password,
      },
      auth: false,
    );
    final token = response.token;
    if (token == null || token.isEmpty) {
      throw StateError('Token tidak diterima dari server.');
    }
    return AuthResult(user: User.fromJson(response.dataMap), token: token);
  }

  Future<User> me() async {
    final response = await _client.get('/auth/me');
    return User.fromJson(response.dataMap);
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.patch(
      '/auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
    return response.message;
  }
}
