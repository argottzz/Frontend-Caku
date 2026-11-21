import '../core/network/api_client.dart';
import '../models/json_utils.dart';
import '../models/report.dart';
import '../models/rental.dart';

class ReportService {
  ReportService(this._client);

  final ApiClient _client;

  Future<ReportData> summary({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _client.get(
      '/reports/summary',
      query: {
        'start_date': startDate == null ? null : _ymd(startDate),
        'end_date': endDate == null ? null : _ymd(endDate),
        'status': status,
        'page': '$page',
        'limit': '$limit',
      },
    );
    final data = Json.asMap(response.data);
    return ReportData(
      ringkasan: ReportSummary.fromJson(Json.asMap(data['ringkasan'])),
      rentals: Json.asMapList(
        data['rentals'],
      ).map(Rental.fromJson).toList(growable: false),
      pagination: response.pagination,
    );
  }

  static String _ymd(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
