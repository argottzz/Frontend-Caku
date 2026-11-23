import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/report.dart';
import 'package:caku_app/screens/admin/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _summary = ReportSummary(
  totalTransaksi: 10,
  pending: 2,
  approved: 1,
  ongoing: 3,
  completed: 4,
  rejected: 0,
  totalSewa: 300000,
  totalDenda: 16000,
  totalPendapatan: 316000,
);

void main() {
  testWidgets('laporan menampilkan ringkasan dan keadaan kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ReportsScreen(
          loadReports:
              ({
                DateTime? startDate,
                DateTime? endDate,
                String? status,
                int page = 1,
                int limit = 10,
              }) async => const ReportData(ringkasan: _summary),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Laporan Pendapatan'), findsOneWidget);
    expect(find.text('Ringkasan laporan'), findsOneWidget);
    expect(find.text('Rp 316.000'), findsOneWidget);
    expect(find.text('Tidak ada transaksi'), findsOneWidget);
  });

  testWidgets('laporan menampilkan galat dan tombol coba lagi', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ReportsScreen(
          loadReports:
              ({
                DateTime? startDate,
                DateTime? endDate,
                String? status,
                int page = 1,
                int limit = 10,
              }) async => throw ApiException(message: 'Server sedang sibuk.'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server sedang sibuk.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
