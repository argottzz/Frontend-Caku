import 'package:caku_app/widgets/app_snack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(VoidCallback onAction) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => AppSnack.success(
            context,
            'Tenda Dome 4P ditambahkan ke keranjang.',
            actionLabel: 'Lihat',
            onAction: onAction,
          ),
          child: const Text('Tambah'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('snack bar dengan aksi tetap hilang otomatis', (tester) async {
    await tester.pumpWidget(_app(() {}));

    await tester.tap(find.text('Tambah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('Tenda Dome 4P ditambahkan ke keranjang.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Tenda Dome 4P ditambahkan ke keranjang.'), findsNothing);
  });

  testWidgets('aksi Lihat dijalankan lalu snack bar langsung ditutup', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(_app(() => pressed++));

    await tester.tap(find.text('Tambah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Lihat'));
    await tester.pumpAndSettle();

    expect(pressed, 1);
    expect(find.text('Tenda Dome 4P ditambahkan ke keranjang.'), findsNothing);
  });

  testWidgets('snack bar tetap ditutup walau aksi melempar', (tester) async {
    await tester.pumpWidget(_app(() => throw StateError('unmounted')));

    await tester.tap(find.text('Tambah'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Lihat'));
    await tester.pump();
    expect(tester.takeException(), isNotNull);

    await tester.pumpAndSettle();

    expect(find.text('Tenda Dome 4P ditambahkan ke keranjang.'), findsNothing);
  });
}
