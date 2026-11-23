import 'package:flutter/widgets.dart';

import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../data/admin_application_service.dart';
import '../data/catalog_service.dart';
import '../data/rental_service.dart';
import '../data/report_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

/// Kumpulan dependensi aplikasi yang dibuat sekali di [main].
class AppServices {
  AppServices._({
    required this.api,
    required this.storage,
    required this.auth,
    required this.cart,
    required this.catalog,
    required this.rentals,
    required this.reports,
    required this.adminApplications,
  });

  factory AppServices.create() {
    final storage = TokenStorage();
    late final AuthController auth;
    final api = ApiClient(
      baseUrl: ApiConfig.baseUrl,
      onUnauthorized: () => auth.handleUnauthorized(),
    );
    auth = AuthController(client: api, storage: storage);
    final cart = CartController();
    return AppServices._(
      api: api,
      storage: storage,
      auth: auth,
      cart: cart,
      catalog: CatalogService(api),
      rentals: RentalService(api),
      reports: ReportService(api),
      adminApplications: AdminApplicationService(api),
    );
  }

  final ApiClient api;
  final TokenStorage storage;
  final AuthController auth;
  final CartController cart;
  final CatalogService catalog;
  final RentalService rentals;
  final ReportService reports;
  final AdminApplicationService adminApplications;
}

/// Akses dependensi non-reaktif.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan pada pohon widget.');
    return scope!.services;
  }

  static AppServices read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan pada pohon widget.');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}

/// Akses status autentikasi yang reaktif.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope?.notifier != null, 'AuthScope tidak ditemukan.');
    return scope!.notifier!;
  }

  static AuthController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope?.notifier != null, 'AuthScope tidak ditemukan.');
    return scope!.notifier!;
  }

  static AuthController? maybeOf(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    return scope?.notifier;
  }
}

/// Akses keranjang yang reaktif.
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope?.notifier != null, 'CartScope tidak ditemukan.');
    return scope!.notifier!;
  }

  static CartController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CartScope>();
    assert(scope?.notifier != null, 'CartScope tidak ditemukan.');
    return scope!.notifier!;
  }
}
