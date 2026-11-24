import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/category_strip.dart';
import '../../widgets/forest_header.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'item_detail_screen.dart';
import 'widgets/item_card.dart';

/// Layar beranda customer: sapaan, pencarian, kategori, dan rekomendasi.
///
/// Beranda sengaja tidak memuat banner promosi; fokusnya adalah discovery
/// cepat menuju Katalog dan Detail Barang.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenProfile});

  /// Mengalihkan ke tab Profil pada shell customer.
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _previewCount = 6;

  List<Category> _categories = const [];
  List<Item> _items = const [];
  bool _loading = true;
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
      final services = AppScope.read(context);
      final results = await Future.wait([
        services.catalog.categories(),
        services.catalog.items(page: 1, limit: _previewCount),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<Category>;
        _items = (results[1] as dynamic).items as List<Item>;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Beranda error: $error');
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat memuat beranda.';
        _loading = false;
      });
    }
  }

  void _openCatalog({int? categoryId, bool autofocus = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CatalogScreen(
          autofocusSearch: autofocus,
          initialCategoryId: categoryId,
        ),
      ),
    );
  }

  void _openDetail(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemDetailScreen(initialItem: item),
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
    final user = AuthScope.maybeOf(context)?.user;
    final cart = CartScope.of(context);
    final name = user?.nama.split(' ').first ?? 'Sobat CAKU';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.forest,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              child: ForestHeader(
                hero: true,
                height: 200,
                eyebrow: 'Halo, $name',
                title: 'Siap berpetualang?',
                subtitle: 'Perlengkapan camping siap menemani perjalananmu.',
                actions: [
                  // Keranjang dan Profil berdampingan di kanan agar konsisten
                  // dengan header Katalog dan Sewa.
                  const Spacer(),
                  ForestHeaderAction(
                    icon: Icons.shopping_cart_outlined,
                    tooltip: 'Keranjang',
                    badgeCount: cart.totalQuantity,
                    onTap: _openCart,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ForestHeaderAction(
                    icon: Icons.person_outline_rounded,
                    tooltip: 'Profil',
                    onTap: widget.onOpenProfile,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchTrigger(onTap: () => _openCatalog(autofocus: true)),
                  const SizedBox(height: AppSpacing.xl),
                  if (_categories.isNotEmpty) ...[
                    const SectionHeader(title: 'Kategori'),
                    const SizedBox(height: AppSpacing.md),
                    CategoryStrip(
                      categories: _categories,
                      padding: EdgeInsets.zero,
                      onSelect: (id) => _openCatalog(categoryId: id),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  SectionHeader(
                    title: 'Rekomendasi',
                    actionLabel: 'Lihat semua',
                    onAction: () => _openCatalog(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildGrid(),
                  const SizedBox(height: AppSpacing.xl),
                  const _PickupNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_loading) {
      return ItemGrid(
        itemCount: _previewCount,
        itemBuilder: (_, _) => const ItemCardSkeleton(),
      );
    }

    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if (_items.isEmpty) {
      return EmptyView(
        icon: Icons.terrain_rounded,
        title: 'Belum ada perlengkapan',
        message: 'Coba muat ulang nanti.',
        actionLabel: 'Muat ulang',
        onAction: _load,
      );
    }

    return ItemGrid(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ItemCard(
          key: ValueKey(item.id),
          item: item,
          onTap: () => _openDetail(item),
        );
      },
    );
  }
}

class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.moss, size: 21),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Cari perlengkapan camping...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
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

/// Pengingat bahwa pengambilan barang dilakukan langsung di lokasi.
class _PickupNote extends StatelessWidget {
  const _PickupNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.forestSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 20,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ambil langsung di lokasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Barang diambil di lokasi penyewaan CAKU sesuai jadwal sewa '
                  'yang disetujui. Tidak ada pengiriman ke alamat.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
