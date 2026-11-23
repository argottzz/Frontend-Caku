import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/admin_application_service.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';

/// Form Pengajuan Admin (17). Textarea alasan pengajuan dihilangkan karena
/// backend tidak menyimpannya.
class AdminApplicationScreen extends StatefulWidget {
  const AdminApplicationScreen({super.key});

  @override
  State<AdminApplicationScreen> createState() => _AdminApplicationScreenState();
}

class _AdminApplicationScreenState extends State<AdminApplicationScreen> {
  Map<String, dynamic>? _application;
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
      final data = await AppScope.read(context).adminApplications.myApplication();
      if (!mounted) return;
      setState(() => _application = data);
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

  String get _status => applicationStatus(_application);

  Future<void> _apply() async {
    setState(() => _submitting = true);
    try {
      await AppScope.read(context).adminApplications.apply();
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dikirim.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Permohonan Menjadi Admin', showBack: true),
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
    final status = _status;
    if (status == 'none') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Text(
                'Sebagai Admin, Anda bertanggung jawab mengelola inventaris, '
                'memverifikasi pembayaran, dan memproses transaksi.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _submitting ? null : _apply,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Ajukan Permohonan'),
          ),
        ],
      );
    }

    if (status == 'pending') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(status: status, application: _application),
        ],
      );
    }

    if (status == 'approved') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(status: status, application: _application),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Akun Anda telah disetujui sebagai Admin. '
            'Silakan masuk ulang jika diperlukan.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // rejected
    final reason = _application?['admin_rejection_reason'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusCard(status: status, application: _application),
        if (reason != null && reason.isNotEmpty) ...[
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
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _submitting ? null : _apply,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text('Ajukan Kembali'),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.application});

  final String status;
  final Map<String, dynamic>? application;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'pending' => 'Menunggu',
      'approved' => 'Disetujui',
      'rejected' => 'Ditolak',
      _ => status,
    };
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
    final date = application?['admin_application_date']?.toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Tanggal pengajuan: $date',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
