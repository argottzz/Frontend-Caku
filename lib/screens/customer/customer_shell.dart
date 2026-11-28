import 'package:flutter/material.dart';

import '../../screens/customer/scan_qr_payment_screen.dart';
import '../../widgets/caku_bottom_nav.dart';
import '../shared/rentals_screen.dart';
import 'home_screen.dart';

/// Kerangka navigasi utama customer: Home, Scan QR (tengah), dan Pesanan Saya.
///
/// Profil dipindahkan ke header Beranda. Katalog tidak lagi menjadi tab.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  static const int _homeIndex = 0;
  static const int _scanIndex = 1;
  static const int _rentalsIndex = 2;

  int _index = _homeIndex;

  /// Dinaikkan setiap kali tab Sewa dibuka agar daftar sewa memuat ulang.
  int _rentalsEpoch = 0;

  void _select(int index) {
    if (index == _scanIndex) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ScanQrPaymentScreen(),
        ),
      );
      return;
    }
    if (index == _index) return;
    setState(() {
      if (index == _rentalsIndex) _rentalsEpoch++;
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index == _rentalsIndex ? 1 : 0,
        children: [
          const HomeScreen(),
          RentalsScreen(key: ValueKey('rentals-$_rentalsEpoch')),
        ],
      ),
      bottomNavigationBar: CakuBottomNav(
        selectedIndex: _index,
        onDestinationSelected: _select,
        featuredIndex: _scanIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Scan QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan Saya',
          ),
        ],
      ),
    );
  }
}
