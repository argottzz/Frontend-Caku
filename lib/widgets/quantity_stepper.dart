import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.min = 1,
    this.max,
    this.compact = false,
    this.semanticLabel = 'Jumlah',
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final int min;
  final int? max;
  final bool compact;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min && onDecrement != null;
    final canIncrement = (max == null || value < max!) && onIncrement != null;
    final size = compact ? 32.0 : 40.0;

    return Semantics(
      label: '$semanticLabel: $value',
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              size: size,
              enabled: canDecrement,
              tooltip: 'Kurangi $semanticLabel',
              onPressed: onDecrement,
            ),
            SizedBox(
              width: compact ? 28 : 36,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              size: size,
              enabled: canIncrement,
              tooltip: 'Tambah $semanticLabel',
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.forest,
        disabledForegroundColor: AppColors.lightGray,
      ),
      icon: Icon(icon, size: 18),
    );
  }
}
