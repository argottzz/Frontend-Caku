import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../state/app_scope.dart';
import '../widgets/app_snack.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

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
      final data = await AppScope.read(
        context,
      ).adminApplications.detail(widget.applicationId);
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
    final confirmed = await showConfirmDialog(
      context,
      title: 'Setujui permohonan?',
      message: 'Pemohon akan menjadi Admin.',
      confirmLabel: 'Setujui',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    try {
      await services.adminApplications.approve(widget.applicationId);
      if (!mounted) return;
      AppSnack.success(context, 'Permohonan disetujui.');
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Setujui permohonan error: $error');
      if (mounted) AppSnack.error(context, 'Permohonan gagal disetujui.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reject() async {
    final services = AppScope.read(context);
    final reason = await _showRejectDialog();
    if (reason == null || !mounted) return;
    setState(() => _submitting = true);
    try {
      await services.adminApplications.reject(widget.applicationId, reason);
      if (!mounted) return;
      AppSnack.success(context, 'Permohonan ditolak.');
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Tolak permohonan error: $error');
      if (mounted) AppSnack.error(context, 'Permohonan gagal ditolak.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: 'Alasan wajib diisi (opsional, maks. 1000 karakter)',
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
              Navigator.pop(dialogContext, text.isEmpty ? '' : text);
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    controller.dispose();
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Detail Permohonan', showBack: true),
      body: _loading
          ? const LoadingView()
          : _error != null
          ? ErrorView(message: _error!, onRetry: _load)
          : ResponsiveFrame(child: _buildBody()),
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
    final appliedAt = Formatters.parseDate(data['admin_application_date']);
    final reviewedAt = Formatters.parseDate(data['admin_reviewed_at']);
    final reviewer = data['admin_reviewer_nama']?.toString();
    final reason = data['admin_rejection_reason']?.toString().trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ApplicationStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            InfoRow(label: 'Email', value: email),
            InfoRow(
              label: 'Tanggal pengajuan',
              value: appliedAt == null ? '-' : Formatters.dateLong(appliedAt),
            ),
            if (reviewedAt != null)
              InfoRow(
                label: 'Ditinjau pada',
                value: Formatters.dateLong(reviewedAt),
              ),
            if (reviewer != null && reviewer.isNotEmpty)
              InfoRow(label: 'Ditinjau oleh', value: reviewer),
          ],
        ),
        if (status == 'rejected' && reason.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SummaryCard(
            title: 'Alasan penolakan',
            children: [
              Text(reason, style: Theme.of(context).textTheme.bodyMedium),
            ],
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
