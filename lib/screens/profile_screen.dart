import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';
import 'admin/reports_screen.dart';
import 'admin_applications_screen.dart';
import 'admin_application_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

/// Profil pengguna. Customer: [14], Admin: [28].
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

  Future<void> _showAbout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tentang CAKU'),
        content: const Text(
          'CAKU - aplikasi penyewaan perlengkapan camping.\n'
          'Versi 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;
    if (user == null) {
      return const Scaffold(
        body: EmptyView(
          title: 'Sesi tidak ditemukan',
          message: 'Silakan masuk kembali untuk melihat profil.',
        ),
      );
    }

    final isAdmin = user.isAdmin;

    return Scaffold(
      appBar: CakuAppBar(
        title: isAdmin ? 'Profil Admin' : 'Profil',
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
                // Header 2 kolom
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.forest,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nama,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          if (isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forest,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Text(
                                'Admin',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  foregroundColor: AppColors.textOnOrange,
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                ),
                                child: const Text('Edit Profil'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ChangePasswordScreen(),
                                  ),
                                ),
                                icon: const Icon(Icons.lock_reset_rounded),
                                tooltip: 'Ubah Password',
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.textPrimary,
                                  shape: const CircleBorder(),
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (!isAdmin) ...[
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Menjadi Admin',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminApplicationScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (isAdmin) ...[
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Laporan Pendapatan',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReportsScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Admin',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminApplicationsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _MenuCard(
                  children: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang CAKU',
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 19),
                  label: const Text('Keluar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.forest, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
