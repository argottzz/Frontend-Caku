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
      RentalStatus.pending => (AppColors.pendingBg, AppColors.pendingText),
      RentalStatus.approved => (AppColors.approvedBg, AppColors.approvedText),
      RentalStatus.ongoing => (AppColors.ongoingBg, AppColors.ongoingText),
      RentalStatus.completed => (
        AppColors.completedBg,
        AppColors.completedText,
      ),
      RentalStatus.rejected => (AppColors.rejectedBg, AppColors.rejectedText),
    };

    return BadgePill(
      label: status.label,
      foreground: foreground,
      background: background,
      dense: dense,
      icon: switch (status) {
        RentalStatus.pending => Icons.schedule,
        RentalStatus.approved => Icons.check_circle,
        RentalStatus.ongoing => Icons.autorenew,
        RentalStatus.completed => Icons.done_all,
        RentalStatus.rejected => Icons.cancel,
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
        borderRadius: BorderRadius.circular(AppRadius.sm),
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

/// Badge status Permohonan Admin (`pending`/`approved`/`rejected`).
class ApplicationStatusBadge extends StatelessWidget {
  const ApplicationStatusBadge({
    super.key,
    required this.status,
    this.dense = true,
  });

  /// Nilai mentah dari API; `null` atau tak dikenal ditampilkan apa adanya.
  final String? status;
  final bool dense;

  static String labelFor(String? status) => switch (status) {
    'pending' => 'Menunggu',
    'approved' => 'Disetujui',
    'rejected' => 'Ditolak',
    _ => status == null || status.isEmpty ? '-' : status,
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (status) {
      'pending' => (
        AppColors.pendingBg,
        AppColors.pendingText,
        Icons.schedule_rounded,
      ),
      'approved' => (
        AppColors.approvedBg,
        AppColors.approvedText,
        Icons.check_circle_outline_rounded,
      ),
      'rejected' => (
        AppColors.rejectedBg,
        AppColors.rejectedText,
        Icons.cancel_outlined,
      ),
      _ => (
        AppColors.surfaceMuted,
        AppColors.textSecondary,
        Icons.help_outline_rounded,
      ),
    };

    return BadgePill(
      label: labelFor(status),
      foreground: foreground,
      background: background,
      icon: icon,
      dense: dense,
    );
  }
}
