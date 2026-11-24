import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/rental.dart';
import 'status_badge.dart';

/// Ringkasan satu transaksi sewa untuk daftar customer maupun admin.
class RentalCard extends StatelessWidget {
  const RentalCard({
    super.key,
    required this.rental,
    this.onTap,
    this.showCustomer = false,
  });

  final Rental rental;
  final VoidCallback? onTap;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strip tipis hijau sebagai penanda kartu transaksi.
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.forest, AppColors.sage],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _body(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pesanan #${rental.id}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            StatusBadge(status: rental.status, dense: true),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${rental.jumlahItem} jenis barang • '
          '${rental.durasiHari} hari',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (showCustomer) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${rental.namaUser} • ${rental.emailUser}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(
              Icons.event_rounded,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Expanded(
              child: Text(
                '${Formatters.date(rental.tanggalMulai)} – '
                '${Formatters.date(rental.tanggalSelesai)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total bayar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    Formatters.rupiah(rental.totalBayar),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forest,
                    ),
                  ),
                ],
              ),
            ),
            if (rental.status == RentalStatus.pending &&
                rental.buktiTransferUrl.isEmpty)
              const Text(
                'Bukti belum ada',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}
