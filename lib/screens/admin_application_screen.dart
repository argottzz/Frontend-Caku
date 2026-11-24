import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../data/admin_application_service.dart';
import '../state/app_scope.dart';
import '../widgets/app_snack.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';

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
      final data = await AppScope.read(
        context,
      ).adminApplications.myApplication();
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
      AppSnack.success(context, 'Pengajuan berhasil dikirim.');
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Ajukan admin error: $error');
      if (mounted) AppSnack.error(context, 'Pengajuan gagal dikirim.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(
        title: 'Permohonan Menjadi Admin',
        showBack: true,
      ),
      body: _loading
          ? const LoadingView()
          : _error != null
          ? ErrorView(message: _error!, onRetry: _load)
          : ResponsiveFrame(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final status = _status;
    if (status == 'none') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          SummaryCard(
            children: [
              Text(
                'Sebagai Admin, Anda bertanggung jawab mengelola inventaris, '
                'memverifikasi pembayaran, dan memproses transaksi.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
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
          const SizedBox(height: AppSpacing.lg),
          const InlineNotice(
            tone: NoticeTone.warning,
            icon: Icons.hourglass_top_rounded,
            title: 'Menunggu peninjauan',
            message:
                'Admin akan meninjau permohonan Anda. Status diperbarui '
                'di halaman ini dan di Profil.',
          ),
        ],
      );
    }

    if (status == 'approved') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(status: status, application: _application),
          const SizedBox(height: AppSpacing.lg),
          const InlineNotice(
            tone: NoticeTone.success,
            icon: Icons.verified_user_outlined,
            title: 'Permohonan disetujui',
            message:
                'Akun Anda kini memiliki akses Admin. Masuk ulang jika '
                'menu admin belum muncul.',
          ),
        ],
      );
    }

    // rejected
    final reason = _application?['admin_rejection_reason']?.toString().trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusCard(status: status, application: _application),
        if (reason != null && reason.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SummaryCard(
            title: 'Alasan penolakan',
            children: [
              Text(reason, style: Theme.of(context).textTheme.bodyMedium),
            ],
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
    final date = Formatters.parseDate(application?['admin_application_date']);
    return SummaryCard(
      children: [
        ApplicationStatusBadge(status: status, dense: false),
        if (date != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tanggal pengajuan: ${Formatters.dateLong(date)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
