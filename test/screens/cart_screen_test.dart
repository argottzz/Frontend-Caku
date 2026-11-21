import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/screens/customer/cart_screen.dart';
import 'package:caku_app/state/app_scope.dart';
import 'package:caku_app/state/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Item sampleItem() {
  return const Item(
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
}

Widget wrapCart(CartController cart, {VoidCallback? onBrowse}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: CartScope(
      controller: cart,
      child: CartScreen(onBrowse: onBrowse),
    ),
  );
}

void main() {
  testWidgets('keranjang kosong menampilkan ajakan ke katalog', (tester) async {
    var browsed = 0;
    await tester.pumpWidget(
      wrapCart(CartController(), onBrowse: () => browsed++),
    );

    expect(find.text('Keranjang masih kosong'), findsOneWidget);
    expect(find.text('Checkout'), findsNothing);

    await tester.tap(find.text('Jelajahi katalog'));
    await tester.pump();

    expect(browsed, 1);
  });

  testWidgets('keranjang menampilkan subtotal dan menghapus barang', (
    tester,
  ) async {
    final cart = CartController()..add(sampleItem());
    await tester.pumpWidget(wrapCart(cart));

    expect(find.text('Tenda Dome 4P'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsWidgets);
    expect(find.text('Rp 50.000/hari'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah jumlah Tenda Dome 4P'));
    await tester.pump();

    expect(cart.quantityFor(1), 2);
    expect(find.text('Rp 100.000'), findsWidgets);

    await tester.tap(find.byTooltip('Hapus dari keranjang'));
    await tester.pump();

    expect(cart.isEmpty, isTrue);
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
  });
}
