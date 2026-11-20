/// Kesalahan yang berasal dari API atau jaringan.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Status HTTP, atau `null` bila kegagalan terjadi sebelum respons diterima.
  final int? statusCode;
  final String message;

  /// Pesan validasi per field, contoh `{'email': 'Format email tidak valid'}`.
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isNetworkFailure => statusCode == null;

  String? fieldError(String field) {
    if (fieldErrors.isEmpty) return null;
    if (fieldErrors.containsKey(field)) return fieldErrors[field];
    for (final entry in fieldErrors.entries) {
      if (entry.key.endsWith('.$field')) return entry.value;
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
