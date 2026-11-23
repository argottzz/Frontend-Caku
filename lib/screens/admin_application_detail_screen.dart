import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
// data service accessed via AppScope
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';

/// Detail Permohonan Admin (27).
class AdminApplicationDetailScreen extends StatefulWidget {
  const AdminApplicationDetailScreen({super.key, required this.applicationId});

  final int applicationId;

  @override
  State<AdminApplicationDetailScreen> createState() =>
      _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState
    extends State<AdminApplicationDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AppScope.read(context).adminApplications.detail(
        widget.applicationId,
      );
      if (!mounted) return;
      setState(() => _data = data);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat data.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _status =>
      (_data?['admin_application_status'] as String?) ?? 'none';

  Future<void> _approve() async {
    final services = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Setujui permohonan?',
      message: 'Pemohon akan menjadi Admin.',
      confirmLabel: 'Setujui',
    );
    if (!confirmed) return;
    setState(() => _submitting = true);
    try {
      await services.adminApplications.approve(
        widget.applicationId,
      );
      if (!mounted) return;
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reject() async {
    final services = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _showRejectDialog();
    if (reason == null) return;
    setState(() => _submitting = true);
    try {
      await services.adminApplications.reject(
        widget.applicationId,
        reason,
      );
      if (!mounted) return;
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Alasan wajib diisi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogContext, text);
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Detail Permohonan', showBack: true),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ResponsiveFrame(
                  child: _buildBody(),
                ),
    );
  }

  Widget _buildBody() {
    final data = _data;
    if (data == null) {
      return const EmptyView(
        title: 'Permohonan tidak ditemukan',
        message: 'Data tidak tersedia.',
      );
    }
    final status = _status;
    final name = data['nama']?.toString() ?? '-';
    final email = data['email']?.toString() ?? '-';
    final date = data['admin_application_date']?.toString();
    final reason = data['admin_rejection_reason'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(email, style: Theme.of(context).textTheme.bodySmall),
                if (date != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('Tanggal pengajuan: $date',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.sm),
                _StatusPill(status: status),
              ],
            ),
          ),
        ),
        if (status == 'rejected' && reason != null && reason.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alasan Penolakan',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(reason, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
        if (status == 'pending') ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _submitting ? null : _approve,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Setujui Permohonan'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending' => AppColors.pendingText,
      'approved' => AppColors.approvedText,
      'rejected' => AppColors.rejectedText,
      _ => AppColors.textSecondary,
    };
    final bg = switch (status) {
      'pending' => AppColors.pendingBg,
      'approved' => AppColors.approvedBg,
      'rejected' => AppColors.rejectedBg,
      _ => AppColors.surface,
    };
    final label = switch (status) {
      'pending' => 'Menunggu',
      'approved' => 'Disetujui',
      'rejected' => 'Ditolak',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
