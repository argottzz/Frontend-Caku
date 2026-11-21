import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/catalog_screen.dart';
import 'screens/session_landing.dart';
import 'screens/splash_screen.dart';
import 'state/app_scope.dart';
import 'state/auth_controller.dart';

class CakuApp extends StatefulWidget {
  const CakuApp({super.key, required this.services});

  final AppServices services;

  @override
  State<CakuApp> createState() => _CakuAppState();
}

class _CakuAppState extends State<CakuApp> {
  late Future<void> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = _prepare();
  }

  Future<void> _prepare() async {
    await Future.wait([
      widget.services.auth.initialize(),
      // Menjaga splash tetap terlihat singkat agar tidak berkedip.
      Future<void>.delayed(const Duration(milliseconds: 700)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: AuthScope(
        controller: widget.services.auth,
        child: CartScope(
          controller: widget.services.cart,
          child: MaterialApp(
            title: 'CAKU',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('id'),
            supportedLocales: const [Locale('id'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: FutureBuilder<void>(
              future: _bootstrap,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SplashScreen();
                }
                return const RootGate();
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Menentukan layar berdasarkan status sesi dan role pengguna.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  AuthStatus? _lastStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = AuthScope.of(context);
    if (_lastStatus != auth.status) {
      final previous = _lastStatus;
      _lastStatus = auth.status;
      if (previous != null) {
        // Tutup rute yang terbuka saat sesi berubah (mis. form register
        // setelah berhasil, atau halaman detail saat sesi berakhir).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final navigator = Navigator.maybeOf(context);
          if (navigator != null && navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return switch (auth.status) {
      AuthStatus.initializing => const SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated =>
        auth.isAdmin ? SessionLanding(user: auth.user!) : const CatalogScreen(),
    };
  }
}
