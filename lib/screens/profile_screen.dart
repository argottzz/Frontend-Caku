import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

/// Profil pengguna. Data berasal dari `GET /auth/me` saat sesi dipulihkan
/// atau login; backend belum menyediakan endpoint ubah profil.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBack = false});

  final bool showBack;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari CAKU?',
      message:
          'Anda perlu masuk kembali untuk mengakses katalog dan riwayat sewa.',
      confirmLabel: 'Keluar',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      await AuthScope.read(context).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    if (user == null) {
      return const Scaffold(
        body: EmptyView(
          title: 'Sesi tidak ditemukan',
          message: 'Silakan masuk kembali untuk melihat profil.',
        ),
      );
    }

    return Scaffold(
      appBar: CakuAppBar(
        title: 'Profil',
        subtitle: 'Informasi akun Anda',
        showBack: showBack,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.forest,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user.nama,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: BadgePill(
                    label: user.role.label,
                    foreground: AppColors.forest,
                    background: AppColors.forestSurface,
                    icon: Icons.badge_outlined,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SummaryCard(
                  title: 'Informasi akun',
                  children: [
                    InfoRow(label: 'Nama lengkap', value: user.nama),
                    InfoRow(label: 'Email', value: user.email),
                    InfoRow(label: 'Peran', value: user.role.label),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const InlineNotice(
                  message:
                      'Perubahan nama, email, atau kata sandi belum tersedia '
                      'melalui aplikasi karena backend belum menyediakan '
                      'endpoint ubah profil.',
                  icon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
