import 'package:caku_app/core/theme/app_theme.dart';
import 'package:caku_app/widgets/caku_app_bar.dart';
import 'package:caku_app/widgets/caku_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  String? subtitle = 'Pantau status pengajuan sewa Anda',
  bool showBack = false,
  VoidCallback? onCartTap,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      appBar: CakuAppBar(
        title: 'Pesanan Saya',
        subtitle: subtitle,
        showBack: showBack,
        onCartTap: onCartTap,
      ),
      body: const SizedBox.shrink(),
    ),
  );
}

void main() {
  testWidgets('header tanpa ikon, teks terpusat dan judul tebal', (
    tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.byType(CakuLogoMark), findsNothing);
    expect(find.byType(CakuLogo), findsNothing);

    final title = tester.widget<Text>(find.text('Pesanan Saya'));
    expect(title.textAlign, TextAlign.center);
    expect(title.style?.fontWeight, FontWeight.w800);

    final subtitle = tester.widget<Text>(
      find.text('Pantau status pengajuan sewa Anda'),
    );
    expect(subtitle.textAlign, TextAlign.center);

    expect(tester.getCenter(find.text('Pesanan Saya')).dx, closeTo(400, 5));
    expect(
      tester.getCenter(find.text('Pantau status pengajuan sewa Anda')).dx,
      closeTo(400, 5),
    );
  });

  testWidgets('header tetap rapi dengan tombol kembali dan keranjang', (
    tester,
  ) async {
    await tester.pumpWidget(_app(showBack: true, onCartTap: () {}));

    expect(find.byTooltip('Kembali'), findsOneWidget);
    expect(find.byTooltip('Keranjang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header tidak meluap pada layar sempit 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(showBack: true, onCartTap: () {}));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
