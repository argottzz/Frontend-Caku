import 'package:caku_app/screens/splash_screen.dart';
import 'package:caku_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('splash menampilkan merek CAKU', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('CAKU'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
