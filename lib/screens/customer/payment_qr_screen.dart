import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/qr_download.dart';
import '../../models/rental.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import 'payment_success_screen.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import 'scan_qr_payment_screen.dart';

/// Layar pembayaran via QR Code untuk sebuah pesanan sewa.
///
/// Menampilkan kode QR dari data transaksi, tombol unduh QR (galeri di mobile,
/// unduhan berkas di web), dan tombol untuk membuka pemindai QR.
class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.rental});

  final Rental rental;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _saving = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (widget.rental.paidAt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const PaymentSuccessScreen(),
          ),
        );
      });
      return;
    }
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPayment();
    });
  }

  Future<void> _checkPayment() async {
    if (!mounted) return;
    try {
      final rental = await AppScope.read(context).rentals.detail(widget.rental.id);
      if (!mounted) return;
      if (rental.paidAt != null ||
          rental.status == RentalStatus.pending) {
        _pollTimer?.cancel();
        _pollTimer = null;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const PaymentSuccessScreen(),
          ),
        );
      }
    } catch (_) {
      // Abaikan error polling; coba lagi pada tick berikutnya.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String get _qrData =>
      widget.rental.qrCodePayload ??
      'CAKU-PAY-${widget.rental.id}-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _downloadQr() async {
    setState(() => _saving = true);
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('QR belum siap.');
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw StateError('Gagal mengambil gambar QR.');
      await saveQrImage(byteData.buffer.asUint8List(), 'QR_CAKU_TRX');
      if (!mounted) return;
      AppSnack.success(
        context,
        kIsWeb
            ? 'QR Code berhasil diunduh.'
            : 'QR Code berhasil disimpan ke galeri.',
      );
    } catch (error) {
      debugPrint('Unduh QR error: $error');
      if (mounted) {
        AppSnack.error(
          context,
          kIsWeb
              ? 'Gagal mengunduh QR Code.'
              : 'Gagal menyimpan QR Code ke galeri.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ScanQrPaymentScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rental = widget.rental;
    return Scaffold(
      appBar: const CakuAppBar(title: 'Pembayaran QR', showBack: true),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            maxWidth: 520,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pesanan #${rental.id}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Total bayar: ${Formatters.rupiah(rental.totalBayar)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: _qrData,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Unduh QR',
                  icon: Icons.download_rounded,
                  loading: _saving,
                  onPressed: _saving ? null : _downloadQr,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Buka Pemindai QR'),
                ),
                const SizedBox(height: AppSpacing.md),
                const InlineNotice(
                  message:
                      'Tunjukkan QR ini ke perangkat lain untuk dipindai, atau '
                      'unduh ke galeri lalu pindai dari HP yang sama.',
                  icon: Icons.info_outline_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
