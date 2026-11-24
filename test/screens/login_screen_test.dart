import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/screens/auth/login_screen.dart';
import 'package:caku_app/screens/auth/register_screen.dart';
import 'package:caku_app/state/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final services = AppServices.create();
  return AppScope(
    services: services,
    child: AuthScope(
      controller: services.auth,
      child: CartScope(
        controller: services.cart,
        child: MaterialApp(theme: AppTheme.light, home: child),
      ),
    ),
  );
}

void main() {
  testWidgets('layar masuk menampilkan isian dan tautan daftar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    expect(find.text('Masuk ke CAKU'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    // Login adalah halaman pertama, jadi tidak ada tombol kembali.
    expect(find.widgetWithText(TextButton, 'Kembali'), findsNothing);
  });

  testWidgets('validasi menolak isian kosong tanpa memanggil API', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
  });

  testWidgets('validasi menolak format email salah', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'nama@email.com'),
      'bukan-email',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Format email tidak valid.'), findsOneWidget);
  });

  testWidgets('tautan daftar membuka halaman pendaftaran terpisah', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LoginScreen()));

    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat akun CAKU'), findsOneWidget);
    expect(find.text('Nama lengkap'), findsOneWidget);
    expect(find.text('Ulangi kata sandi'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Daftar'), findsOneWidget);
  });

  testWidgets('tombol kembali di halaman daftar mengembalikan ke masuk', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.tap(find.widgetWithText(TextButton, 'Daftar'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke CAKU'), findsOneWidget);
    expect(find.text('Buat akun CAKU'), findsNothing);
  });

  testWidgets('halaman daftar sebagai halaman pertama tanpa tombol kembali', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const RegisterScreen()));

    expect(find.text('Buat akun CAKU'), findsOneWidget);
    // Tidak ada halaman sebelumnya, jadi tombol kembali tidak ditampilkan
    // agar tidak menjadi tombol yang tidak berefek.
    expect(find.widgetWithText(TextButton, 'Kembali'), findsNothing);
  });
}
