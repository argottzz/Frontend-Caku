import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/caku_logo.dart';
import '../../widgets/layout.dart';

/// Kerangka layar autentikasi: panel merek di layar lebar, header ringkas
/// di ponsel.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

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
                      child: child,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: ResponsiveFrame(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _MobileBrandHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _FormCard(
                      title: title,
                      subtitle: subtitle,
                      footer: footer,
                      child: child,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.forest,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Glow(size: 260, opacity: 0.10),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Glow(size: 300, opacity: 0.08),
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
                    color: AppColors.textOnDark,
                    height: 1.25,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.cream.withValues(alpha: 0.75),
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

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cream.withValues(alpha: opacity),
      ),
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
              color: AppColors.cream.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 15, color: AppColors.cream),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.cream.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBrandHeader extends StatelessWidget {
  const _MobileBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CakuLogo(size: 84, showFrame: true),
        const SizedBox(height: AppSpacing.md),
        Text(
          'CAKU',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.forest,
            letterSpacing: 4,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Penyewaan perlengkapan camping',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final double maxWidth;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormCard(title: title, subtitle: subtitle, child: child),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.nearBlack.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xl),
          child,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            footer!,
          ],
        ],
      ),
    );
  }
}
