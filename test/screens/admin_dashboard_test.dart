import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/rental.dart';
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

Rental _rental(int id) {
  return Rental(
    id: id,
    idUser: 2,
    namaUser: 'Arga Zanuar',
    emailUser: 'arga@caku.test',
    tanggalMulai: DateTime(2026, 11, 22),
    tanggalSelesai: DateTime(2026, 11, 24),
    tanggalKembaliAktual: null,
    durasiHari: 3,
    buktiTransferUrl: '',
    status: RentalStatus.completed,
    kondisiPengembalian: null,
    catatanPengembalian: null,
    jumlahItem: 3,
    totalSewa: 374000,
    hariTerlambat: 0,
    totalDenda: 0,
    totalBayar: 374000,
    createdAt: DateTime(2026, 11, 20),
    items: const [],
  );
}

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
    expect(find.textContaining('Mencakup transaksi'), findsOneWidget);
    expect(find.text('Aksi Cepat'), findsOneWidget);
    expect(find.text('Tambah Barang'), findsOneWidget);
    expect(find.text('Permohonan Admin'), findsOneWidget);
    expect(find.text('Ringkasan Operasional'), findsOneWidget);
    expect(find.text('Menunggu'), findsWidgets);
    expect(find.text('Total Barang'), findsOneWidget);
    expect(find.text('Transaksi Aktif & Terbaru'), findsOneWidget);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.text('Lihat semua'), findsOneWidget);
  });

  testWidgets('dashboard membatasi daftar transaksi terbaru jadi dua', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          loadReport: () async => ReportData(
            ringkasan: _summary,
            rentals: [_rental(5), _rental(4), _rental(3)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pesanan #5'), findsOneWidget);
    expect(find.text('Pesanan #4'), findsOneWidget);
    expect(find.text('Pesanan #3'), findsNothing);
    expect(find.text('Lihat semua'), findsOneWidget);
  });

  testWidgets('dashboard tidak meluap pada layar sempit 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminDashboardScreen(
          loadReport: () async =>
              ReportData(ringkasan: _summary, rentals: [_rental(5)]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
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
