import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/item.dart';
import 'package:caku_app/screens/customer/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Item _item(int id) {
  return Item(
    id: id,
    idKategori: 1,
    namaKategori: 'Tenda dan Shelter',
    nama: 'Tenda Dome 4P Kapasitas Empat Orang',
    deskripsi: 'Tenda kapasitas 4 orang',
    imageUrl: '',
    stok: 3,
    hargaSewaHarian: 50000,
    dendaHarian: 10000,
  );
}

/// Grid dengan lebar area tertentu, seperti yang dipakai Beranda/Katalog.
Widget _grid(double width, {double textScale = 1.0}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SizedBox(
          width: width,
          child: ItemGrid(
            itemCount: 4,
            itemBuilder: (_, index) =>
                ItemCard(item: _item(index + 1), onTap: () {}),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Kartu produk dulu memakai mainAxisExtent tetap 292 px. Karena foto memakai
  // AspectRatio 4:3, kartu pada layar lebar kehabisan ruang teks dan overflow
  // (terukur 65 px pada 600 px dan 88 px pada 1024 px). Test ini menjaga agar
  // delegate tetap menghitung tinggi dari lebar kolom.
  for (final width in <double>[320, 360, 412, 600, 768, 1024, 1440]) {
    testWidgets('kartu produk tidak overflow pada lebar ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_grid(width));
       await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kartu produk tidak overflow saat teks diperbesar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_grid(360, textScale: 1.6));
     await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  test('ponsel memakai dua kolom', () {
    final delegate = itemGridDelegateFor(360);
    expect(delegate.crossAxisCount, 2);
  });

  test('layar lebar menambah kolom, bukan melebarkan kartu', () {
    final delegate = itemGridDelegateFor(1024);
    expect(delegate.crossAxisCount, greaterThan(2));
    // Lebar kartu dijaga di sekitar target agar tidak melebar berlebihan.
    expect(delegate.mainAxisExtent, lessThan(400));
  });
}
