import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/rental.dart';
import '../state/app_scope.dart';
import '../widgets/app_snack.dart';
import '../widgets/caku_app_bar.dart';
import '../widgets/layout.dart';
import '../widgets/rental_card.dart';
import '../widgets/state_views.dart';
import 'rental_detail_screen.dart';

/// Daftar transaksi sewa. Customer melihat miliknya sendiri; mode admin
/// menampilkan seluruh transaksi untuk diproses.
class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key, this.adminMode = false, this.initialStatus});

  final bool adminMode;

  /// Filter status awal, dipakai saat dibuka dari kartu dashboard admin.
  final RentalStatus? initialStatus;

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  static const int _pageSize = 10;

  List<Rental> _rentals = const [];
  RentalStatus? _status;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final result = await AppScope.read(context).rentals.list(
        status: _status?.apiValue,
        page: reset ? 1 : _page + 1,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _page = reset ? 1 : _page + 1;
        _rentals = reset ? result.rentals : [..._rentals, ...result.rentals];
        _hasNext = result.pagination?.hasNext ?? false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (reset) {
        setState(() => _error = error.message);
      } else {
        AppSnack.error(context, error.message);
      }
    } catch (error) {
      debugPrint('Daftar rental error: $error');
      if (!mounted) return;
      if (reset) {
        setState(() => _error = 'Terjadi kesalahan saat memuat pesanan.');
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
    return Scaffold(
      appBar: CakuAppBar(
        title: widget.adminMode ? 'Kelola penyewaan' : 'Riwayat sewa',
        subtitle: widget.adminMode
            ? 'Verifikasi dan proses pesanan'
            : 'Pantau status pengajuan Anda',
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        color: AppColors.forest,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                children: [
                  _StatusPill(
                    label: 'Semua',
                    selected: _status == null,
                    onTap: () => _selectStatus(null),
                  ),
                  ...RentalStatus.values.map(
                    (status) => _StatusPill(
                      label: status.label,
                      selected: _status == status,
                      onTap: () => _selectStatus(status),
                    ),
                  ),
                ],
              ),
            ),
            ResponsiveFrame(
              maxWidth: 720,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const ListSkeleton(count: 4, itemHeight: 150);
    }

    if (_error != null) {
      return ErrorView(message: _error!, onRetry: () => _load(reset: true));
    }

    if (_rentals.isEmpty) {
      return EmptyView(
        icon: Icons.receipt_long_rounded,
        title: widget.adminMode
            ? 'Belum ada transaksi'
            : 'Belum ada pengajuan sewa',
        message: widget.adminMode
            ? 'Transaksi akan muncul di sini setelah customer mengajukan sewa.'
            : 'Ajukan sewa dari katalog, lalu pantau statusnya di halaman ini.',
        actionLabel: _status == null ? null : 'Lihat semua status',
        onAction: _status == null ? null : () => _selectStatus(null),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final rental in _rentals) ...[
          RentalCard(
            key: ValueKey(rental.id),
            rental: rental,
            showCustomer: widget.adminMode,
            onTap: () => _openDetail(rental),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (_hasNext)
          TextButton.icon(
            onPressed: _loadingMore ? null : () => _load(reset: false),
            icon: _loadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more_rounded, size: 18),
            label: Text(_loadingMore ? 'Memuat...' : 'Muat lebih banyak'),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              '${_rentals.length} pesanan ditampilkan',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.forest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
