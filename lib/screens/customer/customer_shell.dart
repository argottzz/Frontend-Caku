import 'package:flutter/material.dart';

import '../../widgets/caku_bottom_nav.dart';
import '../profile_screen.dart';
import '../rentals_screen.dart';
import 'home_screen.dart';

/// Kerangka navigasi utama customer: Home, Profil (tengah), dan Sewa Saya.
///
/// Katalog tidak lagi menjadi tab; halaman itu dibuka dari pencarian atau
/// kategori di Beranda.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  static const int _homeIndex = 0;
  static const int _profileIndex = 1;
  static const int _rentalsIndex = 2;

  int _index = _homeIndex;

  /// Dinaikkan setiap kali tab Sewa dibuka agar daftar sewa memuat ulang.
  int _rentalsEpoch = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      // Pengajuan baru dari keranjang dibuat di rute lain, jadi tab Sewa
      // perlu dimuat ulang saat dipilih.
      if (index == _rentalsIndex) _rentalsEpoch++;
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenProfile: () => _select(_profileIndex)),
          const ProfileScreen(),
          RentalsScreen(key: ValueKey('rentals-$_rentalsEpoch')),
        ],
      ),
      bottomNavigationBar: CakuBottomNav(
        selectedIndex: _index,
        onDestinationSelected: _select,
        featuredIndex: _profileIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Sewa Saya',
          ),
        ],
      ),
    );
  }
}
