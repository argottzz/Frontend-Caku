import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/item.dart';
import '../../../widgets/item_image.dart';
import '../../../widgets/status_badge.dart';

/// Tinggi area teks di bawah foto, diukur dari isi kartu: padding 12+12,
/// label kategori 17, jarak 4, nama dua baris 36, harga 23, jarak 8, dan
/// badge stok 17 = 137, ditambah sedikit kelonggaran pembulatan subpiksel.
const double _itemCardTextHeight = 140;

/// Lebar kartu yang nyaman dibaca; jumlah kolom dihitung dari angka ini.
const double _itemCardTargetWidth = 200;

/// Grid produk bersama untuk Beranda dan Katalog, sehingga tinggi kartu selalu
/// identik di kedua layar.
///
/// Tinggi kartu dihitung dari lebar kolom, bukan angka tetap. Foto memakai
/// AspectRatio 4:3 sehingga tingginya ikut melebar; dengan tinggi tetap, layar
/// lebar menyisakan ruang teks terlalu kecil dan kartu overflow.
///
/// [gridWidth] adalah lebar area grid setelah padding layar.
/// [textScaler] dipakai agar kartu ikut meninggi saat ukuran teks diperbesar.
SliverGridDelegateWithFixedCrossAxisCount itemGridDelegateFor(
  double gridWidth, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final columns = (gridWidth / _itemCardTargetWidth).round().clamp(2, 8);
  final columnWidth = (gridWidth - AppSpacing.md * (columns - 1)) / columns;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: AppSpacing.md,
    mainAxisSpacing: AppSpacing.md,
    mainAxisExtent: columnWidth * 3 / 4 + textScaler.scale(_itemCardTextHeight),
  );
}

/// Grid produk yang menyesuaikan jumlah kolom dan tinggi kartu dengan lebar
/// area yang tersedia (lihat [itemGridDelegateFor]).
class ItemGrid extends StatelessWidget {
  const ItemGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: itemGridDelegateFor(
          constraints.maxWidth,
          textScaler: MediaQuery.textScalerOf(context),
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                aspectRatio: 4 / 3,
                child: ItemImage(imageUrl: item.imageUrl, borderRadius: 0),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaKategori.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: AppColors.moss,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
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
                      const Spacer(),
                      Text(
                        '${Formatters.rupiah(item.hargaSewaHarian)}/hari',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CompactStockLine(stock: item.stok),
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
        border: Border.all(color: AppColors.border),
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
