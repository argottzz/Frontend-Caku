import 'package:flutter/material.dart';

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
import '../../widgets/form_widgets.dart';
import '../../widgets/image_source_field.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import '../rental_detail_screen.dart';

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
  bool _submitting = false;
  String? _startError;
  String? _endError;
  String? _proofError;
  String? _formError;

  int get _days {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return 0;
    return Formatters.daysBetween(start, end);
  }

  double _totalPerDay(List<CartLine> lines) =>
      lines.fold(0, (total, line) => total + line.subtotal);

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

    final proofError = _proof == null ? 'Bukti transfer wajib diunggah.' : null;

    setState(() {
      _startError = startError;
      _endError = endError;
      _proofError = proofError;
      _formError = cart.isEmpty
          ? 'Keranjang kosong. Pilih perlengkapan terlebih dahulu.'
          : null;
    });

    if (startError != null ||
        endError != null ||
        proofError != null ||
        cart.isEmpty) {
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
        buktiTransfer: _proof!,
      );

      cart.clear();
      widget.onRentalCreated?.call();
      if (!mounted) return;

      AppSnack.success(context, 'Pengajuan sewa berhasil dikirim.');
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => RentalDetailScreen(rentalId: rental.id),
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
      appBar: CakuAppBar(
        title: 'Checkout',
        subtitle: 'Info penyewa, periode, dan pembayaran',
        showBack: true,
      ),
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
                SummaryCard(
                  title: 'Info Penyewa & Periode',
                  children: [
                    InfoRow(
                      label: 'Nama',
                      value: AuthScope.maybeOf(context)?.user?.nama ?? '-',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DateField(
                      label: 'Tanggal Mulai',
                      value: _start,
                      placeholder: 'Pilih tanggal mulai',
                      error: _startError,
                      onTap: _pickStart,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DateField(
                      label: 'Tanggal selesai',
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
                    ImageSourceField(
                      label: 'Bukti transfer',
                      required: true,
                      value: _proof,
                      aspectRatio: 4 / 3,
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
                    if (_proofError != null) ...[
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
                    const InlineNotice(
                      message:
                          'Unggah bukti transfer sesuai total sewa. Admin akan '
                          'memverifikasi pengajuan sebelum masa sewa dimulai.',
                      icon: Icons.receipt_long_outlined,
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
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.error,
  });

  final String label;
  final DateTime? value;
  final String placeholder;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final borderColor = error == null ? AppColors.border : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label, required: true),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: value == null ? AppColors.gray : AppColors.forest,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value == null ? placeholder : Formatters.dateLong(value!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: value == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: AppColors.gray,
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
