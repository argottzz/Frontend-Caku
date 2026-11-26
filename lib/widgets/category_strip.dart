import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/category.dart';

/// Deretan kategori berbentuk ikon dengan label kecil di bawahnya.
///
/// Dipakai bersama oleh Beranda, Katalog, dan Kelola Barang agar filter
/// kategori selalu tampil identik di semua layar.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.onSelect,
    this.selectedId,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  final List<Category> categories;

  /// `null` berarti pilihan "Semua".
  final int? selectedId;
  final ValueChanged<int?> onSelect;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      CategoryTile(
        label: 'Semua',
        icon: Icons.grid_view_rounded,
        selected: selectedId == null,
        onTap: () => onSelect(null),
      ),
      for (final category in categories)
        CategoryTile(
          label: category.nama,
          icon: categoryIconFor(category.nama),
          selected: selectedId == category.id,
          onTap: () => onSelect(category.id),
        ),
    ];

    // Lebar dibagi rata agar tepi kanan sejajar dengan tepi kiri; bila tidak
    // muat (banyak kategori / layar sempit) kembali menjadi daftar bergulir.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        final tileWidth = width / items.length;
        if (tileWidth >= 48) {
          return Padding(
            padding: padding,
            child: Row(
              children: [for (final item in items) Expanded(child: item)],
            ),
          );
        }

        return SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: padding,
            children: items,
          ),
        );
      },
    );
  }
}

/// Ikon kategori dipilih dari kata kunci nama kategori. Kategori baru dari
/// backend otomatis memakai ikon bawaan sehingga tetap tampil rapi.
IconData categoryIconFor(String nama) {
  final n = nama.toLowerCase();
  if (n.contains('tenda')) return Icons.change_history_rounded;
  if (n.contains('tas') || n.contains('carrier')) {
    return Icons.backpack_outlined;
  }
  if (n.contains('kompor')) return Icons.local_fire_department_outlined;
  if (n.contains('lampu') || n.contains('senter')) {
    return Icons.lightbulb_outline_rounded;
  }
  if (n.contains('matras')) return Icons.bed_outlined;
  if (n.contains('tidur') || n.contains('sleeping')) {
    return Icons.airline_seat_flat_outlined;
  }
  if (n.contains('masak') || n.contains('cookware')) {
    return Icons.restaurant_outlined;
  }
  if (n.contains('kursi')) return Icons.chair_outlined;
  if (n.contains('meja')) return Icons.table_restaurant_outlined;
  if (n.contains('jaket') || n.contains('pakaian')) {
    return Icons.checkroom_outlined;
  }
  if (n.contains('sepatu')) return Icons.directions_walk_rounded;
  if (n.contains('air') || n.contains('botol')) {
    return Icons.water_drop_outlined;
  }
  return Icons.inventory_2_outlined;
}

/// Tile kategori tunggal: kotak ikon dengan label di bawahnya.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? AppColors.moss : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selected ? AppColors.moss : AppColors.border,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected ? AppColors.white : AppColors.forest,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.forest : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip kategori berbentuk kapsul. Masih dipakai bar filter status transaksi.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.moss : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? AppColors.moss : AppColors.border,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
