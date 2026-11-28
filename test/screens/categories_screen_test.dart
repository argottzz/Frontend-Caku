import 'package:caku_app/core/network/api_exception.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/category.dart';
import 'package:caku_app/screens/admin/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _categories = [
  Category(id: 1, nama: 'Tenda dan Shelter'),
  Category(id: 2, nama: 'Perlengkapan Tidur'),
];

Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

void main() {
  testWidgets('manajemen kategori menampilkan daftar dari API', (tester) async {
    await tester.pumpWidget(
      wrap(CategoriesScreen(loadCategories: () async => _categories)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manajemen Kategori'), findsOneWidget);
    expect(find.text('Tenda dan Shelter'), findsOneWidget);
    expect(find.text('Perlengkapan Tidur'), findsOneWidget);
    expect(find.text('2 kategori tersedia'), findsOneWidget);
    expect(find.text('Tambah kategori'), findsOneWidget);
    expect(find.byTooltip('Ubah kategori'), findsNWidgets(2));
    expect(find.byTooltip('Hapus kategori'), findsNWidgets(2));
  });

  testWidgets('manajemen kategori menampilkan empty state', (tester) async {
    await tester.pumpWidget(
      wrap(CategoriesScreen(loadCategories: () async => const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kategori'), findsOneWidget);
    expect(
      find.text('Tambahkan kategori pertama agar barang dapat dikelompokkan.'),
      findsOneWidget,
    );
  });

  testWidgets('manajemen kategori menampilkan error state dan coba lagi', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CategoriesScreen(
          loadCategories: () async =>
              throw ApiException(message: 'Server sedang sibuk.'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server sedang sibuk.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('dialog tambah kategori menolak nama kosong', (tester) async {
    await tester.pumpWidget(
      wrap(CategoriesScreen(loadCategories: () async => _categories)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah kategori'));
    await tester.pumpAndSettle();

    expect(find.text('Nama kategori'), findsOneWidget);

    await tester.tap(find.text('Tambah').last);
    await tester.pumpAndSettle();

    expect(find.text('Nama kategori wajib diisi.'), findsOneWidget);
  });

  testWidgets('dialog ubah kategori menampilkan nama saat ini', (tester) async {
    await tester.pumpWidget(
      wrap(CategoriesScreen(loadCategories: () async => _categories)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ubah kategori').first);
    await tester.pumpAndSettle();

    expect(find.text('Ubah nama kategori'), findsOneWidget);

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, 'Tenda dan Shelter');
  });

  testWidgets('manajemen kategori tidak meluap pada layar sempit 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        CategoriesScreen(
          loadCategories: () async => const [
            Category(
              id: 1,
              nama: 'Peralatan Masak dan Makan Perlengkapan Camping Panjang',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('Category membaca id_kategori dan nama dari respons backend', () {
    final category = Category.fromJson({
      'id_kategori': 3,
      'nama': 'Penerangan dan Listrik',
    });

    expect(category.id, 3);
    expect(category.nama, 'Penerangan dan Listrik');
  });
}
