import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Kerangka konten responsif: nyaman di ponsel dan tidak melebar di web.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = 560,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screen,
      vertical: AppSpacing.lg,
    ),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Latar bertema untuk layar autentikasi dan status kosong.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                color: AppColors.forestSurface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Baris label–nilai untuk ringkasan transaksi.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasize
                  ? style
                  : style?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            textAlign: TextAlign.right,
            style: style?.copyWith(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
