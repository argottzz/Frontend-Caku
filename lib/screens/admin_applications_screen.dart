import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/state_views.dart';
import 'admin_application_detail_screen.dart';

/// Daftar Permohonan Admin (26).
class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  List<Map<String, dynamic>> _items = const [];
  String? _status;
  bool _loading = true;
  String? _error;

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
      final data = await AppScope.read(context).adminApplications.list(
        status: _status,
      );
      if (!mounted) return;
      setState(() => _items = data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Permohonan Admin', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final s in [null, 'pending', 'approved', 'rejected'])
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(s == null ? 'Semua' : _label(s)),
                        selected: _status == s,
                        onSelected: (_) {
                          setState(() => _status = s);
                          _load();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _items.isEmpty
                        ? const EmptyView(
                            title: 'Belum ada permohonan menjadi Admin',
                            message: 'Permohonan akan muncul di sini.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.forest,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.screen),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final id = (item['id_user'] as num?)?.toInt() ?? 0;
                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.listItem,
                                  ),
                                  child: ListTile(
                                    title: Text(item['nama']?.toString() ?? '-'),
                                    subtitle: Text(item['email']?.toString() ?? ''),
                                    trailing: _StatusPill(
                                      status: item['admin_application_status']
                                          ?.toString(),
                                    ),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            AdminApplicationDetailScreen(
                                          applicationId: id,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _label(String status) {
    return switch (status) {
      'pending' => 'Menunggu',
      'approved' => 'Disetujui',
      'rejected' => 'Ditolak',
      _ => status,
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String? status;

  String _statusLabel(String? status) {
    return switch (status) {
      'pending' => 'Menunggu',
      'approved' => 'Disetujui',
      'rejected' => 'Ditolak',
      _ => status ?? '-',
    };
  }

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
