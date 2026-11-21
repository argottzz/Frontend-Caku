import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.initialItem});

  final Item initialItem;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item = widget.initialItem;
  int _quantity = 1;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _refreshing = true);
    try {
      final item = await AppScope.read(
        context,
      ).catalog.item(widget.initialItem.id);
      if (!mounted) return;
      setState(() {
        _item = item;
        _quantity = _quantity.clamp(1, item.stok < 1 ? 1 : item.stok);
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Detail barang error: $error');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _addToCart() {
    final cart = CartScope.read(context);
    var added = 0;
    for (var index = 0; index < _quantity; index++) {
      if (cart.add(_item)) added++;
    }
    if (added > 0) {
      AppSnack.success(
        context,
        '$added ${_item.nama} ditambahkan ke keranjang.',
      );
    } else {
      AppSnack.info(
        context,
        'Jumlah di keranjang sudah mencapai stok tersedia.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inCart = CartScope.of(context).quantityFor(_item.id);
    final maxAddable = (_item.stok - inCart).clamp(0, _item.stok);
    final canAdd = maxAddable > 0;
    final quantity = canAdd ? _quantity.clamp(1, maxAddable) : 1;

    return Scaffold(
      appBar: CakuAppBar(
        title: 'Detail barang',
        subtitle: _item.namaKategori,
        showBack: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 1.35,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ItemImage(imageUrl: _item.imageUrl, borderRadius: 0),
                if (_refreshing)
                  const Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
          ResponsiveFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _item.namaKategori.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                    StockBadge(stock: _item.stok),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _item.nama,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.rupiah(_item.hargaSewaHarian),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forest,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        '/hari',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (inCart > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InlineNotice(
                    message:
                        '$inCart unit sudah ada di keranjang. Sisa yang dapat ditambahkan: $maxAddable.',
                    icon: Icons.shopping_basket_outlined,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _item.deskripsi.trim().isEmpty
                      ? 'Belum ada deskripsi untuk barang ini.'
                      : _item.deskripsi,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SummaryCard(
                  title: 'Rincian sewa',
                  children: [
                    InfoRow(
                      label: 'Harga sewa',
                      value:
                          '${Formatters.rupiah(_item.hargaSewaHarian)} / hari',
                    ),
                    InfoRow(
                      label: 'Denda keterlambatan',
                      value: '${Formatters.rupiah(_item.dendaHarian)} / hari',
                    ),
                    const Divider(height: AppSpacing.xl),
                    Text(
                      'Durasi sewa dihitung termasuk tanggal mulai dan tanggal selesai. '
                      'Bukti transfer diunggah saat mengajukan sewa, lalu admin memverifikasi pesanan.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(height: 1.55),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah sewa',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Maksimal $maxAddable unit dapat ditambahkan',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    QuantityStepper(
                      value: quantity,
                      max: maxAddable,
                      semanticLabel: 'jumlah sewa',
                      onDecrement: canAdd && quantity > 1
                          ? () => setState(() => _quantity = quantity - 1)
                          : null,
                      onIncrement: canAdd && quantity < maxAddable
                          ? () => setState(() => _quantity = quantity + 1)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
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
                      'Total per hari',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      Formatters.rupiah(
                        _item.hargaSewaHarian * (canAdd ? quantity : 0),
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
                label: canAdd ? 'Tambah ke keranjang' : 'Stok habis',
                icon: canAdd ? Icons.add_shopping_cart_rounded : null,
                expand: false,
                onPressed: canAdd ? _addToCart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
