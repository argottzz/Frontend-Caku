import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Label konsisten di atas isian.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.label,
    this.required = false,
    this.hint,
  });

  final String label;
  final bool required;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
          if (hint != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                hint!,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu ringkasan berjudul.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final String? title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Pasangan ikon + teks kecil untuk metadata.
class MetaText extends StatelessWidget {
  const MetaText({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: tint),
        const SizedBox(width: AppSpacing.xs + 2),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tint),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
