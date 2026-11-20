import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/rental.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.dense = false});

  final RentalStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      RentalStatus.pending => (AppColors.warningSurface, AppColors.warning),
      RentalStatus.approved => (AppColors.infoSurface, AppColors.info),
      RentalStatus.ongoing => (AppColors.forestSurface, AppColors.forest),
      RentalStatus.completed => (AppColors.successSurface, AppColors.success),
      RentalStatus.rejected => (AppColors.errorSurface, AppColors.error),
    };

    return BadgePill(
      label: status.label,
      foreground: foreground,
      background: background,
      dense: dense,
      icon: switch (status) {
        RentalStatus.pending => Icons.hourglass_top_rounded,
        RentalStatus.approved => Icons.verified_rounded,
        RentalStatus.ongoing => Icons.local_shipping_rounded,
        RentalStatus.completed => Icons.check_circle_rounded,
        RentalStatus.rejected => Icons.cancel_rounded,
      },
    );
  }
}

class BadgePill extends StatelessWidget {
  const BadgePill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? 3 : AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final available = stock > 0;
    return BadgePill(
      label: available ? 'Stok $stock' : 'Stok habis',
      foreground: available ? AppColors.forest : AppColors.error,
      background: available ? AppColors.forestSurface : AppColors.errorSurface,
      dense: true,
    );
  }
}
