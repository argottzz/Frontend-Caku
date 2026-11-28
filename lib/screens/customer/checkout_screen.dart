import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_scope.dart';
import '../../state/cart_controller.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/date_field.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/image_source_field.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import 'payment_qr_screen.dart';
import '../shared/rental_detail_screen.dart';

/// Pengajuan sewa: pilih periode, tinjau rincian, unggah bukti transfer, lalu
/// kirim `POST /rentals` sebagai multipart.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.onRentalCreated,
    this.initialStart,
    this.initialEnd,
  });

  /// Dipanggil setelah pengajuan berhasil agar daftar sewa dapat dimuat ulang.
  final VoidCallback? onRentalCreated;
  final DateTime? initialStart;
  final DateTime? initialEnd;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const int _maxDaysAhead = 366;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  DateTime? _start;
  DateTime? _end;
  FileUpload? _proof;
  FileUpload? _identityProof;
  String _paymentMethod = 'transfer';
  bool _submitting = false;
  String? _startError;
  String? _endError;
  String? _proofError;
  String? _identityProofError;
  String? _formError;

  int get _days {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return 0;
    return Formatters.daysBetween(start, end);
  }

  double _totalPerDay(List<CartLine> lines) =>
      lines.fold(0, (total, line) => total + line.subtotal);

  bool get _hasMissingOriginalPrice {
    final cart = CartScope.read(context);
    return cart.lines.any((line) => !line.item.hasOriginalPrice);
  }

  double _penaltyPerDay(List<CartLine> lines) => lines.fold(
    0,
    (total, line) => total + line.item.dendaHarian * line.quantity,
  );

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

  Future<void> _submit() async {
    final cart = CartScope.read(context);
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

    final proofError = _paymentMethod == 'transfer' && _proof == null
        ? 'Bukti transfer wajib diunggah.'
        : null;
    final identityProofError = _identityProof == null
        ? 'Foto jaminan KTP wajib diunggah.'
        : null;

    setState(() {
      _startError = startError;
      _endError = endError;
      _proofError = proofError;
      _identityProofError = identityProofError;
      _formError = cart.isEmpty
          ? 'Keranjang kosong. Pilih perlengkapan terlebih dahulu.'
          : (_hasMissingOriginalPrice
                ? 'Harga asli salah satu barang belum diisi oleh Admin. '
                      'Barang tersebut belum dapat disewa.'
                : null);
    });

    if (startError != null ||
        endError != null ||
        proofError != null ||
        identityProofError != null ||
        cart.isEmpty ||
        _hasMissingOriginalPrice) {
      return;
    }

    setState(() => _submitting = true);
    try {
      final rental = await AppScope.read(context).rentals.create(
        tanggalMulai: _start!,
        tanggalSelesai: _end!,
        items: cart.lines
            .map((line) => (idItem: line.item.id, jumlah: line.quantity))
            .toList(growable: false),
        buktiTransfer: _paymentMethod == 'transfer' ? _proof : null,
        metodePembayaran: _paymentMethod == 'qr' ? 'qr_code' : 'transfer',
        identityImage: _identityProof!,
      );

      cart.clear();
      widget.onRentalCreated?.call();
      if (!mounted) return;

      AppSnack.success(context, 'Pengajuan sewa berhasil dikirim.');
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => _paymentMethod == 'qr'
               ? PaymentQrScreen(rental: rental)
               : RentalDetailScreen(rentalId: rental.id),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _startError = error.fieldError('tanggal_mulai');
        _endError = error.fieldError('tanggal_selesai');
        _proofError = error.fieldError('bukti_transfer');
        _formError = error.fieldError('items') ?? error.message;
      });
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Ajukan sewa error: $error');
      if (mounted) {
        setState(
          () => _formError = 'Pengajuan gagal dikirim. Silakan coba lagi.',
        );
        AppSnack.error(context, 'Pengajuan gagal dikirim. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final lines = cart.lines;
    final totalPerDay = _totalPerDay(lines);
    final penaltyPerDay = _penaltyPerDay(lines);
    final estimatedTotal = totalPerDay * _days;

    return Scaffold(
      appBar: CakuAppBar(title: 'Checkout', showBack: true),
      body: ListView(
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
                if (_formError != null) ...[
                  InlineNotice(
                    message: _formError!,
                    icon: Icons.error_outline_rounded,
                    tone: NoticeTone.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_hasMissingOriginalPrice) ...[
                  InlineNotice(
                    message:
                        'Harga asli salah satu barang belum diisi oleh Admin. '
                        'Barang tersebut belum dapat disewa.',
                    icon: Icons.block_rounded,
                    tone: NoticeTone.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SummaryCard(
                  title: 'Info Penyewa & Periode',
                  children: [
                    InfoRow(
                      label: 'Nama',
                      value: AuthScope.maybeOf(context)?.user?.nama ?? '-',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DateField(
                      label: 'Tanggal Mulai',
                      value: _start,
                      placeholder: 'Pilih tanggal mulai',
                      error: _startError,
                      onTap: _pickStart,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DateField(
                      label: 'Tanggal Selesai',
                      value: _end,
                      placeholder: 'Pilih tanggal selesai',
                      error: _endError,
                      onTap: _pickEnd,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InfoRow(
                      label: 'Durasi',
                      value: _days > 0 ? '$_days hari' : 'Belum dipilih',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InlineNotice(
                      message: _days > 0
                          ? 'Durasi sewa $_days hari, termasuk tanggal mulai '
                                'dan tanggal selesai.'
                          : 'Durasi dihitung termasuk tanggal mulai dan '
                                'tanggal selesai.',
                      icon: Icons.event_available_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Ringkasan Barang',
                  children: [
                    if (lines.isEmpty)
                      Text(
                        'Keranjang kosong. Kembali ke katalog untuk memilih '
                        'perlengkapan.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ...lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.item.nama,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${line.quantity} × '
                                      '${Formatters.rupiah(line.item.hargaSewaHarian)}'
                                      '/hari',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                '${Formatters.rupiah(line.subtotal)}/hari',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Total Pembayaran',
                  children: [
                    InfoRow(
                      label: 'Total per hari',
                      value: Formatters.rupiah(totalPerDay),
                    ),
                    InfoRow(
                      label: 'Durasi',
                      value: _days > 0 ? '$_days hari' : 'Belum dipilih',
                    ),
                    InfoRow(
                      label: 'Denda keterlambatan',
                      value: '${Formatters.rupiah(penaltyPerDay)}/hari',
                    ),
                    const Divider(height: AppSpacing.lg),
                    InfoRow(
                      label: 'Total sewa',
                      value: _days > 0
                          ? Formatters.rupiah(estimatedTotal)
                          : '—',
                      emphasize: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Denda hanya dikenakan bila pengembalian melewati '
                      'tanggal selesai. Jumlah akhir dihitung oleh server.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Pembayaran',
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PaymentMethodTab(
                              label: 'Transfer',
                              selected: _paymentMethod == 'transfer',
                              onTap: () =>
                                  setState(() => _paymentMethod = 'transfer'),
                            ),
                          ),
                          Expanded(
                            child: _PaymentMethodTab(
                              label: 'QR Code',
                              selected: _paymentMethod == 'qr',
                              onTap: () =>
                                  setState(() => _paymentMethod = 'qr'),
                            ),
                          ),
                        ],
                      ),
                    ),
                     const SizedBox(height: AppSpacing.md),
                     if (_paymentMethod == 'qr')
                       const InlineNotice(
                         message:
                             'Setelah pesanan dibuat, kode QR pembayaran akan '
                             'ditampilkan untuk dipindai atau diunduh.',
                         icon: Icons.qr_code_rounded,
                       ),
                     if (_paymentMethod == 'qr')
                       const SizedBox(height: AppSpacing.md),
                     if (_paymentMethod == 'transfer') ...[
                       _BankInfoCard(total: estimatedTotal),
                       const SizedBox(height: AppSpacing.md),
                     ],
                     if (_paymentMethod == 'transfer')
                       ImageSourceField(
label: 'Bukti transfer',
                      required: true,
                      value: _proof,
                      aspectRatio: 4 / 3,
                      compact: true,
                      helper:
                          'JPG, JPEG, PNG, atau WEBP. Maksimal 5 MB. '
                          'Pastikan nominal dan tanggal transfer terlihat.',
                      onChanged: (upload) {
                        setState(() {
                          _proof = upload;
                          _proofError = null;
                        });
                      },
                    ),
                    if (_paymentMethod == 'transfer' && _proofError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _proofError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    if (_paymentMethod == 'transfer')
                      const InlineNotice(
                        message:
                            'Unggah bukti transfer sesuai total sewa. Admin akan '
                            'memverifikasi pengajuan sebelum masa sewa dimulai.',
                        icon: Icons.receipt_long_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Jaminan Identitas',
                  children: [
                    ImageSourceField(
                      label: 'Foto jaminan KTP',
                      required: true,
                      value: _identityProof,
                      aspectRatio: 4 / 3,
                      compact: true,
                      helper:
                          'JPG, JPEG, PNG, atau WEBP. Maksimal 5 MB. '
                          'Pastikan identitas terlihat jelas.',
                      onChanged: (upload) {
                        setState(() {
                          _identityProof = upload;
                          _identityProofError = null;
                        });
                      },
                    ),
                    if (_identityProofError != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _identityProofError!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    const InlineNotice(
                      message:
                          'Foto jaminan KTP wajib diunggah untuk setiap '
                          'transaksi penyewaan.',
                      icon: Icons.badge_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _days > 0 ? 'Total sewa ($_days hari)' : 'Total per hari',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      Formatters.rupiah(
                        _days > 0 ? estimatedTotal : totalPerDay,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              PrimaryButton(
                label: 'Buat Pesanan',
                icon: Icons.send_rounded,
                expand: false,
                loading: _submitting,
                onPressed: (_submitting || _hasMissingOriginalPrice)
                    ? null
                    : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PaymentMethodTab extends StatelessWidget {
  const _PaymentMethodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.forest;
    return Material(
      color: selected ? AppColors.forest : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _BankInfoCard extends StatelessWidget {
  const _BankInfoCard({required this.total});

  final double total;

  static const String _accountNumber = '1234567890';
  static const String _accountName = 'CAKU Outdoor';
  static const String _bank = 'BCA';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.forestSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.sage),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekening Tujuan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$_bank $_accountNumber ($_accountName)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nominal: ${Formatters.rupiah(total)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: _accountNumber),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nomor rekening disalin')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Salin'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
