import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/rental.dart';
import '../../models/report.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/layout.dart';
import '../../widgets/rental_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_filter_bar.dart';
import '../rental_detail_screen.dart';

/// Isi tab Laporan pada [AdminDashboardScreen].
///
/// Dulu halaman Laporan Pendapatan tersendiri; sekarang header dan pemilih
/// tab disediakan dashboard, sedangkan filter, ringkasan, dan daftar
/// transaksi tetap ditangani di sini.
class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key, this.loadReports});

  /// Sumber data opsional untuk pengujian.
  final Future<ReportData> Function({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int page,
    int limit,
  })?
  loadReports;

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  static const int _pageSize = 10;

  ReportData? _data;
  List<Rental> _rentals = const [];
  int _page = 1;
  bool _hasNext = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  DateTime? _start;
  DateTime? _end;
  RentalStatus? _status;

  bool get _hasActiveFilter =>
      _start != null || _end != null || _status != null;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _rentals = const [];
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final data = widget.loadReports != null
          ? await widget.loadReports!(
              startDate: _start,
              endDate: _end,
              status: _status?.apiValue,
              page: reset ? 1 : _page + 1,
              limit: _pageSize,
            )
          : await AppScope.read(context).reports.summary(
              startDate: _start,
              endDate: _end,
              status: _status?.apiValue,
              page: reset ? 1 : _page + 1,
              limit: _pageSize,
            );
      if (!mounted) return;
      setState(() {
        _page = reset ? 1 : _page + 1;
        _data = data;
        _rentals = reset ? data.rentals : [..._rentals, ...data.rentals];
        _hasNext = data.pagination?.hasNext ?? false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (reset) {
        setState(() => _error = error.message);
      } else {
        AppSnack.error(context, error.message);
      }
    } catch (error) {
      debugPrint('Laporan error: $error');
      if (!mounted) return;
      if (reset) {
        setState(() => _error = 'Terjadi kesalahan saat memuat laporan.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _selectStatus(RentalStatus? status) {
    if (_status == status) return;
    setState(() => _status = status);
    _load(reset: true);
  }

  Future<void> _pickStart() async {
    final today = Formatters.dateOnly(DateTime.now());
    final first = DateTime(2000, 1, 1);
    final last = DateTime(today.year + 1, 12, 31);
    var initial = _start ?? today;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Dari tanggal',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _start = picked;
      if (_end != null && _end!.isBefore(picked)) _end = picked;
    });
    _load(reset: true);
  }

  Future<void> _pickEnd() async {
    final today = Formatters.dateOnly(DateTime.now());
    final first = _start ?? DateTime(2000, 1, 1);
    final last = DateTime(today.year + 1, 12, 31);
    var initial = _end ?? first;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Sampai tanggal',
    );
    if (picked == null || !mounted) return;

    setState(() => _end = picked);
    _load(reset: true);
  }

  void _clearStart() {
    setState(() => _start = null);
    _load(reset: true);
  }

  void _clearEnd() {
    setState(() => _end = null);
    _load(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _start = null;
      _end = null;
      _status = null;
    });
    _load(reset: true);
  }

  Future<void> _openDetail(Rental rental) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RentalDetailScreen(rentalId: rental.id),
      ),
    );
    if (mounted) await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _data?.ringkasan ?? ReportSummary.empty;

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      color: AppColors.forest,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          StatusFilterBar(selected: _status, onSelect: _selectStatus),
          ResponsiveFrame(
            maxWidth: 960,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilterCard(
                  start: _start,
                  end: _end,
                  onPickStart: _pickStart,
                  onPickEnd: _pickEnd,
                  onClearStart: _start == null ? null : _clearStart,
                  onClearEnd: _end == null ? null : _clearEnd,
                  onReset: _hasActiveFilter ? _resetFilters : null,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading && _data == null)
                  const ListSkeleton(count: 4, itemHeight: 120)
                else if (_error != null && _data == null)
                  ErrorView(message: _error!, onRetry: () => _load(reset: true))
                else ...[
                  SummaryCard(
                    title: 'Ringkasan laporan',
                    children: [
                      InfoRow(
                        label: 'Jumlah transaksi',
                        value: '${summary.totalTransaksi}',
                      ),
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
                        'Filter berdasarkan tanggal mulai sewa. Status '
                        'filter memengaruhi ringkasan dan daftar transaksi.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Hasil laporan',
                    subtitle: _rentals.isEmpty
                        ? 'Tidak ada transaksi pada filter ini'
                        : '${_rentals.length} dari '
                              '${_data?.pagination?.total ?? _rentals.length} '
                              'transaksi',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_rentals.isEmpty)
                    EmptyView(
                      compact: true,
                      icon: Icons.receipt_long_rounded,
                      title: 'Tidak ada transaksi',
                      message:
                          'Ubah filter tanggal atau status untuk melihat '
                          'transaksi lain.',
                      actionLabel: _hasActiveFilter ? 'Reset filter' : null,
                      onAction: _hasActiveFilter ? _resetFilters : null,
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final rental in _rentals) ...[
                          RentalCard(
                            key: ValueKey(rental.id),
                            rental: rental,
                            showCustomer: true,
                            onTap: () => _openDetail(rental),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (_hasNext)
                          TextButton.icon(
                            onPressed: _loadingMore
                                ? null
                                : () => _load(reset: false),
                            icon: _loadingMore
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.expand_more_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              _loadingMore ? 'Memuat...' : 'Muat lebih banyak',
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              '${_rentals.length} transaksi ditampilkan',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.start,
    required this.end,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClearStart,
    required this.onClearEnd,
    required this.onReset,
  });

  final DateTime? start;
  final DateTime? end;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onClearStart;
  final VoidCallback? onClearEnd;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Filter laporan',
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _DateChip(
              label: 'Dari',
              value: start,
              onTap: onPickStart,
              onClear: onClearStart,
            ),
            _DateChip(
              label: 'Sampai',
              value: end,
              onTap: onPickEnd,
              onClear: onClearEnd,
            ),
            if (onReset != null)
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Filter berdasarkan tanggal mulai sewa. Tanggal sampai dapat '
          'dikosongkan untuk melihat data sampai terbaru.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: value == null ? AppColors.border : AppColors.forest,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: value == null ? AppColors.textSecondary : AppColors.forest,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              value == null
                  ? '$label tanggal'
                  : '$label: ${Formatters.date(value!)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: onClear,
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
