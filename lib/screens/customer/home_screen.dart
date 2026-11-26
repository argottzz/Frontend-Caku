import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/caku_logo.dart';
import '../../widgets/caku_search_field.dart';
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
/// Beranda adalah satu-satunya halaman dengan header besar (hero); halaman
/// lain memakai AppBar biasa agar tidak berulang.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
                height: 210,
                eyebrow: 'Halo, $name',
                title: 'Siap berpetualang?',
                subtitle: 'Perlengkapan camping siap menemani perjalananmu.',
                actions: [
                  // Logo menandai merek, keranjang selalu di kanan. Profil
                  // tidak diulang karena sudah ada di bottom navigation.
                  const CakuLogoMark(size: 34),
                  const Spacer(),
                  ForestHeaderAction(
                    icon: Icons.shopping_cart_outlined,
                    tooltip: 'Keranjang',
                    badgeCount: cart.totalQuantity,
                    onTap: _openCart,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xl,
                AppSpacing.screen,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CakuSearchField(
                    readOnly: true,
                    onTap: () => _openCatalog(autofocus: true),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (_categories.isNotEmpty) ...[
                    const SectionHeader(title: 'Kategori'),
                    const SizedBox(height: AppSpacing.md),
                    CategoryStrip(
                      categories: _categories,
                      padding: EdgeInsets.zero,
                      onSelect: (id) => _openCatalog(categoryId: id),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  SectionHeader(
                    title: 'Rekomendasi',
                    actionLabel: 'Lihat semua',
                    onAction: () => _openCatalog(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildGrid(),
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
