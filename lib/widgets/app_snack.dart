import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

abstract final class AppSnack {
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.success,
      Icons.check_circle_outline,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_outline_rounded);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.info, Icons.info_outline_rounded);
  }

  static void _show(
    BuildContext context,
    String message,
    Color accent,
    IconData icon, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  onPressed: () {
                    // Tutup lebih dulu agar snack bar tidak tersangkut bila
                    // aksi gagal (mis. context layar asal sudah dilepas).
                    messenger.hideCurrentSnackBar(
                      reason: SnackBarClosedReason.action,
                    );
                    onAction();
                  },
                )
              : null,
          // Sejak Flutter 3.44 snack bar yang punya aksi bertahan terus bila
          // `persist` tidak diatur. Semua snack bar di aplikasi ini harus
          // hilang sendiri setelah durasi tampil.
          persist: false,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
