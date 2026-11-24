import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/admin_application_service.dart';
import '../state/app_scope.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/forest_header.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';
import 'admin/dashboard_screen.dart';
import 'admin_applications_screen.dart';

/// Profil pengguna. Customer: [14], Admin: [28].
///
/// Satu mode saja: tab Profil pada shell (customer & admin). Fitur yang belum
/// punya endpoint backend (edit profil, ubah password) tidak ditampilkan.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Status permohonan admin terakhir (`none`/`pending`/`approved`/`rejected`).
  String? _applicationStatus;

  @override
  void initState() {
    super.initState();
    _loadApplicationStatus();
  }

  /// Hanya keterangan status yang ditampilkan; pengajuan tetap dilakukan di
  /// [AdminApplicationsScreen].
  Future<void> _loadApplicationStatus() async {
    final auth = AuthScope.maybeOf(context);
    final user = auth?.user;
    // Status hanya relevan untuk customer yang sudah punya sesi.
    if (user == null || user.isAdmin) return;
    try {
      final data = await AppScope.read(
        context,
      ).adminApplications.myApplication();
      if (!mounted) return;
      setState(() => _applicationStatus = applicationStatus(data));
    } catch (error) {
      // Status hanya pelengkap: kegagalan memuat tidak boleh memblokir profil.
      debugPrint('Status pengajuan admin gagal dimuat: $error');
    }
  }

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

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  /// Laporan adalah tab di dalam Dashboard, jadi dibuka sebagai halaman
  /// Dashboard yang langsung memilih tab tersebut.
  void _openDashboardTab(BuildContext context, int initialTab) {
    _open(context, AdminDashboardScreen(initialTab: initialTab));
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
    final title = isAdmin ? 'Profil Admin' : 'Profil';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: ForestHeader(
              height: 150,
              eyebrow: user.role.label,
              title: title,
              subtitle: 'Kelola akun dan pengaturan CAKU.',
            ),
          ),
          ResponsiveFrame(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xl,
              AppSpacing.screen,
              AppSpacing.bottomClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IdentityCard(
                  initials: user.initials,
                  nama: user.nama,
                  email: user.email,
                  roleLabel: user.role.label,
                  showRoleBadge: isAdmin,
                ),
                const SizedBox(height: AppSpacing.xl),

                if (!isAdmin) ...[
                  const _SectionLabel('Aktivitas Akun'),
                  const SizedBox(height: AppSpacing.md),
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Menjadi Admin',
                        trailing: _applicationStatus == null
                            ? null
                            : ApplicationStatusBadge(
                                status: _applicationStatus,
                              ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AdminApplicationsScreen(),
                            ),
                          );
                          if (mounted) _loadApplicationStatus();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                if (isAdmin) ...[
                  const _SectionLabel('Operasional Admin'),
                  const SizedBox(height: AppSpacing.md),
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Laporan Pendapatan',
                        onTap: () => _openDashboardTab(context, 1),
                      ),
                      _MenuItem(
                        icon: Icons.assignment_ind_outlined,
                        label: 'Permohonan Admin',
                        onTap: () =>
                            _open(context, const AdminApplicationsScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                const _SectionLabel('Pengaturan Akun'),
                const SizedBox(height: AppSpacing.md),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu identitas pengguna: avatar inisial, nama, email, dan label role.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.initials,
    required this.nama,
    required this.email,
    required this.roleLabel,
    required this.showRoleBadge,
  });

  final String initials;
  final String nama;
  final String email;
  final String roleLabel;
  final bool showRoleBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    if (showRoleBadge) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _RoleBadge(label: roleLabel),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label heading kecil di atas tiap kelompok kartu.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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
              const Divider(
                height: 1,
                color: AppColors.border,
                indent: AppSpacing.card,
                endIndent: AppSpacing.card,
              ),
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
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
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
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: AppSpacing.sm),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
