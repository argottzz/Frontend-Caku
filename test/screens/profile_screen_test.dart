import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/models/user.dart';
import 'package:caku_app/screens/shared/profile_screen.dart';
import 'package:caku_app/state/app_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _admin = User(
  id: 1,
  nama: 'Administrator Caku',
  email: 'admin@caku.test',
  role: UserRole.admin,
);

const _customer = User(
  id: 2,
  nama: 'Arga Zanuar',
  email: 'arga@caku.test',
  role: UserRole.customer,
  phoneNumber: '085737372213',
);

Widget wrap(Widget child, {User user = _admin}) {
  final services = AppServices.create();
  services.auth.setUser(user);
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
  testWidgets('profil admin menampilkan kartu identitas ringkas', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ProfileScreen(loadPendingCount: _noPending)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil Admin'), findsOneWidget);
    expect(find.text('Administrator Caku'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('admin@caku.test'), findsOneWidget);
    expect(find.text('+ Tambahkan nomor telepon'), findsOneWidget);
    // Aksi foto dipadatkan ke ikon kamera, bukan baris tombol.
    expect(find.byTooltip('Tambah foto profil'), findsOneWidget);
    expect(find.text('Ubah foto'), findsNothing);
    expect(find.text('Hapus foto'), findsNothing);
  });

  testWidgets('profil admin menampilkan section manajemen & operasional', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ProfileScreen(loadPendingCount: _noPending)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manajemen & Operasional'), findsOneWidget);
    expect(find.text('Permohonan Admin'), findsOneWidget);
    expect(find.text('Kelola Kategori Barang'), findsOneWidget);
    expect(find.text('Aturan & Ketentuan Sewa'), findsOneWidget);
    // Laporan pendapatan sudah ada sebagai tab Dashboard.
    expect(find.text('Laporan Pendapatan'), findsNothing);

    expect(find.text('Pengaturan Akun'), findsOneWidget);
    expect(find.text('Ubah Kata Sandi'), findsOneWidget);
    expect(find.text('Tentang CAKU'), findsOneWidget);
    expect(find.text('Versi Aplikasi 1.0.0'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('lencana tidak muncul bila tidak ada permohonan menunggu', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ProfileScreen(loadPendingCount: _noPending)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Permohonan Admin'), findsOneWidget);
    expect(find.textContaining('Baru'), findsNothing);
  });

  testWidgets('lencana menampilkan jumlah permohonan yang menunggu', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ProfileScreen(loadPendingCount: _twoPending)),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 Baru'), findsOneWidget);
  });

  testWidgets('aturan & ketentuan sewa dibuka sebagai teks read-only', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const ProfileScreen(loadPendingCount: _noPending)),
    );
    await tester.pumpAndSettle();

    final item = find.text('Aturan & Ketentuan Sewa');
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(find.text('Aturan & Ketentuan Sewa'), findsWidgets);
    expect(find.textContaining('Penyewa wajib mengembalikan barang'), findsOne);
    expect(
      find.textContaining('hanya dapat dibaca dari aplikasi'),
      findsOneWidget,
    );
  });

  testWidgets('profil admin tidak meluap pada layar ponsel 375px dan 320px', (
    tester,
  ) async {
    for (final width in [375.0, 320.0]) {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrap(const ProfileScreen(loadPendingCount: _twoPending)),
      );
      await tester.pumpAndSettle();

      // Teks panjang dipotong elipsis, bukan meluap.
      expect(find.text('Administrator Caku'), findsOneWidget);
      expect(find.text('2 Baru'), findsOneWidget);
      expect(find.text('Manajemen & Operasional'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('profil customer tidak menampilkan menu khusus admin', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const ProfileScreen(), user: _customer));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Manajemen & Operasional'), findsNothing);
    expect(find.text('Kelola Kategori Barang'), findsNothing);
    expect(find.text('Permohonan Menjadi Admin'), findsOneWidget);
    expect(find.text('Syarat & Ketentuan Sewa'), findsOneWidget);
    // Nomor telepon yang sudah ada ditampilkan terformat, bukan ajakan isi.
    expect(find.text('0857-3737-2213'), findsOneWidget);
  });
}

Future<int> _noPending() async => 0;

Future<int> _twoPending() async => 2;
