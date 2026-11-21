import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/item.dart';
import '../../../widgets/item_image.dart';
import '../../../widgets/status_badge.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAdd,
    this.quantityInCart = 0,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final int quantityInCart;

  @override
  Widget build(BuildContext context) {
    final canAdd = item.stok > quantityInCart;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.12,
                child: ItemImage(imageUrl: item.imageUrl),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
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
                      Expanded(
                        child: Text(
                          item.nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.rupiah(item.hargaSewaHarian),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.forest,
                                  ),
                                ),
                                Text(
                                  'per hari',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Tooltip(
                            message: canAdd
                                ? 'Tambah ${item.nama} ke keranjang'
                                : 'Stok tidak mencukupi',
                            child: Material(
                              color: canAdd
                                  ? AppColors.forest
                                  : AppColors.lightGray,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: InkWell(
                                onTap: canAdd ? onAdd : null,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 20,
                                    color: canAdd
                                        ? AppColors.white
                                        : AppColors.gray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCardSkeleton extends StatelessWidget {
  const ItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}

class CompactStockLine extends StatelessWidget {
  const CompactStockLine({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    return stock > 0
        ? StockBadge(stock: stock)
        : const BadgePill(
            label: 'Stok habis',
            foreground: AppColors.error,
            background: AppColors.errorSurface,
            dense: true,
          );
  }
}
