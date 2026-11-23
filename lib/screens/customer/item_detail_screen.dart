import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/status_badge.dart';
import 'cart_screen.dart';

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
        final max = item.stok < 1 ? 1 : item.stok;
        _quantity = _quantity.clamp(1, max);
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$added ${_item.nama} ditambahkan ke keranjang.'),
            action: SnackBarAction(
              label: 'Lihat Keranjang',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screen,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg + 4),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: ItemImage(
                            imageUrl: _item.imageUrl,
                            borderRadius: 0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                      left: AppSpacing.md,
                      child: Material(
                        color: AppColors.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.controlBorder),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                ResponsiveFrame(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forestSurface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          _item.namaKategori,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _item.nama,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            '${Formatters.rupiah(_item.hargaSewaHarian)}/hari',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          StockBadge(stock: _item.stok),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleLarge,
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
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
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
                  QuantityStepper(
                    value: quantity,
                    max: maxAddable < 1 ? 1 : maxAddable,
                    semanticLabel: 'jumlah sewa',
                    onDecrement: canAdd && quantity > 1
                        ? () => setState(() => _quantity = quantity - 1)
                        : null,
                    onIncrement: canAdd && quantity < maxAddable
                        ? () => setState(() => _quantity = quantity + 1)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      label: canAdd ? 'Tambahkan ke Keranjang' : 'Stok Habis',
                      icon: canAdd ? Icons.add_shopping_cart_rounded : null,
                      onPressed: canAdd ? _addToCart : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}