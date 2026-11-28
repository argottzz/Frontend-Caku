import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';
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

  /// Deskripsi dipotong di [maxLines] sampai pengguna menekan "Baca selengkapnya".
  bool _descExpanded = false;
  static const int _descMaxLines = 3;

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
    final navigator = Navigator.of(context);
    var added = 0;
    for (var index = 0; index < _quantity; index++) {
      if (cart.add(_item)) added++;
    }
    if (added > 0) {
      AppSnack.success(
        context,
        '$added ${_item.nama} ditambahkan ke keranjang.',
        actionLabel: 'Lihat',
        onAction: () {
          navigator.push(
            MaterialPageRoute<void>(builder: (_) => const CartScreen()),
          );
        },
      );
    } else {
      AppSnack.info(
        context,
        'Jumlah di keranjang sudah mencapai stok tersedia.',
      );
    }
  }

  void _openImage() {
    if (_item.imageUrl.trim().isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ItemImage(
                imageUrl: _item.imageUrl,
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

  void _openCart() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final inCart = CartScope.of(context).quantityFor(_item.id);
    final maxAddable = (_item.stok - inCart).clamp(0, _item.stok);
    final canAdd = maxAddable > 0 && _item.originalPrice != null;
    final quantity = canAdd ? _quantity.clamp(1, maxAddable) : 1;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Hero gambar edge-to-edge (4:3 sesuai design.md) dengan
                // tombol kembali melayang.
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: _openImage,
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 3.4,
                          child: ItemImage(
                            imageUrl: _item.imageUrl,
                            borderRadius: 0,
                          ),
                        ),
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0, 0.55, 1],
                                  colors: [
                                    Color(0x6610241F),
                                    Color(0x0010241F),
                                    Color(0xB310241F),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: topInset + AppSpacing.sm,
                          left: AppSpacing.screen,
                          child: _CircleAction(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Kembali',
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Positioned(
                          top: topInset + AppSpacing.sm,
                          right: AppSpacing.screen,
                          child: _CartCircleButton(
                            count: CartScope.of(context).totalQuantity,
                            onTap: _openCart,
                          ),
                        ),
                        if (_refreshing)
                          Positioned(
                            top: topInset + AppSpacing.sm + 52,
                            right: AppSpacing.screen,
                            child: _CircleAction(
                              icon: null,
                              tooltip: 'Memuat detail',
                              onTap: null,
                              child: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Konten utama menumpuk ke atas hero dengan sudut atas membulat.
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -AppRadius.modal),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.modal),
                        ),
                      ),
                      child: ResponsiveFrame(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screen,
                          AppSpacing.xl,
                          AppSpacing.screen,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _KategoriPill(label: _item.namaKategori),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _item.stok > 0
                                            ? AppColors.success
                                            : AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      _item.stok > 0
                                          ? 'Tersedia: ${_item.stok} unit'
                                          : 'Stok habis',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _item.stok > 0
                                                ? AppColors.textSecondary
                                                : AppColors.error,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _item.nama,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.report_gmailerrorred_rounded,
                                    label: 'Denda keterlambatan',
                                    value:
                                        '${Formatters.rupiah(_item.dendaHarian)}/hari',
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.badge_outlined,
                                    label: 'Jaminan sewa',
                                    value: 'Wajib KTP / SIM',
                                  ),
                                ),
                              ],
                            ),
                            if (_item.originalPrice == null) ...[
                              const SizedBox(height: AppSpacing.md),
                              InlineNotice(
                                message:
                                    'Harga asli barang ini belum diisi Admin. '
                                    'Barang belum dapat disewa.',
                                tone: NoticeTone.warning,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deskripsi & Kelengkapan',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _Description(
                                    text: _item.deskripsi,
                                    expanded: _descExpanded,
                                    maxLines: _descMaxLines,
                                    onToggle: () => setState(
                                      () => _descExpanded = !_descExpanded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Ketentuan & Nilai Aset',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Estimasi nilai barang',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                      Text(
                                        _item.originalPrice == null
                                            ? 'Belum diisi'
                                            : Formatters.rupiah(
                                                _item.originalPrice!,
                                              ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '* Digunakan sebagai acuan perhitungan '
                                    'ganti rugi apabila terjadi kerusakan '
                                    'berat atau kehilangan.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _BottomActionBar(
            item: _item,
            quantity: quantity,
            canAdd: canAdd,
            maxAddable: maxAddable,
            onDecrement: canAdd && quantity > 1
                ? () => setState(() => _quantity = quantity - 1)
                : null,
            onIncrement: canAdd && quantity < maxAddable
                ? () => setState(() => _quantity = quantity + 1)
                : null,
            onAdd: _addToCart,
          ),
        ],
      ),
    );
  }
}

/// Tombol lingkaran melayang di atas hero image.
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.child,
  });

  final IconData? icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: child ?? Icon(icon, color: AppColors.forest, size: 20),
          ),
        ),
      ),
    );
  }
}

class _KategoriPill extends StatelessWidget {
  const _KategoriPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.forestSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.forest,
        ),
      ),
    );
  }
}

/// Deskripsi dengan toggle "Baca selengkapnya" hanya bila teks benar-benar
/// melebihi batas baris, sehingga deskripsi pendek tetap tampil utuh.
class _Description extends StatelessWidget {
  const _Description({
    required this.text,
    required this.expanded,
    required this.maxLines,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final int maxLines;
  final VoidCallback onToggle;

  static const TextStyle _style = TextStyle(
    fontSize: 14,
    height: 1.6,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: AppTheme.fontFamily,
  );

  @override
  Widget build(BuildContext context) {
    final body = text.trim().isEmpty
        ? 'Belum ada deskripsi untuk barang ini.'
        : text;

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: body, style: _style),
          maxLines: maxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: _style,
            ),
            if (overflows) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onToggle,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(expanded ? 'Sembunyikan' : 'Baca selengkapnya'),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Bar aksi bawah: total sewa di kiri, stepper jumlah + CTA pill di kanan.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.item,
    required this.quantity,
    required this.canAdd,
    required this.maxAddable,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAdd,
  });

  final Item item;
  final int quantity;
  final bool canAdd;
  final int maxAddable;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.md,
          AppSpacing.screen,
          AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1417322E),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canAdd
                        ? '${Formatters.rupiah(item.hargaSewaHarian)}/hari'
                        : 'Stok habis',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: canAdd
                          ? AppColors.forest
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    canAdd
                        ? '$quantity unit × ${Formatters.rupiah(item.hargaSewaHarian)}'
                        : 'Tidak dapat disewa saat ini',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            QuantityStepper(
              value: quantity,
              max: maxAddable < 1 ? 1 : maxAddable,
              semanticLabel: 'jumlah sewa',
              compact: true,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 56,
              height: 48,
              child: IconButton(
                onPressed: canAdd ? onAdd : null,
                tooltip: canAdd ? 'Tambahkan ke Keranjang' : 'Stok habis',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.disabledSurface,
                  disabledForegroundColor: AppColors.disabledText,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol keranjang bulat di atas hero image dengan badge jumlah.
class _CartCircleButton extends StatelessWidget {
  const _CartCircleButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.forest,
                size: 20,
              ),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.background,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
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

/// Kartu informasi kecil berisi ikon, nilai utama, dan label.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.forest),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
