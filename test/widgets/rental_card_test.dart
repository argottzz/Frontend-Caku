import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/rental.dart';
import 'package:caku_app/widgets/rental_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Rental sampleRental({RentalStatus status = RentalStatus.pending}) {
  return Rental(
    id: 12,
    idUser: 2,
    namaUser: 'Customer Caku',
    emailUser: 'customer@caku.test',
    tanggalMulai: DateTime(2026, 12, 10),
    tanggalSelesai: DateTime(2026, 12, 12),
    tanggalKembaliAktual: null,
    durasiHari: 3,
    buktiTransferUrl: 'https://res.cloudinary.com/demo/image/upload/bukti.jpg',
    status: status,
    kondisiPengembalian: null,
    catatanPengembalian: null,
    jumlahItem: 2,
    totalSewa: 300000,
    hariTerlambat: 0,
    totalDenda: 0,
    totalBayar: 300000,
    createdAt: DateTime(2026, 12, 1),
    items: const [],
  );
}

void main() {
  testWidgets('kartu rental menampilkan pesanan, tanggal, dan total', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: RentalCard(rental: sampleRental(), onTap: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Pesanan #12'), findsOneWidget);
    expect(find.textContaining('2 jenis barang'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Rp 300.000'), findsOneWidget);
    expect(find.textContaining('customer@caku.test'), findsNothing);
  });

  testWidgets('kartu rental admin menampilkan identitas penyewa', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: RentalCard(
              rental: sampleRental(status: RentalStatus.ongoing),
              showCustomer: true,
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('customer@caku.test'), findsOneWidget);
    expect(find.text('Berjalan'), findsOneWidget);
  });
}
