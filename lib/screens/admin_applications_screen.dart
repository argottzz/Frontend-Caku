import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../state/app_scope.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/category_strip.dart';
import '../widgets/state_views.dart';
import '../widgets/status_badge.dart';
import 'admin_application_panel.dart';
import 'admin_application_review_panel.dart';

/// Halaman Permohonan Admin untuk kedua peran.
///
/// * Customer melihat status permohonan miliknya sendiri (dulu halaman
///   Permohonan Menjadi Admin).
/// * Admin melihat daftar permohonan dan meninjau satu permohonan di halaman
///   yang sama (dulu halaman Daftar + Detail Permohonan).
///
/// Isi tiap peran dipisah ke file sendiri agar halaman ini tetap ringkas.
class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  /// Permohonan yang sedang ditinjau admin; `null` berarti daftar.
  int? _openId;

  /// Dinaikkan setiap kali review selesai agar daftar memuat ulang tanpa
  /// membuang filter dan posisi gulir yang sudah dipilih admin.
  int _listEpoch = 0;

  void _openDetail(int id) => setState(() => _openId = id);

  void _closeDetail() => setState(() => _openId = null);

  void _reviewed() => setState(() => _listEpoch++);

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthScope.of(context).isAdmin;
    final openId = isAdmin ? _openId : null;
    final showingDetail = openId != null;

    return PopScope(
      // Back sistem saat detail terbuka harus kembali ke daftar, bukan
      // menutup seluruh halaman.
      canPop: !showingDetail,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && showingDetail) _closeDetail();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: showingDetail
            ? CakuAppBar(
                title: 'Detail Permohonan',
                showBack: true,
                leading: IconButton(
                  tooltip: 'Kembali ke daftar',
                  onPressed: _closeDetail,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              )
            : CakuAppBar(
                title: isAdmin
                    ? 'Permohonan Admin'
                    : 'Permohonan Menjadi Admin',
                subtitle: isAdmin
                    ? 'Tinjau permohonan menjadi Admin'
                    : 'Ajukan dan pantau status permohonan',
                showBack: true,
              ),
        // IndexedStack menjaga daftar tetap hidup saat detail dibuka,
        // sehingga filter status dan posisi gulir tidak hilang.
        body: isAdmin
            ? IndexedStack(
                index: showingDetail ? 1 : 0,
                children: [
                  _AdminApplicationList(
                    onOpen: _openDetail,
                    refreshToken: _listEpoch,
                  ),
                  if (showingDetail)
                    ApplicationReviewPanel(
                      applicationId: openId,
                      onReviewed: _reviewed,
                    )
                  else
                    const SizedBox.shrink(),
                ],
              )
            : const CustomerApplicationPanel(),
      ),
    );
  }
}

/// Daftar permohonan untuk admin: filter status + kartu pemohon.
class _AdminApplicationList extends StatefulWidget {
  const _AdminApplicationList({required this.onOpen, this.refreshToken = 0});

  final ValueChanged<int> onOpen;

  /// Berubah saat review selesai; daftar memuat ulang tanpa dibangun ulang.
  final int refreshToken;

  @override
  State<_AdminApplicationList> createState() => _AdminApplicationListState();
}

class _AdminApplicationListState extends State<_AdminApplicationList> {
  static const List<String?> _filters = [
    null,
    'pending',
    'approved',
    'rejected',
  ];

  List<Map<String, dynamic>> _items = const [];
  String? _status;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AdminApplicationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AppScope.read(
        context,
      ).adminApplications.list(status: _status);
      if (!mounted) return;
      setState(() => _items = data);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (error) {
      debugPrint('Permohonan admin error: $error');
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat data.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectStatus(String? status) {
    if (_status == status) return;
    setState(() => _status = status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.xs,
            ),
            children: [
              for (final status in _filters)
                CategoryChip(
                  label: status == null
                      ? 'Semua'
                      : ApplicationStatusBadge.labelFor(status),
                  selected: _status == status,
                  onTap: () => _selectStatus(status),
                ),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) return const LoadingView();
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_items.isEmpty) {
      return EmptyView(
        icon: Icons.assignment_ind_outlined,
        title: 'Belum ada permohonan',
        message: _status == null
            ? 'Permohonan menjadi Admin akan muncul di sini.'
            : 'Tidak ada permohonan dengan status ini.',
        actionLabel: _status == null ? null : 'Lihat semua',
        onAction: _status == null ? null : () => _selectStatus(null),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.forest,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxl,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ApplicationCard(
              nama: item['nama']?.toString() ?? '-',
              email: item['email']?.toString() ?? '',
              tanggal: Formatters.parseDate(item['admin_application_date']),
              status: item['admin_application_status']?.toString(),
              onTap: () {
                final id = (item['id_user'] as num?)?.toInt();
                if (id != null) widget.onOpen(id);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Satu baris permohonan: inisial pemohon, identitas, tanggal, dan status.
class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.nama,
    required this.email,
    required this.tanggal,
    required this.status,
    required this.onTap,
  });

  final String nama;
  final String email;
  final DateTime? tanggal;
  final String? status;
  final VoidCallback onTap;

  /// Inisial maksimal dua huruf dari nama pemohon.
  String get _initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.mist,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.moss,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (tanggal != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Diajukan ${Formatters.date(tanggal!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    ApplicationStatusBadge(status: status),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
