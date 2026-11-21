import '../core/network/api_client.dart';
import 'json_utils.dart';
import 'rental.dart';

class ReportSummary {
  const ReportSummary({
    required this.totalTransaksi,
    required this.pending,
    required this.approved,
    required this.ongoing,
    required this.completed,
    required this.rejected,
    required this.totalSewa,
    required this.totalDenda,
    required this.totalPendapatan,
  });

  final int totalTransaksi;
  final int pending;
  final int approved;
  final int ongoing;
  final int completed;
  final int rejected;
  final double totalSewa;
  final double totalDenda;
  final double totalPendapatan;

  static const ReportSummary empty = ReportSummary(
    totalTransaksi: 0,
    pending: 0,
    approved: 0,
    ongoing: 0,
    completed: 0,
    rejected: 0,
    totalSewa: 0,
    totalDenda: 0,
    totalPendapatan: 0,
  );

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      totalTransaksi: Json.asInt(json['total_transaksi']),
      pending: Json.asInt(json['transaksi_pending']),
      approved: Json.asInt(json['transaksi_approved']),
      ongoing: Json.asInt(json['transaksi_ongoing']),
      completed: Json.asInt(json['transaksi_completed']),
      rejected: Json.asInt(json['transaksi_rejected']),
      totalSewa: double.tryParse(Json.asString(json['total_sewa'], '0')) ?? 0,
      totalDenda: double.tryParse(Json.asString(json['total_denda'], '0')) ?? 0,
      totalPendapatan:
          double.tryParse(Json.asString(json['total_pendapatan'], '0')) ?? 0,
    );
  }
}

class ReportData {
  const ReportData({
    required this.ringkasan,
    this.rentals = const [],
    this.pagination,
  });

  final ReportSummary ringkasan;
  final List<Rental> rentals;
  final Pagination? pagination;

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      ringkasan: ReportSummary.fromJson(Json.asMap(json['ringkasan'])),
      rentals: Json.asMapList(
        json['rentals'],
      ).map(Rental.fromJson).toList(growable: false),
      pagination: json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}
