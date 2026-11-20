import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Konfigurasi alamat backend CAKU.
///
/// Prioritas:
/// 1. `--dart-define=API_URL=http://host:8000/api`
/// 2. Web/desktop: `http://localhost:8000/api`
/// 3. Android: probe `10.0.2.2` (emulator) lalu `127.0.0.1` (adb reverse).
abstract final class ApiConfig {
  static const String _override = String.fromEnvironment('API_URL');

  static const String webBaseUrl = 'http://localhost:8000/api';
  static const List<String> androidCandidates = [
    'http://10.0.2.2:8000/api',
    'http://127.0.0.1:8000/api',
  ];

  /// Base URL awal sebelum probe selesai.
  static String get initialBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return webBaseUrl;
    return androidCandidates.first;
  }

  /// Menentukan base URL yang benar-benar dapat dijangkau.
  ///
  /// Endpoint `/categories` bersifat privat sehingga balasan `401` tetap
  /// menandakan server hidup; yang diperiksa hanya keterjangkauan.
  static Future<String> resolve() async {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return webBaseUrl;

    for (final candidate in androidCandidates) {
      if (await _isReachable(candidate)) return candidate;
    }
    return androidCandidates.first;
  }

  static Future<bool> _isReachable(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/categories'))
          .timeout(const Duration(milliseconds: 1800));
      return response.statusCode > 0;
    } catch (_) {
      return false;
    }
  }
}
