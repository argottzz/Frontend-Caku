import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/report.dart';
import 'package:caku_app/screens/admin/dashboard_screen.dart';
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
  testWidgets('dashboard menampilkan ringkasan dan status transaksi', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          loadReport: () async => const ReportData(ringkasan: _summary),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Rp 316.000'), findsWidgets);
    expect(find.text('10 transaksi'), findsOneWidget);
    expect(find.text('Menunggu'), findsWidgets);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.text('Lihat semua'), findsOneWidget);
  });

  testWidgets('dashboard menampilkan galat dan tombol coba lagi', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          loadReport: () async =>
              throw ApiException(message: 'Server sedang sibuk.'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server sedang sibuk.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('tab Laporan membuka rekap tanpa memuat ringkasan lagi', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          loadReport: () async => const ReportData(ringkasan: _summary),
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

    // Tab laporan belum dibangun sebelum dibuka.
    expect(find.text('Ringkasan laporan'), findsNothing);

    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan laporan'), findsOneWidget);
    expect(find.text('Filter laporan'), findsOneWidget);
    expect(find.text('Tidak ada transaksi'), findsOneWidget);
  });

  testWidgets('tab Laporan dapat dibuka langsung lewat initialTab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          initialTab: 1,
          loadReport: () async => const ReportData(ringkasan: _summary),
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

    expect(find.text('Filter laporan'), findsOneWidget);
    expect(find.text('Server sedang sibuk.'), findsOneWidget);
  });
}
