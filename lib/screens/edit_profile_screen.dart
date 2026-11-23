import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';

/// Edit Profil (15). Saat ini read-only: backend belum menyediakan endpoint
/// ubah profil.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    return Scaffold(
      appBar: const CakuAppBar(title: 'Edit Profil', showBack: true),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const _InfoBanner(
                  message:
                      'Perubahan profil membutuhkan dukungan backend. '
                      'Fitur ini belum tersedia saat ini.',
                ),
                const SizedBox(height: AppSpacing.lg),
                FieldLabel(label: 'Email', required: false),
                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: AppSpacing.formField),
                FieldLabel(label: 'Nama Lengkap', required: true),
                TextFormField(
                  initialValue: user?.nama ?? '',
                  readOnly: true,
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: null,
                  child: const Text('Simpan Perubahan'),
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
