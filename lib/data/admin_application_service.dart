import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';

/// Layanan pengajuan menjadi admin. Endpoint backend:
/// POST /admin-applications, GET /admin-applications/me,
/// GET /admin-applications, GET /admin-applications/:id,
/// PATCH /admin-applications/:id/approve, PATCH /admin-applications/:id/reject
class AdminApplicationService {
  AdminApplicationService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>?> myApplication() async {
    try {
      final response = await _client.get('/admin-applications/me');
      return response.dataMap;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> apply() async {
    await _client.post('/admin-applications');
  }

  Future<List<Map<String, dynamic>>> list({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/admin-applications',
      query: {'status': status, 'page': '$page', 'limit': '$limit'},
    );
    return response.dataList;
  }

  /// Jumlah pengajuan yang masih menunggu ditinjau, untuk lencana dashboard.
  Future<int> pendingCount() async {
    final response = await _client.get(
      '/admin-applications',
      query: {'status': 'pending', 'page': '1', 'limit': '1'},
    );
    return response.pagination?.total ?? response.dataList.length;
  }

  Future<Map<String, dynamic>> detail(int id) async {
    final response = await _client.get('/admin-applications/$id');
    return response.dataMap;
  }

  Future<void> approve(int id) async {
    await _client.patch('/admin-applications/$id/approve');
  }

  Future<void> reject(int id, String reason) async {
    await _client.patch(
      '/admin-applications/$id/reject',
      body: {'admin_rejection_reason': reason},
    );
  }
}

/// Status pengajuan admin yang dikembalikan backend.
String applicationStatus(Map<String, dynamic>? data) {
  if (data == null) return 'none';
  return (data['admin_application_status'] as String?) ?? 'none';
}
