import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/screens/customer/checkout_screen.dart';
import 'package:caku_app/state/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Item _item = Item(
  id: 1,
  idKategori: 1,
  namaKategori: 'Tenda dan Shelter',
  nama: 'Tenda Dome 4P',
  deskripsi: 'Tenda kapasitas 4 orang',
  imageUrl: '',
  stok: 3,
  hargaSewaHarian: 50000,
  dendaHarian: 10000,
);

void main() {
  testWidgets('checkout menolak pengajuan tanpa tanggal dan bukti', (
    tester,
  ) async {
    final services = AppServices.create();
    services.cart.add(_item);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppScope(
          services: services,
          child: CartScope(
            controller: services.cart,
            child: CheckoutScreen(onRentalCreated: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Info Penyewa & Periode'), findsOneWidget);
    expect(find.text('Tenda Dome 4P'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsWidgets);

    await tester.tap(find.text('Buat Pesanan'));
    await tester.pump();

    expect(find.text('Pilih tanggal mulai sewa.'), findsOneWidget);
    expect(find.text('Bukti transfer wajib diunggah.'), findsOneWidget);
    expect(services.cart.isEmpty, isFalse);
  });
}
