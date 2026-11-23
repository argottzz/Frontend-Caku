import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/screens/customer/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Item sampleItem({int stock = 3}) {
  return Item(
    id: 1,
    idKategori: 1,
    namaKategori: 'Tenda dan Shelter',
    nama: 'Tenda Dome 4P',
    deskripsi: 'Tenda kapasitas 4 orang',
    imageUrl: '',
    stok: stock,
    hargaSewaHarian: 50000,
    dendaHarian: 10000,
  );
}

void main() {
  testWidgets('kartu barang menampilkan harga dan kategori', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ItemCard(
              item: sampleItem(),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tenda Dome 4P'), findsOneWidget);
    expect(find.text('Rp 50.000/hari'), findsOneWidget);
    expect(find.text('Tenda dan Shelter'.toUpperCase()), findsOneWidget);
  });

  testWidgets('kartu barang menampilkan stok habis saat stok 0', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ItemCard(
              item: sampleItem(stock: 0),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Stok habis'), findsOneWidget);
  });
}
