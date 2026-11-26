import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/screens/customer/item_detail_screen.dart';
import 'package:caku_app/state/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = Item(
  id: 1,
  idKategori: 1,
  namaKategori: 'Tenda dan Shelter',
  nama: 'Tenda Dome 4P',
  deskripsi: 'Tenda kapasitas 4 orang',
  imageUrl: '',
  stok: 3,
  hargaSewaHarian: 50000,
  dendaHarian: 10000,
  originalPrice: 500000,
);

Widget _app() {
  final services = AppServices.create();
  return AppScope(
    services: services,
    child: CartScope(
      controller: services.cart,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ItemDetailScreen(initialItem: _item),
                  ),
                ),
                child: const Text('Buka detail'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openDetail(WidgetTester tester) async {
  await tester.pumpWidget(_app());
  await tester.tap(find.text('Buka detail'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _addToCart(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Tambahkan ke Keranjang'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('aksi Lihat membuka keranjang', (tester) async {
    await _openDetail(tester);
    await _addToCart(tester);

    expect(
      find.text('1 Tenda Dome 4P ditambahkan ke keranjang.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Lihat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Keranjang'), findsOneWidget);
  });

  testWidgets('aksi Lihat tetap bekerja setelah layar detail ditutup', (
    tester,
  ) async {
    await _openDetail(tester);
    await _addToCart(tester);

    // Kembali ke layar sebelumnya; snack bar tetap tampil karena berada di
    // ScaffoldMessenger akar.
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();

    expect(
      find.text('1 Tenda Dome 4P ditambahkan ke keranjang.'),
      findsOneWidget,
    );

    // Panggil aksi seperti saat tombol "Lihat" ditekan. Layar detail sudah
    // dilepas, jadi aksi tidak boleh memakai context milik State-nya lagi.
    tester.widget<SnackBarAction>(find.byType(SnackBarAction)).onPressed();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Keranjang'), findsOneWidget);
  });
}
