import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_scope.dart';
import '../../state/cart_controller.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/date_field.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';
import 'checkout_screen.dart';

/// Keranjang sisi klien. Tidak ada endpoint keranjang di backend, sehingga
/// isi keranjang disimpan di aplikasi sampai pengajuan sewa dikirim.
class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    this.onBrowse,
    this.onRentalCreated,
    this.initialStart,
    this.initialEnd,
  });

  final VoidCallback? onBrowse;
  final VoidCallback? onRentalCreated;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const int _maxDaysAhead = 366;

  DateTime? _start;
  DateTime? _end;
  String? _startError;
  String? _endError;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  int get _days {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return 0;
    return Formatters.daysBetween(start, end);
  }

  bool get _hasStockIssue {
    final cart = CartScope.of(context);
    for (final line in cart.lines) {
      if (line.quantity > line.item.stok) return true;
    }
    return false;
  }

  bool get _canCheckout {
    final cart = CartScope.of(context);
    if (cart.isEmpty) return false;
    if (_start == null || _end == null) return false;
    if (_days < 1) return false;
    if (_hasStockIssue) return false;
    return true;
  }

  Future<void> _pickStart() async {
    final today = Formatters.dateOnly(DateTime.now());
    final last = today.add(const Duration(days: _maxDaysAhead));
    var initial = _start ?? today;
    if (initial.isBefore(today)) initial = today;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: last,
      helpText: 'Pilih tanggal mulai sewa',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _start = picked;
      _startError = null;
      if (_end == null || _end!.isBefore(picked)) {
        _end = picked;
        _endError = null;
      }
    });
  }

  Future<void> _pickEnd() async {
    final today = Formatters.dateOnly(DateTime.now());
    var first = _start ?? today;
    if (first.isBefore(today)) first = today;
    final last = first.add(const Duration(days: _maxDaysAhead));
    var initial = _end ?? first;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: 'Pilih tanggal selesai sewa',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _end = picked;
      _endError = null;
    });
  }

  Future<void> _openCheckout(BuildContext context) async {
    final today = Formatters.dateOnly(DateTime.now());
    String? startError;
    String? endError;

    if (_start == null) {
      startError = 'Pilih tanggal mulai sewa.';
    } else if (_start!.isBefore(today)) {
      startError = 'Tanggal mulai tidak boleh sebelum hari ini.';
    }

    if (_start != null && _end == null) {
      endError = 'Pilih tanggal selesai sewa.';
    } else if (_start != null && _end != null && _end!.isBefore(_start!)) {
      endError = 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }

    setState(() {
      _startError = startError;
      _endError = endError;
    });

    if (startError != null || endError != null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          onRentalCreated: widget.onRentalCreated,
          initialStart: _start,
          initialEnd: _end,
        ),
      ),
    );
  }

  Future<void> _confirmRemove(CartLine line) async {
    final cart = CartScope.read(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus dari keranjang?',
      message:
          '${line.item.nama} akan dihapus dari keranjang. Kamu bisa '
          'menambahkannya lagi dari katalog.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    cart.remove(line.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final isEmpty = cart.isEmpty;

    return Scaffold(
      appBar: CakuAppBar(title: 'Keranjang', showBack: true),
      body: isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Keranjang masih kosong',
              message:
                  'Pilih perlengkapan camping dari katalog, lalu atur jumlah '
                  'sewa di halaman ini.',
              actionLabel: 'Jelajahi Perlengkapan',
              onAction: widget.onBrowse ?? () => Navigator.maybePop(context),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                ResponsiveFrame(
                  maxWidth: 640,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RentalDateCard(
                        start: _start,
                        end: _end,
                        startError: _startError,
                        endError: _endError,
                        onPickStart: _pickStart,
                        onPickEnd: _pickEnd,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final line in cart.lines) ...[
                        _CartLineCard(
                          line: line,
                          onIncrement: () {
                            final added = cart.increment(line.item.id);
                            if (!added) {
                              AppSnack.info(
                                context,
                                'Jumlah sudah mencapai stok tersedia '
                                '(${line.item.stok} unit).',
                              );
                            }
                          },
                          onDecrement: () => cart.decrement(line.item.id),
                          onRemove: () => _confirmRemove(line),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _SummaryCard(
                        days: _days,
                        totalUnit: cart.totalQuantity,
                        totalPerDay: cart.totalPerDay,
                      ),
                      if (_hasStockIssue) ...[
                        const SizedBox(height: AppSpacing.md),
                        const InlineNotice(
                          message:
                              'Jumlah melebihi stok tersedia. Kurangi jumlah.',
                          tone: NoticeTone.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalInfo = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _days > 0
                              ? 'Total estimasi ($_days hari)'
                              : 'Total per hari',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          Formatters.rupiah(
                            _days > 0
                                ? cart.totalPerDay * _days
                                : cart.totalPerDay,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest,
                          ),
                        ),
                      ],
                    );

                    final checkoutButton = PrimaryButton(
                      label: 'Lanjutkan Checkout',
                      icon: Icons.arrow_forward_rounded,
                      expand: false,
                      onPressed: _canCheckout
                          ? () => _openCheckout(context)
                          : null,
                    );

                    // Di ponsel sempit tombol dan total tidak muat sebaris,
                    // jadi tombol diletakkan di bawah total.
                    if (constraints.maxWidth < 360) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          totalInfo,
                          const SizedBox(height: AppSpacing.sm),
                          checkoutButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: totalInfo),
                        const SizedBox(width: AppSpacing.md),
                        checkoutButton,
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _RentalDateCard extends StatelessWidget {
  const _RentalDateCard({
    required this.start,
    required this.end,
    required this.startError,
    required this.endError,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime? start;
  final DateTime? end;
  final String? startError;
  final String? endError;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Periode Sewa',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DateField(
                label: 'Tanggal Mulai',
                value: start,
                placeholder: 'Pilih tanggal',
                error: startError,
                onTap: onPickStart,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DateField(
                label: 'Tanggal Selesai',
                value: end,
                placeholder: 'Pilih tanggal',
                error: endError,
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.days,
    required this.totalUnit,
    required this.totalPerDay,
  });

  final int days;
  final int totalUnit;
  final double totalPerDay;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: 'Ringkasan',
      children: [
        InfoRow(
          label: 'Durasi',
          value: days > 0 ? '$days hari' : 'Belum dipilih',
        ),
        InfoRow(label: 'Total unit', value: '$totalUnit unit'),
        InfoRow(
          label: 'Total estimasi biaya',
          value: days > 0 ? Formatters.rupiah(totalPerDay * days) : '—',
          emphasize: true,
        ),
      ],
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = line.item;
    final stockWarning = line.quantity > item.stok;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 54,
                child: ItemImage(imageUrl: item.imageUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${Formatters.rupiah(item.hargaSewaHarian)}/hari',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forest,
                      ),
                    ),
                    if (stockWarning) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Stok tidak mencukupi',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (item.originalPrice == null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Harga asli belum diisi. Barang belum dapat disewa.',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: 'Hapus dari keranjang',
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtotal per hari',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      Formatters.rupiah(line.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              QuantityStepper(
                value: line.quantity,
                max: item.stok,
                compact: true,
                semanticLabel: 'jumlah ${item.nama}',
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
