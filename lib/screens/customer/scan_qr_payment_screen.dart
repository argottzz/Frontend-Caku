import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import 'payment_success_screen.dart';
import '../../widgets/caku_app_bar.dart';

/// Layar pemindai QR pembayaran (mode kamera langsung + mode galeri).
class ScanQrPaymentScreen extends StatefulWidget {
  const ScanQrPaymentScreen({super.key});

  @override
  State<ScanQrPaymentScreen> createState() => _ScanQrPaymentScreenState();
}

class _ScanQrPaymentScreenState extends State<ScanQrPaymentScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _analyzing = false;

  bool _isValid(String value) => value.startsWith('CAKU-PAY-');

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (code == null) return;
    if (!_isValid(code)) {
      if (mounted) AppSnack.error(context, 'QR tidak valid.');
      return;
    }
    await _handlePayment(code);
  }

  Future<void> _handlePayment(String code) async {
    if (_handled) return;
    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    try {
      await AppScope.read(context).rentals.payWithQr(code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PaymentSuccessScreen(),
        ),
      );
    } on ApiException catch (error) {
      _handled = false;
      if (mounted) {
        AppSnack.error(context, error.message);
        await _controller.start();
      }
    } catch (error) {
      _handled = false;
      debugPrint('Bayar QR error: $error');
      if (mounted) {
        AppSnack.error(context, 'Gagal memproses pembayaran.');
        await _controller.start();
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_handled || _analyzing) return;
    // Plugin mobile_scanner untuk web tidak mengimplementasikan analyzeImage()
    // (selalu melempar UnsupportedError), jadi QR dari galeri hanya bisa dibaca
    // di Android/iOS. Di web cukup arahkan pengguna memakai kamera.
    if (kIsWeb) {
      AppSnack.info(
        context,
        'Scan dari galeri hanya tersedia di aplikasi Android/iOS. '
        'Gunakan kamera untuk memindai QR.',
      );
      return;
    }
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    setState(() => _analyzing = true);
    try {
      final result = await _controller.analyzeImage(picked.path);
      if (!mounted) return;
      final code = (result == null || result.barcodes.isEmpty)
          ? null
          : result.barcodes.first.rawValue;
      if (code == null) {
        AppSnack.error(context, 'QR tidak terbaca dari gambar.');
        return;
      }
      if (!_isValid(code)) {
        AppSnack.error(context, 'QR tidak valid.');
        return;
      }
      await _handlePayment(code);
    } catch (error) {
      debugPrint('Analisis gambar QR error: $error');
      if (mounted) AppSnack.error(context, 'Gagal membaca gambar QR.');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Scan QR Pembayaran', showBack: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _analyzing ? null : _pickFromGallery,
                icon: _analyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_rounded),
                label: const Text('Pilih dari Galeri'),
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
