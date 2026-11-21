import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../profile_screen.dart';
import '../rentals_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';

/// Kerangka navigasi utama customer: Katalog, Keranjang, Sewa, dan Profil.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  /// Dinaikkan setelah pengajuan sewa berhasil agar tab Sewa memuat ulang.
  int _rentalsEpoch = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartQuantity = CartScope.of(context).totalQuantity;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const CatalogScreen(),
          CartScreen(
            onBrowse: () => _select(0),
            onRentalCreated: () => setState(() => _rentalsEpoch++),
          ),
          RentalsScreen(key: ValueKey('rentals-$_rentalsEpoch')),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: _CartBadge(
              quantity: cartQuantity,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: _CartBadge(
              quantity: cartQuantity,
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Sewa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.quantity, required this.child});

  final int quantity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: quantity > 0,
      label: Text(quantity > 99 ? '99+' : '$quantity'),
      child: child,
    );
  }
}
