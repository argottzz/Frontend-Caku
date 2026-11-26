import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/rental.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/return_rental_dialog.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Detail satu transaksi sewa. Customer dapat membatalkan pengajuan pending;
/// admin dapat memproses status dan pengembalian.
class RentalDetailScreen extends StatefulWidget {
  const RentalDetailScreen({super.key, required this.rentalId});

  final int rentalId;

  @override
  State<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends State<RentalDetailScreen> {
  Rental? _rental;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rental = await AppScope.read(
        context,
      ).rentals.detail(widget.rentalId);
      if (!mounted) return;
      setState(() => _rental = rental);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (error) {
      debugPrint('Detail rental error: $error');
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat pesanan.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(
    RentalStatus next, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      final updated = await AppScope.read(
        context,
      ).rentals.updateStatus(widget.rentalId, next);
      if (!mounted) return;
      setState(() => _rental = updated);
      AppSnack.success(context, 'Status pesanan diperbarui.');
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
      await _load();
    } catch (error) {
      debugPrint('Ubah status error: $error');
      if (mounted) {
        AppSnack.error(context, 'Gagal memperbarui status pesanan.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus transaksi?',
      message: 'Pengajuan yang dihapus tidak dapat dikembalikan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await AppScope.read(context).rentals.cancel(widget.rentalId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Batal rental error: $error');
      if (mounted) {
        AppSnack.error(context, 'Pengajuan gagal dibatalkan.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _processReturn(Rental rental) async {
    final input = await showReturnRentalDialog(
      context,
      tanggalMulai: rental.tanggalMulai,
    );
    if (input == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await AppScope.read(context).rentals.processReturn(
        id: rental.id,
        tanggalKembaliAktual: input.tanggalKembali,
        kondisiPengembalian: input.kondisi,
        catatanPengembalian: input.catatan,
      );
      if (!mounted) return;
      setState(() => _rental = result);
      if (result.penggantianPerluDitinjau) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Pengembalian diproses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengembalian berhasil diproses, tetapi sebagian barang '
                  'belum memiliki harga asli sehingga penggantian perlu '
                  'ditinjau admin.',
                ),
                if (result.itemTanpaHargaAsli.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Barang tanpa harga asli:'),
                  ...result.itemTanpaHargaAsli.map(
                    (item) => Text('• ${item.namaItem} (${item.jumlah} unit)'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      } else if (result.perluPenyesuaianStok) {
        AppSnack.info(
          context,
          'Pengembalian dicatat. Sesuaikan stok karena kondisi '
          '${input.kondisi.toLowerCase()}.',
        );
      } else {
        AppSnack.success(context, 'Pengembalian berhasil diproses.');
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Proses kembali error: $error');
      if (mounted) AppSnack.error(context, 'Gagal memproses pengembalian.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _completeReplacement() async {
    final rental = _rental;
    if (rental == null || rental.penggantian == null) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Tandai penggantian selesai?',
      message:
          'Kewajiban penggantian barang hilang akan ditandai selesai. '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Tandai Selesai',
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await AppScope.read(context).rentals.completeReplacement(rental.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      AppSnack.success(context, 'Kewajiban penggantian selesai dicatat.');
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Selesaikan penggantian error: $error');
      if (mounted) AppSnack.error(context, 'Gagal memperbarui penggantian.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openProof(String url) {
    if (url.trim().isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ItemImage(
                imageUrl: url,
                fit: BoxFit.contain,
                borderRadius: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthScope.of(context).isAdmin;
    return Scaffold(
      appBar: CakuAppBar(
        title: 'Detail Transaksi',
        showBack: true,
      ),
      body: _buildBody(isAdmin),
      bottomNavigationBar: _rental == null
          ? null
          : _ActionBar(
              rental: _rental!,
              isAdmin: isAdmin,
              busy: _busy,
              onCancel: _cancel,
              onApprove: () => _changeStatus(
                RentalStatus.approved,
                title: 'Setujui pengajuan?',
                message:
                    'Stok barang akan dikurangi otomatis setelah pengajuan '
                    'disetujui.',
                confirmLabel: 'Setujui',
              ),
              onReject: () => _changeStatus(
                RentalStatus.rejected,
                title: 'Tolak pengajuan?',
                message:
                    'Pengajuan akan ditandai ditolak. Tindakan ini tidak dapat '
                    'dibatalkan.',
                confirmLabel: 'Tolak',
                destructive: true,
              ),
              onStart: () => _changeStatus(
                RentalStatus.ongoing,
                title: 'Mulai masa sewa?',
                message:
                    'Tandai barang sudah diambil customer dan masa sewa '
                    'berjalan.',
                confirmLabel: 'Mulai sewa',
              ),
              onReturn: () => _processReturn(_rental!),
            ),
    );
  }

  Widget _buildBody(bool isAdmin) {
    if (_loading) return const LoadingView(message: 'Memuat pesanan...');
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final rental = _rental!;
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.forest,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveFrame(
            maxWidth: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SummaryCard(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rental.status.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusBadge(status: rental.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Instruksi mengikuti status, tepat di bawah status agar
                    // tidak perlu dicari (desain.md §8.10).
                    _StatusGuidance(rental: rental, isAdmin: isAdmin),
                    if (isAdmin) ...[
                      const Divider(height: AppSpacing.xl),
                      InfoRow(label: 'Penyewa', value: rental.namaUser),
                      InfoRow(label: 'Email', value: rental.emailUser),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Barang yang disewa',
                  children: [
                    if (rental.items.isEmpty)
                      Text(
                        'Rincian barang tidak tersedia.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ...rental.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaItem,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${item.jumlah} × '
                                      '${Formatters.rupiah(item.hargaPerHari)}'
                                      '/hari',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    if (item.originalPriceAtRental != null)
                                      Text(
                                        'Harga asli saat sewa: '
                                        '${Formatters.rupiah(item.originalPriceAtRental!)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                Formatters.rupiah(item.subtotal),
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
                  title: 'Jadwal sewa',
                  children: [
                    InfoRow(
                      label: 'Tanggal mulai',
                      value: Formatters.dateLong(rental.tanggalMulai),
                    ),
                    InfoRow(
                      label: 'Tanggal selesai',
                      value: Formatters.dateLong(rental.tanggalSelesai),
                    ),
                    InfoRow(
                      label: 'Durasi',
                      value: '${rental.durasiHari} hari',
                    ),
                    if (rental.tanggalKembaliAktual != null)
                      InfoRow(
                        label: 'Kembali aktual',
                        value: Formatters.dateLong(
                          rental.tanggalKembaliAktual!,
                        ),
                      ),
                    if (rental.kondisiPengembalian != null)
                      InfoRow(
                        label: 'Kondisi kembali',
                        value: rental.kondisiPengembalian!,
                      ),
                    if (rental.hariTerlambat > 0)
                      InfoRow(
                        label: 'Keterlambatan',
                        value: '${rental.hariTerlambat} hari',
                        valueColor: AppColors.error,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SummaryCard(
                  title: 'Rincian biaya',
                  children: [
                    InfoRow(
                      label: 'Total sewa',
                      value: Formatters.rupiah(rental.totalSewa),
                    ),
                    if (rental.totalDenda > 0)
                      InfoRow(
                        label: 'Denda keterlambatan',
                        value: Formatters.rupiah(rental.totalDenda),
                        valueColor: AppColors.error,
                      ),
                    const Divider(height: AppSpacing.lg),
                    InfoRow(
                      label: 'Total bayar',
                      value: Formatters.rupiah(rental.totalBayar),
                      emphasize: true,
                    ),
                  ],
                ),
                if (rental.penggantian != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryCard(
                    title: 'Penggantian barang hilang',
                    children: [
                      InfoRow(
                        label: 'Total kewajiban',
                        value: Formatters.rupiah(
                          double.tryParse(rental.penggantian!.totalAmount) ?? 0,
                        ),
                        emphasize: true,
                      ),
                      InfoRow(
                        label: 'Status',
                        value: rental.penggantian!.status,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Kewajiban ini berkaitan dengan barang yang hilang '
                        'pada transaksi ini.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (isAdmin && rental.penggantian!.isPending) ...[
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Tandai Selesai',
                          icon: Icons.check_rounded,
                          loading: _busy,
                          onPressed: _busy ? null : _completeReplacement,
                        ),
                      ],
                      if (rental.penggantian!.isCompleted) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Kewajiban penggantian selesai dicatat.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.success),
                        ),
                      ],
                    ],
                  ),
                ],
                if (rental.buktiTransferUrl.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryCard(
                    title: 'Bukti transfer',
                    children: [
                      InkWell(
                        onTap: () => _openProof(rental.buktiTransferUrl),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: ItemImage(
                          imageUrl: rental.buktiTransferUrl,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Ketuk gambar untuk memperbesar.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if ((rental.catatanPengembalian ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SummaryCard(
                    title: 'Catatan pengembalian',
                    children: [
                      Text(
                        rental.catatanPengembalian!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (rental.createdAt != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Diajukan ${Formatters.dateTime(rental.createdAt!)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Instruksi singkat sesuai status transaksi (`desain.md` §8.10).
///
/// Hanya memakai data yang benar-benar tersedia: tanggal mulai untuk status
/// disetujui, tanpa mengarang alamat pengambilan atau menyatakan barang sudah
/// diterima customer.
class _StatusGuidance extends StatelessWidget {
  const _StatusGuidance({required this.rental, required this.isAdmin});

  final Rental rental;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final (tone, icon, title, message) = switch (rental.status) {
      RentalStatus.pending => (
        NoticeTone.warning,
        Icons.hourglass_top_rounded,
        'Menunggu verifikasi',
        isAdmin
            ? 'Periksa bukti transfer, lalu setujui atau tolak pengajuan.'
            : 'Pembayaran sedang diperiksa admin. Status akan berubah '
                  'setelah diverifikasi.',
      ),
      RentalStatus.approved => (
        NoticeTone.success,
        Icons.storefront_outlined,
        'Siap diambil di lokasi',
        'Pembayaran sudah diverifikasi dan penyewaan disetujui. Silakan '
            'datang ke lokasi penyewaan CAKU untuk mengambil barang pada '
            '${Formatters.dateLong(rental.tanggalMulai)}. Barang tidak '
            'dikirim ke alamat.',
      ),
      RentalStatus.ongoing => (
        NoticeTone.info,
        Icons.backpack_outlined,
        'Masa sewa berjalan',
        'Barang sudah diserahkan. Kembalikan paling lambat '
            '${Formatters.dateLong(rental.tanggalSelesai)} agar tidak '
            'dikenakan denda.',
      ),
      RentalStatus.completed => (
        NoticeTone.success,
        Icons.task_alt_rounded,
        'Penyewaan selesai',
        'Terima kasih sudah menyewa di CAKU. Transaksi ini sudah selesai.',
      ),
      RentalStatus.rejected => (
        NoticeTone.error,
        Icons.cancel_outlined,
        'Pengajuan ditolak',
        'Pengajuan ini tidak dapat diproses. Silakan hubungi admin atau '
            'ajukan sewa baru.',
      ),
    };

    return InlineNotice(tone: tone, icon: icon, title: title, message: message);
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.rental,
    required this.isAdmin,
    required this.busy,
    required this.onCancel,
    required this.onApprove,
    required this.onReject,
    required this.onStart,
    required this.onReturn,
  });

  final Rental rental;
  final bool isAdmin;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onStart;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (isAdmin) {
      switch (rental.status) {
        case RentalStatus.pending:
          actions.addAll([
            Expanded(
              child: DangerButton(
                label: 'Tolak',
                onPressed: busy ? null : onReject,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Setujui',
                loading: busy,
                onPressed: onApprove,
              ),
            ),
          ]);
          break;
        case RentalStatus.approved:
          actions.add(
            Expanded(
              child: PrimaryButton(
                label: 'Mulai masa sewa',
                icon: Icons.play_arrow_rounded,
                loading: busy,
                onPressed: onStart,
              ),
            ),
          );
          break;
        case RentalStatus.ongoing:
          actions.add(
            Expanded(
              child: PrimaryButton(
                label: 'Proses pengembalian',
                icon: Icons.assignment_turned_in_rounded,
                loading: busy,
                onPressed: onReturn,
              ),
            ),
          );
          break;
        case RentalStatus.completed:
        case RentalStatus.rejected:
          return const SizedBox.shrink();
      }
    } else if (rental.canCancel) {
      actions.add(
        Expanded(
          child: DangerButton(
            label: 'Hapus Transaksi',
            icon: Icons.delete_outline_rounded,
            loading: busy,
            onPressed: onCancel,
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return SafeArea(
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
        child: Row(children: actions),
      ),
    );
  }
}
