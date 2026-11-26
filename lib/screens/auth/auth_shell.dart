import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/caku_logo.dart';
import '../../widgets/layout.dart';

/// Kerangka layar autentikasi: panel merek di layar lebar, header ringkas
/// di ponsel. Judul dan keterangan berada di luar kartu, sedangkan seluruh
/// isian form berada di dalam satu kartu agar fokus pengguna jelas.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  /// Tombol kembali di atas form. `null` berarti halaman ini bukan halaman
  /// yang dibuka dari halaman lain, jadi tidak ada tombol yang tidak berefek.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(flex: 5, child: _BrandPanel()),
                  Expanded(
                    flex: 6,
                    child: _FormArea(
                      title: title,
                      subtitle: subtitle,
                      footer: footer,
                      maxWidth: 480,
                      onBack: onBack,
                      child: child,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xl,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              child: ResponsiveFrame(
                padding: EdgeInsets.zero,
                child: _FormContent(
                  title: title,
                  subtitle: subtitle,
                  footer: footer,
                  onBack: onBack,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Panel merek di layar lebar: foto hutan, logo, dan poin keunggulan.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'asset/images/branding/forest-header.jpg',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stack) =>
              const ColoredBox(color: AppColors.forest),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xB310241F), Color(0xF210241F)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl + AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CakuLogo(size: 108, showFrame: true),
              const Spacer(),
              Text(
                'Perlengkapan camping\nsiap menemani\npetualanganmu.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 28,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _BrandPoint(
                icon: Icons.inventory_2_outlined,
                text: 'Katalog alat camping dengan stok yang jelas',
              ),
              const _BrandPoint(
                icon: Icons.event_available_outlined,
                text: 'Pengajuan sewa dengan tanggal yang fleksibel',
              ),
              const _BrandPoint(
                icon: Icons.receipt_long_outlined,
                text: 'Riwayat transaksi dan rincian biaya transparan',
              ),
              const Spacer(),
              Text(
                'CAKU • Penyewaan perlengkapan camping',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.sageLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandPoint extends StatelessWidget {
  const _BrandPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 15, color: AppColors.sageLight),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.sageLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormArea extends StatelessWidget {
  const _FormArea({
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.maxWidth = 480,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final double maxWidth;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _FormContent(
            title: title,
            subtitle: subtitle,
            footer: footer,
            onBack: onBack,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Logo, judul dan sub-judul di tengah, lalu form di dalam kartu dan tautan
/// pindah halaman di bawahnya (di luar kartu).
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali'),
            ),
          ),
        const Center(child: CakuLogo(size: 64, showFrame: true)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
        if (footer != null) ...[const SizedBox(height: AppSpacing.lg), footer!],
      ],
    );
  }
}
