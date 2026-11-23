import 'package:flutter/material.dart';

import '../profile_screen.dart';
import '../rentals_screen.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';

/// Kerangka navigasi utama customer: Home, Jelajahi, Sewa Saya, dan Profil.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  /// Dinaikkan setiap kali tab Sewa dibuka agar daftar sewa memuat ulang.
  int _rentalsEpoch = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      // Pengajuan baru dari keranjang dibuat di rute lain, jadi tab Sewa
      // perlu dimuat ulang saat dipilih.
      if (index == 2) _rentalsEpoch++;
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const CatalogScreen(),
          RentalsScreen(key: ValueKey('rentals-$_rentalsEpoch')),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Jelajahi',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Sewa Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}