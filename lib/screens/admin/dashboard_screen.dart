import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/report.dart';
import '../../models/rental.dart';
import '../../state/app_scope.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/layout.dart';
import '../../widgets/rental_card.dart';
import '../../widgets/state_views.dart';

import '../admin_applications_screen.dart';
import 'item_form_screen.dart' show ItemFormScreen;
import '../rental_detail_screen.dart';
import '../rentals_screen.dart';
import 'reports_screen.dart';

/// Dashboard admin dari `GET /reports/summary`.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, this.loadReport});

  /// Sumber data opsional untuk pengujian; produksi memakai [ReportService].
  final Future<ReportData> Function()? loadReport;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  ReportData? _data;
  bool _loading = true;
  String? _error;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    AppServices? services;
    try {
      services = AppScope.read(context);
    } catch (_) {
      services = null;
    }
    setState(() {
      _error = null;
      if (_data == null) _loading = true;
    });

    try {
      final data =
          await (widget.loadReport?.call() ??
              (services != null
                  ? services.reports.summary(limit: 5)
                  : Future<ReportData>.value(
                      ReportData(ringkasan: ReportSummary.empty),
                    )));
      int totalItems = 0;
      if (services != null) {
        try {
          final page = await services.catalog.items(limit: 1);
          totalItems = page.pagination?.total ?? page.items.length;
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _data = data;
        _totalItems = totalItems;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Dashboard error: $error');
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat ringkasan.';
        _loading = false;
      });
    }
  }

  Future<void> _openRentals({RentalStatus? status}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RentalsScreen(adminMode: true, initialStatus: status),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _openDetail(Rental rental) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RentalDetailScreen(rentalId: rental.id),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(
        title: 'Dashboard',
        subtitle: 'Ringkasan operasional CAKU',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _data == null) {
      return const LoadingView(message: 'Memuat ringkasan...');
    }

    if (_error != null && _data == null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final summary = _data?.ringkasan ?? ReportSummary.empty;
    final rentals = _data?.rentals ?? const <Rental>[];

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.forest,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            maxWidth: 960,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  InlineNotice(
                    message: _error!,
                    icon: Icons.error_outline_rounded,
                    tone: NoticeTone.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _HeroCard(summary: summary),
                const SizedBox(height: AppSpacing.lg),
                _StatGrid(
                  summary: summary,
                  onOpen: (status) => _openRentals(status: status),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InventoryStrip(totalItems: _totalItems),
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(
                  onReports: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReportsScreen(),
                    ),
                  ),
                  onApplications: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminApplicationsScreen(),
                    ),
                  ),
                  onAddItem: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ItemFormScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _RevenueCard(summary: summary),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Transaksi terbaru',
                  subtitle: rentals.isEmpty
                      ? 'Belum ada transaksi untuk ditampilkan'
                      : '${rentals.length} transaksi terakhir',
                  actionLabel: 'Lihat semua',
                  onAction: () => _openRentals(),
                ),
                const SizedBox(height: AppSpacing.md),
                if (rentals.isEmpty)
                  const EmptyView(
                    compact: true,
                    icon: Icons.receipt_long_rounded,
                    title: 'Belum ada transaksi',
                    message:
                        'Pengajuan sewa dari customer akan muncul di sini '
                        'untuk diverifikasi.',
                  )
                else
                  for (final rental in rentals) ...[
                    RentalCard(
                      key: ValueKey(rental.id),
                      rental: rental,
                      showCustomer: true,
                      onTap: () => _openDetail(rental),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total pendapatan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                Formatters.rupiah(summary.totalPendapatan),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnDark,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroChip(
                    icon: Icons.receipt_long_rounded,
                    label: '${summary.totalTransaksi} transaksi',
                  ),
                  _HeroChip(
                    icon: Icons.hourglass_top_rounded,
                    label: '${summary.pending} menunggu',
                  ),
                  _HeroChip(
                    icon: Icons.backpack_outlined,
                    label: '${summary.ongoing} berjalan',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.cream),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.foreground,
    required this.background,
    this.status,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color foreground;
  final Color background;
  final RentalStatus? status;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary, required this.onOpen});

  final ReportSummary summary;
  final ValueChanged<RentalStatus?> onOpen;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatData(
        label: 'Menunggu',
        value: summary.pending,
        icon: Icons.hourglass_top_rounded,
        foreground: AppColors.warning,
        background: AppColors.warningSurface,
        status: RentalStatus.pending,
      ),
      _StatData(
        label: 'Berjalan',
        value: summary.ongoing,
        icon: Icons.backpack_outlined,
        foreground: AppColors.forest,
        background: AppColors.forestSurface,
        status: RentalStatus.ongoing,
      ),
      _StatData(
        label: 'Selesai',
        value: summary.completed,
        icon: Icons.task_alt_rounded,
        foreground: AppColors.success,
        background: AppColors.successSurface,
        status: RentalStatus.completed,
      ),
      _StatData(
        label: 'Total Transaksi',
        value: summary.totalTransaksi,
        icon: Icons.receipt_long_rounded,
        foreground: AppColors.info,
        background: AppColors.infoSurface,
        status: null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 132,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return _StatTile(data: tile, onTap: () => onOpen(tile.status));
          },
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data, required this.onTap});

  final _StatData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: data.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(data.icon, size: 18, color: data.foreground),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.gray,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${data.value}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              Text(data.label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Ringkasan pendapatan',
      children: [
        InfoRow(
          label: 'Total sewa',
          value: Formatters.rupiah(summary.totalSewa),
        ),
        InfoRow(
          label: 'Total denda',
          value: Formatters.rupiah(summary.totalDenda),
        ),
        const Divider(height: AppSpacing.lg),
        InfoRow(
          label: 'Total pendapatan',
          value: Formatters.rupiah(summary.totalPendapatan),
          emphasize: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Pendapatan mencakup transaksi disetujui, berjalan, dan selesai. '
          'Denda hanya dihitung dari transaksi selesai.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InventoryStrip extends StatelessWidget {
  const _InventoryStrip({required this.totalItems});

  final int totalItems;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.forestSurface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.forest,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Inventaris Barang',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$totalItems',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onReports,
    required this.onApplications,
    required this.onAddItem,
  });

  final VoidCallback onReports;
  final VoidCallback onApplications;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionChip(
            icon: Icons.bar_chart_rounded,
            label: 'Laporan Pendapatan',
            onTap: onReports,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.assignment_ind_outlined,
            label: 'Permohonan Admin',
            onTap: onApplications,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionChip(
            icon: Icons.add_rounded,
            label: '+ Tambah Barang',
            onTap: onAddItem,
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.forest, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
