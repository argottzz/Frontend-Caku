import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';

/// Ubah Password (16). Saat ini read-only: backend belum menyediakan endpoint
/// ubah password.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Ubah Password', showBack: true),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Ubah password membutuhkan dukungan backend. '
                          'Fitur ini belum tersedia saat ini.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FieldLabel(label: 'Password Lama', required: true),
                TextFormField(obscureText: true, readOnly: true),
                const SizedBox(height: AppSpacing.formField),
                FieldLabel(label: 'Password Baru', required: true),
                TextFormField(obscureText: true, readOnly: true),
                const SizedBox(height: AppSpacing.formField),
                FieldLabel(label: 'Konfirmasi Password Baru', required: true),
                TextFormField(obscureText: true, readOnly: true),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: null,
                  child: const Text('Simpan Password'),
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
