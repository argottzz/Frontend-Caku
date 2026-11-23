import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/rental.dart';

/// Baris pill horizontal untuk memilih status sewa. Dipakai oleh daftar
/// penyewaan customer/admin dan laporan admin.
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
          _StatusPill(
            label: 'Semua',
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          ...RentalStatus.values.map(
            (status) => _StatusPill(
              label: status.label,
              selected: selected == status,
              onTap: () => onSelect(status),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
        color: selected ? AppColors.forest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
