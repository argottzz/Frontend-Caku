import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/user.dart';
import '../state/app_scope.dart';
import '../widgets/app_buttons.dart';
import '../widgets/caku_logo.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';
import '../widgets/status_badge.dart';

/// Layar sesi sementara: menampilkan identitas pengguna dan aksi keluar.
/// Digantikan oleh beranda customer/admin pada tahap berikutnya.
class SessionLanding extends StatelessWidget {
  const SessionLanding({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CakuLogoMark(size: 30),
            SizedBox(width: AppSpacing.sm),
            Text('CAKU'),
          ],
        ),
      ),
      body: ResponsiveFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Center(child: CakuLogo(size: 120, showFrame: true)),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sesi Anda aktif',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Halo, ${user.nama}.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SummaryCard(
              title: 'Informasi akun',
              children: [
                InfoRow(label: 'Nama', value: user.nama),
                InfoRow(label: 'Email', value: user.email),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BadgePill(
                      label: user.role.label,
                      foreground: AppColors.forest,
                      background: AppColors.forestSurface,
                      icon: Icons.badge_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SecondaryButton(
              label: 'Keluar',
              icon: Icons.logout_rounded,
              onPressed: () => AuthScope.read(context).logout(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
