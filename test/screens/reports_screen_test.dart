import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/rental.dart';
import 'package:caku_app/models/report.dart';
import 'package:caku_app/screens/admin/reports_screen.dart';
import 'package:caku_app/core/network/api_client.dart';
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

Rental _rental({int id = 5, RentalStatus status = RentalStatus.ongoing}) {
  return Rental(
    id: id,
    idUser: 2,
    namaUser: 'Customer Caku',
    emailUser: 'customer@caku.test',
    tanggalMulai: DateTime(2026, 11, 24),
    tanggalSelesai: DateTime(2026, 11, 24),
    tanggalKembaliAktual: null,
    durasiHari: 1,
    buktiTransferUrl: '',
    status: status,
    kondisiPengembalian: null,
    catatanPengembalian: null,
    jumlahItem: 1,
    totalSewa: 25000,
    hariTerlambat: 0,
    totalDenda: 0,
    totalBayar: 25000,
    createdAt: DateTime(2026, 11, 20),
    items: const [],
  );
}

Widget wrap(Widget child, {double width = 400}) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Future<ReportData> Function({
  DateTime? startDate,
  DateTime? endDate,
  String? status,
  int page,
  int limit,
})
_loader(ReportData data) {
  return ({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int page = 1,
    int limit = 10,
  }) async => data;
}

void main() {
  testWidgets('laporan menampilkan ringkasan dan keadaan kosong', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ReportsTab(loadReports: _loader(const ReportData(ringkasan: _summary))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Filter laporan'), findsOneWidget);
    expect(find.text('Ringkasan laporan'), findsOneWidget);
    expect(find.text('Ekspor PDF'), findsOneWidget);
    expect(find.text('Rp 316.000'), findsOneWidget);
    expect(find.text('Tidak ada transaksi'), findsOneWidget);
    // Reset hanya muncul setelah filter tanggal aktif.
    expect(find.text('Reset'), findsNothing);
  });

  testWidgets('laporan memadatkan kartu hasil tanpa identitas penyewa', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ReportsTab(
          loadReports: _loader(
            ReportData(
              ringkasan: _summary,
              rentals: [_rental()],
              pagination: const Pagination(
                page: 1,
                limit: 10,
                total: 10,
                totalPages: 1,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pesanan #5'), findsOneWidget);
    expect(find.textContaining('1 jenis barang'), findsOneWidget);
    expect(find.text('Total bayar: Rp 25.000'), findsOneWidget);
    expect(find.textContaining('customer@caku.test'), findsNothing);
    expect(find.text('1 dari 10 transaksi'), findsOneWidget);
  });

  testWidgets('filter tanggal memunculkan tombol Reset', (tester) async {
    await tester.pumpWidget(
      wrap(
        ReportsTab(loadReports: _loader(const ReportData(ringkasan: _summary))),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dari tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('laporan tidak meluap pada layar sempit 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ReportsTab(
            loadReports: _loader(
              ReportData(ringkasan: _summary, rentals: [_rental()]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('laporan menampilkan galat dan tombol coba lagi', (tester) async {
    await tester.pumpWidget(
      wrap(
        ReportsTab(
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
