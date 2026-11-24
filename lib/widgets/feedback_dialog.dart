import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Modal feedback terpusat (sukses / gagal) dengan backdrop gelap.
///
/// Dipakai untuk alur yang butuh konfirmasi visual sebelum berpindah layar.
/// Pesan tetap berasal dari sistem; modal ini hanya menampilkannya.
Future<void> showFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  bool success = true,
  String actionLabel = 'Mengerti',
  Future<void> Function()? onAction,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.nearBlack.withValues(alpha: 0.45),
    builder: (dialogContext) {
      return _FeedbackCard(
        title: title,
        message: message,
        success: success,
        actionLabel: actionLabel,
        onAction: () async {
          if (onAction != null) await onAction();
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      );
    },
  );
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.title,
    required this.message,
    required this.success,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final bool success;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final accent = success ? AppColors.forest : AppColors.error;
    final tint = success ? AppColors.forestSurface : AppColors.errorSurface;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.modal),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(
                  success
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
