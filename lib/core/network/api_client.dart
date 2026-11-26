import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_exception.dart';

/// Satu file yang akan dikirim sebagai multipart.
class FileUpload {
  const FileUpload({
    required this.filename,
    required this.bytes,
    required this.mimeType,
  });

  final String filename;
  final Uint8List bytes;
  final String mimeType;
}

class Pagination {
  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNext => page < totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 10,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 1,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }
}

class ApiResponse {
  const ApiResponse({
    required this.message,
    this.data,
    this.token,
    this.pagination,
  });

  final String message;
  final dynamic data;
  final String? token;
  final Pagination? pagination;

  Map<String, dynamic> get dataMap =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : const {};

  List<Map<String, dynamic>> get dataList {
    if (data is! List) return const [];
    return (data as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}

/// Klien HTTP tunggal untuk seluruh aplikasi.
class ApiClient {
  ApiClient({required this.baseUrl, this.onUnauthorized});

  /// Dipanggil saat request bertoken menerima `401`.
  final Future<void> Function()? onUnauthorized;

  static const Duration _timeout = Duration(seconds: 20);
  static const Duration _uploadTimeout = Duration(seconds: 60);

  String baseUrl;
  String? token;

  bool get hasToken => token != null && token!.isNotEmpty;

  Map<String, String> _headers({bool json = true, bool auth = true}) {
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (auth && hasToken) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String?>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) params[key] = value;
    });
    return Uri.parse(
      '$baseUrl$normalized',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<ApiResponse> get(
    String path, {
    Map<String, String?>? query,
    bool auth = true,
  }) {
    return _execute(
      () => http.get(_uri(path, query), headers: _headers(auth: auth)),
      auth: auth,
    );
  }

  Future<ApiResponse> post(String path, {Object? body, bool auth = true}) {
    return _execute(
      () => http.post(
        _uri(path),
        headers: _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      auth: auth,
    );
  }

  Future<ApiResponse> put(String path, {Object? body, bool auth = true}) {
    return _execute(
      () => http.put(
        _uri(path),
        headers: _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      auth: auth,
    );
  }

  Future<ApiResponse> patch(String path, {Object? body, bool auth = true}) {
    return _execute(
      () => http.patch(
        _uri(path),
        headers: _headers(auth: auth),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
      auth: auth,
    );
  }

  Future<ApiResponse> delete(String path, {bool auth = true}) {
    return _execute(
      () => http.delete(_uri(path), headers: _headers(auth: auth)),
      auth: auth,
    );
  }

  /// POST multipart. Field teks dikirim sebagai string.
  Future<ApiResponse> postMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, FileUpload> files = const {},
  }) {
    return _executeMultipart(
      path,
      fields: fields,
      files: files,
      method: 'POST',
    );
  }

  /// PUT multipart untuk pembaruan penuh data barang.
  Future<ApiResponse> putMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, FileUpload> files = const {},
  }) {
    return _executeMultipart(path, fields: fields, files: files, method: 'PUT');
  }

  /// PATCH multipart, dipakai untuk pembaruan sebagian (mis. foto profil).
  Future<ApiResponse> patchMultipart(
    String path, {
    required Map<String, String> fields,
    Map<String, FileUpload> files = const {},
  }) {
    return _executeMultipart(path, fields: fields, files: files, method: 'PATCH');
  }

  Future<ApiResponse> _executeMultipart(
    String path, {
    required Map<String, String> fields,
    required Map<String, FileUpload> files,
    required String method,
  }) async {
    if (!hasToken) {
      throw ApiException(
        message: 'Sesi Anda berakhir. Silakan masuk kembali.',
        statusCode: 401,
      );
    }

    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(_headers(json: false));
    request.fields.addAll(fields);
    for (final entry in files.entries) {
      request.files.add(
        http.MultipartFile.fromBytes(
          entry.key,
          entry.value.bytes,
          filename: entry.value.filename,
          contentType: MediaType.parse(entry.value.mimeType),
        ),
      );
    }

    try {
      final streamed = await request.send().timeout(_uploadTimeout);
      final response = await http.Response.fromStream(streamed);
      return _parse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      debugPrint('API multipart error: $error');
      throw ApiException(
        message:
            'Tidak dapat menghubungi server. Periksa koneksi Anda lalu coba lagi.',
      );
    }
  }

  Future<ApiResponse> _execute(
    Future<http.Response> Function() request, {
    required bool auth,
  }) async {
    try {
      final response = await request().timeout(_timeout);
      return await _parse(response, authenticatedRequest: auth);
    } on ApiException {
      rethrow;
    } catch (error) {
      debugPrint('API error: $error');
      throw ApiException(
        message:
            'Tidak dapat menghubungi server. Periksa koneksi Anda lalu coba lagi.',
      );
    }
  }

  Future<ApiResponse> _parse(
    http.Response response, {
    bool authenticatedRequest = true,
  }) async {
    final body = utf8.decode(response.bodyBytes);
    dynamic decoded;
    if (body.trim().isEmpty) {
      decoded = const <String, dynamic>{};
    } else {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = const <String, dynamic>{};
      }
    }

    final json = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        message: (json['message'] as String?)?.trim() ?? '',
        data: json['data'],
        token: json['token'] as String?,
        pagination: json['pagination'] is Map<String, dynamic>
            ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
            : null,
      );
    }

    if (response.statusCode == 401 && authenticatedRequest && hasToken) {
      await onUnauthorized?.call();
    }

    final fieldErrors = <String, String>{};
    final rawErrors = json['error'];
    if (rawErrors is List) {
      for (final entry in rawErrors) {
        if (entry is! Map) continue;
        final path = entry['path'];
        final key = path is List
            ? path.map((part) => '$part').join('.')
            : '${path ?? ''}';
        final message = '${entry['message'] ?? ''}';
        if (key.isNotEmpty && message.isNotEmpty) {
          fieldErrors[key] = message;
        }
      }
    }

    final message = (json['message'] as String?)?.trim();
    throw ApiException(
      statusCode: response.statusCode,
      message: message == null || message.isEmpty
          ? _fallbackMessage(response.statusCode)
          : message,
      fieldErrors: fieldErrors,
    );
  }

  String _fallbackMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Data yang dikirim tidak valid.',
      401 => 'Sesi Anda berakhir. Silakan masuk kembali.',
      403 => 'Anda tidak memiliki akses untuk tindakan ini.',
      404 => 'Data tidak ditemukan.',
      409 => 'Tindakan tidak dapat dilakukan saat ini.',
      429 => 'Terlalu banyak percobaan. Coba lagi nanti.',
      >= 500 => 'Terjadi kesalahan pada server. Coba lagi.',
      _ => 'Permintaan gagal (kode $statusCode).',
    };
  }
}
