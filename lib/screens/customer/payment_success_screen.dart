import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/layout.dart';

/// Layar konfirmasi pembayaran QR berhasil.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Pembayaran Berhasil', showBack: false),
      body: ResponsiveFrame(
        maxWidth: 520,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_rounded, size: 96, color: AppColors.success),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Pembayaran Berhasil',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pesanan Anda telah dibayar. Menunggu konfirmasi admin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Kembali ke Beranda',
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
