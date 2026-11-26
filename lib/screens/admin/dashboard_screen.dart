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

import '../shared/admin_applications_screen.dart';
import 'item_form_screen.dart' show ItemFormScreen;
import '../shared/rental_detail_screen.dart';
import '../shared/rentals_screen.dart';
import 'reports_screen.dart';

/// Dashboard admin: dua tab dalam satu halaman.
///
/// * **Ringkasan** — kondisi operasional hari ini (`GET /reports/summary`).
/// * **Laporan** — rekap dengan filter tanggal dan status.
///
/// Dulu keduanya dua halaman terpisah dengan header yang sama; sekarang
/// header dan pemilih tab dipakai bersama, isi tiap tab tetap di file
/// masing-masing.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    this.loadReport,
    this.loadReports,
    this.initialTab = 0,
  });

  /// Sumber data opsional untuk pengujian; produksi memakai [ReportService].
  final Future<ReportData> Function()? loadReport;

  /// 0 = Ringkasan, 1 = Laporan.
  final int initialTab;
  final Future<ReportData> Function({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int page,
    int limit,
  })?
  loadReports;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const int _summaryTab = 0;
  static const int _reportsTab = 1;

  int _tab = _summaryTab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(_summaryTab, _reportsTab);
    _reportsVisited = _tab == _reportsTab;
  }

  /// Tab laporan baru dibangun setelah pertama kali dibuka, supaya dashboard
  /// tidak memanggil API laporan sebelum admin membutuhkannya. Setelah itu
  /// widget tetap hidup sehingga filter tanggal tidak hilang saat berpindah
  /// tab.
  bool _reportsVisited = false;

  void _selectTab(int index) {
    if (_tab == index) return;
    setState(() {
      if (index == _reportsTab) _reportsVisited = true;
      _tab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CakuAppBar(
        title: 'Dashboard',
        showBack: Navigator.of(context).canPop(),
      ),
      body: Column(
        children: [
          _DashboardTabs(selected: _tab, onSelect: _selectTab),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                DashboardSummaryTab(
                  loadReport: widget.loadReport,
                  onOpenReports: () => _selectTab(_reportsTab),
                ),
                if (_reportsVisited)
                  ReportsTab(loadReports: widget.loadReports)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pemilih tab "Ringkasan" / "Laporan" di bawah header admin.
class _DashboardTabs extends StatelessWidget {
  const _DashboardTabs({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Ringkasan',
              icon: Icons.dashboard_outlined,
              selected: selected == 0,
              onTap: () => onSelect(0),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _TabButton(
              label: 'Laporan',
              icon: Icons.bar_chart_rounded,
              selected: selected == 1,
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.forest;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.moss : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? AppColors.moss : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Isi tab Ringkasan: tugas tertunda, statistik, pendapatan, inventaris,
/// transaksi terbaru, dan aksi cepat.
class DashboardSummaryTab extends StatefulWidget {
  const DashboardSummaryTab({
    super.key,
    this.loadReport,
    required this.onOpenReports,
  });

  final Future<ReportData> Function()? loadReport;

  /// Membuka tab Laporan pada halaman yang sama.
  final VoidCallback onOpenReports;

  @override
  State<DashboardSummaryTab> createState() => _DashboardSummaryTabState();
}

class _DashboardSummaryTabState extends State<DashboardSummaryTab> {
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
        padding: const EdgeInsets.only(top: AppSpacing.md),
        children: [
          ResponsiveFrame(
            maxWidth: 960,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
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
                // Tugas mendesak lebih dulu: pengajuan yang menunggu
                // verifikasi ditampilkan sebelum statistik.
                if (summary.pending > 0) ...[
                  _PendingBanner(
                    count: summary.pending,
                    onTap: () => _openRentals(status: RentalStatus.pending),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _HeroCard(summary: summary),
                const SizedBox(height: AppSpacing.lg),
                _StatGrid(
                  summary: summary,
                  onOpen: (status) => _openRentals(status: status),
                ),
                const SizedBox(height: AppSpacing.lg),
                _RevenueCard(summary: summary),
                const SizedBox(height: AppSpacing.lg),
                _InventoryStrip(totalItems: _totalItems),
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
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(
                  onReports: widget.onOpenReports,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pita tugas: jumlah pengajuan yang menunggu verifikasi.
///
/// Hanya muncul saat ada pengajuan pending, sehingga dashboard langsung
/// menuntun admin ke pekerjaan yang harus diselesaikan lebih dulu.
class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pendingBg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 20,
                  color: AppColors.warningText,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count pengajuan menunggu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warningText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verifikasi agar stok dan jadwal sewa akurat.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warningText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.warningText,
              ),
            ],
          ),
        ),
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
          colors: [AppColors.forest, AppColors.pine],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total pendapatan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.sageLight,
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
        color: AppColors.sage.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.sageLight),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.sageLight,
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
                    color: AppColors.textSecondary,
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
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.moss, size: 20),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
