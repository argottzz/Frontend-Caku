import 'package:flutter/foundation.dart';

/// Konfigurasi alamat backend CAKU, satu sumber untuk seluruh aplikasi.
///
/// Prioritas penentuan base URL:
/// 1. `--dart-define=API_BASE_URL=<origin>` (boleh dengan atau tanpa `/api`).
/// 2. Build release/profile: Railway HTTPS, tidak pernah localhost.
/// 3. Build debug tanpa define: backend lokal sesuai platform.
///
/// Awalan `/api` ditambahkan otomatis sehingga layar, widget, dan service tidak
/// pernah menulis alamat backend sendiri.
abstract final class ApiConfig {
  static const String productionOrigin =
      'https://backend-caku-production.up.railway.app';

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static const String _androidDebugOrigin = 'http://10.0.2.2:8000';
  static const String _hostDebugOrigin = 'http://localhost:8000';

  /// Base URL lengkap, termasuk akhiran `/api`. 
  static String get baseUrl {
    final override = _override.trim();
    if (override.isNotEmpty) return normalize(override);

    if (!kDebugMode) return normalize(productionOrigin);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return normalize(_androidDebugOrigin);
    }

    return normalize(_hostDebugOrigin);
  }

  /// Membuang garis miring di akhir lalu menambahkan `/api` bila belum ada.
  static String normalize(String origin) {
    final trimmed = origin.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }
}
