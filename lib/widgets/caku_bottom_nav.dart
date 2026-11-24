import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Bottom navigation bar utama (customer & admin) berbentuk floating pill.
///
/// Memakai [NavigationBar] milik Flutter agar touch target, splash, dan
/// aksesibilitas tetap bawaan; hanya tampilannya yang disesuaikan. Theme
/// `navigationBarTheme` di [AppTheme] sengaja tidak dipakai karena bar ini
/// membungkusnya dengan container melayang.
///
/// Jika [featuredIndex] diisi, destinasi tersebut ditampilkan sebagai tombol
/// bundar yang terangkat di tengah bar (dipakai untuk tab Profil customer).
class CakuBottomNav extends StatelessWidget {
  const CakuBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.featuredIndex,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  /// Indeks destinasi yang ditonjolkan; `null` memakai bar biasa.
  final int? featuredIndex;

  @override
  Widget build(BuildContext context) {
    final featured = featuredIndex;
    final hasFeatured = featured != null &&
        featured >= 0 &&
        featured < destinations.length;

    final bar = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.nav),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1417322E),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.nav),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            elevation: 0,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: states.contains(WidgetState.selected)
                    ? AppColors.forest
                    : AppColors.textSecondary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                size: 22,
                color: states.contains(WidgetState.selected)
                    ? AppColors.forest
                    : AppColors.textSecondary,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            height: 64,
            destinations: hasFeatured
                ? [
                    for (var i = 0; i < destinations.length; i++)
                      i == featured
                          ? const NavigationDestination(
                              icon: SizedBox.shrink(),
                              label: '',
                              enabled: false,
                            )
                          : destinations[i],
                  ]
                : destinations,
          ),
        ),
      ),
    );

    if (!hasFeatured) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            AppSpacing.sm,
          ),
          child: bar,
        ),
      );
    }

    final destination = destinations[featured];
    final isSelected = selectedIndex == featured;

    // Ruang ekstra di atas bar memberi tempat tombol terangkat agar tidak
    // terpotong dan tetap bisa disentuh.
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 64 + 20 + AppSpacing.sm,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                20,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: bar,
            ),
            Positioned(
              top: 0,
              child: _FeaturedTab(
                destination: destination,
                selected: isSelected,
                onTap: () => onDestinationSelected(featured),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab utama yang terangkat: lingkaran Primary + label tebal.
class _FeaturedTab extends StatelessWidget {
  const _FeaturedTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? destination.selectedIcon : destination.icon;
    final iconColor = selected ? AppColors.white : AppColors.forest;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.forest : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.forest : AppColors.border,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2617322E),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconTheme(
                data: IconThemeData(size: 24, color: iconColor),
                child: Center(child: icon ?? const SizedBox.shrink()),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.forest : AppColors.textSecondary,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
