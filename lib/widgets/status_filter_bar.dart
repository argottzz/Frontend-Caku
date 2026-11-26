import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/rental.dart';
import 'category_strip.dart';

/// Baris filter status transaksi, memakai chip yang sama dengan kategori agar
/// bahasa visual filter konsisten di seluruh aplikasi.
class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screen,
      vertical: AppSpacing.xs,
    ),
    this.height = 48,
  });

  final RentalStatus? selected;
  final ValueChanged<RentalStatus?> onSelect;
  final EdgeInsetsGeometry padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          CategoryChip(
            label: 'Semua',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final status in RentalStatus.values)
            CategoryChip(
              label: status.label,
              selected: selected == status,
              onTap: () => onSelect(status),
            ),
        ],
      ),
    );
  }
}
