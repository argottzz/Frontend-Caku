import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/app_scope.dart';
import '../../state/cart_controller.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';
import 'checkout_screen.dart';

/// Keranjang sisi klien. Tidak ada endpoint keranjang di backend, sehingga
/// isi keranjang disimpan di aplikasi sampai pengajuan sewa dikirim.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.onBrowse, this.onRentalCreated});

  final VoidCallback? onBrowse;
  final VoidCallback? onRentalCreated;

  Future<void> _openCheckout(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(onRentalCreated: onRentalCreated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final isEmpty = cart.isEmpty;

    return Scaffold(
      appBar: CakuAppBar(
        title: 'Keranjang',
        subtitle: isEmpty
            ? 'Belum ada perlengkapan dipilih'
            : '${cart.lines.length} jenis • ${cart.totalQuantity} unit',
      ),
      body: isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Keranjang masih kosong',
              message:
                  'Pilih perlengkapan camping dari katalog, lalu atur jumlah '
                  'sewa di halaman ini.',
              actionLabel: 'Jelajahi katalog',
              onAction: onBrowse ?? () => Navigator.maybePop(context),
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
                          onRemove: () => cart.remove(line.item.id),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      const InlineNotice(
                        message:
                            'Total akhir dihitung setelah Anda memilih tanggal '
                            'sewa di halaman checkout. Stok tetap diverifikasi '
                            'server saat pengajuan dikirim.',
                      ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total per hari',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            Formatters.rupiah(cart.totalPerDay),
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
                      label: 'Checkout',
                      icon: Icons.arrow_forward_rounded,
                      expand: false,
                      onPressed: () => _openCheckout(context),
                    ),
                  ],
                ),
              ),
            ),
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
                height: 72,
                child: ItemImage(imageUrl: item.imageUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaKategori.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus dari keranjang',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
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
