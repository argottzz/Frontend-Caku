import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/pdf_saver_mobile.dart'
    if (dart.library.html) '../../core/utils/pdf_saver_web.dart';

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
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_filter_bar.dart';
import '../shared/rental_detail_screen.dart';

/// Isi tab Laporan pada [AdminDashboardScreen].
///
/// Urutannya: filter status, filter tanggal, ringkasan hasil filter, lalu
/// daftar transaksi yang dipadatkan agar lebih banyak baris terlihat dalam
/// satu layar.
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

  bool get _hasDateFilter => _start != null || _end != null;

  bool get _hasActiveFilter => _hasDateFilter || _status != null;

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

  /// Menghapus hanya filter tanggal; filter status tetap seperti yang dipilih.
  void _resetDates() {
    setState(() {
      _start = null;
      _end = null;
    });
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

  Future<void> _export() async {
    final data = _data;
    if (data == null) {
      AppSnack.info(context, 'Muat laporan terlebih dahulu.');
      return;
    }
    try {
      final summary = data.ringkasan;
      final rentals = _rentals;
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text(
              'Laporan Transaksi CAKU',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Filter: ${_status?.label ?? 'Semua'}'
              '${_start != null ? ' | Dari: ${Formatters.date(_start!)}' : ''}'
              '${_end != null ? ' | Sampai: ${Formatters.date(_end!)}' : ''}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: const [
                'No',
                'Tanggal Sewa',
                'Jumlah Barang',
                'Total Bayar',
                'Status',
              ],
              data: rentals
                  .map(
                    (r) => [
                      '#${r.id}',
                      '${Formatters.date(r.tanggalMulai)} - ${Formatters.date(r.tanggalSelesai)}',
                      '${r.jumlahItem}',
                      Formatters.rupiah(r.totalBayar),
                      r.status.label,
                    ],
                  )
                  .toList(growable: false),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Ringkasan: ${summary.totalTransaksi} transaksi, '
              'Total sewa ${Formatters.rupiah(summary.totalSewa)}, '
              'Total denda ${Formatters.rupiah(summary.totalDenda)}, '
              'Total pendapatan ${Formatters.rupiah(summary.totalPendapatan)}.',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );
      final bytes = await pdf.save();
      final fileName = 'laporan_caku_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final resultPath = await savePdfFile(bytes, fileName);
      if (!mounted) return;
      AppSnack.success(context, 'PDF berhasil disimpan: $resultPath');
    } catch (error) {
      debugPrint('Ekspor PDF error: $error');
      if (mounted) {
        AppSnack.error(context, 'Gagal membuat PDF laporan.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _data?.ringkasan ?? ReportSummary.empty;
    final total = _data?.pagination?.total ?? _rentals.length;

    return CustomRefreshIndicator(
      onRefresh: () => _load(reset: true),
      builder: (context, child, controller) => Stack(
        children: [
          child,
          Positioned(
            top: controller.value * 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.forest,
                  value: controller.isLoading ? null : controller.value.clamp(0.0, 1.0),
                ),
              ),
            ),
          ),
        ],
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          StatusFilterBar(selected: _status, onSelect: _selectStatus),
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
                _FilterCard(
                  start: _start,
                  end: _end,
                  onPickStart: _pickStart,
                  onPickEnd: _pickEnd,
                  onClearStart: _start == null ? null : _clearStart,
                  onClearEnd: _end == null ? null : _clearEnd,
                  onReset: _hasDateFilter ? _resetDates : null,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading && _data == null)
                  const ListSkeleton(count: 4, itemHeight: 120)
                else if (_error != null && _data == null)
                  ErrorView(message: _error!, onRetry: () => _load(reset: true))
                else ...[
                  _ReportSummaryCard(summary: summary, onExport: _export),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Hasil laporan',
                    subtitle: _rentals.isEmpty
                        ? 'Tidak ada transaksi pada filter ini'
                        : '${_rentals.length} dari $total transaksi',
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
                          _ReportRentalCard(
                            key: ValueKey(rental.id),
                            rental: rental,
                            onTap: () => _openDetail(rental),
                          ),
                          const SizedBox(height: AppSpacing.sm),
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

/// Kartu filter tanggal. Tombol Reset hanya tampil saat tanggal dipilih.
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
    final chips = [
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
    ];

    return SummaryCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filter laporan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onReset != null)
              TextButton(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  chips[0],
                  const SizedBox(height: AppSpacing.sm),
                  chips[1],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: chips[0]),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: chips[1]),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Filter berdasarkan tanggal mulai sewa. Kosongkan tanggal sampai '
          'untuk melihat data hingga terbaru.',
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
    final selected = value != null;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: selected ? AppColors.forest : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  selected
                      ? '$label: ${Formatters.date(value!)}'
                      : '$label tanggal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (onClear != null)
                InkWell(
                  onTap: onClear,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs),
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu hasil kalkulasi filter: berlatar hijau lembut agar berbeda dari
/// kartu input di atasnya.
class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({required this.summary, required this.onExport});

  final ReportSummary summary;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.forestSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.sage),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ringkasan laporan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onExport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.forest,
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: AppColors.moss),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: const Text(
                  'Ekspor PDF',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
        ],
      ),
    );
  }
}

/// Kartu transaksi ringkas untuk daftar hasil filter: nomor & status, tanggal
/// sewa & jumlah barang, lalu total bayar. Identitas penyewa hanya tampil di
/// halaman detail.
class _ReportRentalCard extends StatelessWidget {
  const _ReportRentalCard({
    super.key,
    required this.rental,
    required this.onTap,
  });

  final Rental rental;
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
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan #${rental.id}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(status: rental.status, dense: true),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${Formatters.date(rental.tanggalMulai)} – '
                      '${Formatters.date(rental.tanggalSelesai)} • '
                      '${rental.jumlahItem} jenis barang',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total bayar: ${Formatters.rupiah(rental.totalBayar)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
