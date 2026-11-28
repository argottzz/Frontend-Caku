import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
import '../shared/profile_screen.dart';

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
  static const List<String> _bannerAssets = [
    'asset/images/onboarding/onboarding-1.jpg',
    'asset/images/onboarding/onboarding-2.jpg',
    'asset/images/onboarding/onboarding-3.jpg',
  ];

  List<Category> _categories = const [];
  List<Item> _items = const [];
  bool _loading = true;
  String? _error;

  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
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
      body: CustomRefreshIndicator(
        onRefresh: _load,
        builder: (context, child, controller) => Stack(
          children: [
            child,
            Positioned(
              top: controller.value * 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.forest,
                    value: controller.isLoading
                        ? null
                        : controller.value.clamp(0.0, 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const CakuLogoMark(size: 28),
                  ),
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xl,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CakuSearchField(
                    readOnly: true,
                    onTap: () => _openCatalog(autofocus: true),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BannerCarousel(controller: _bannerController, assets: _bannerAssets),
                  const SizedBox(height: AppSpacing.lg),
                  if (_categories.isNotEmpty) ...[
                    const SectionHeader(title: 'Kategori'),
                    const SizedBox(height: AppSpacing.md),
                    CategoryStrip(
                      categories: _categories,
                      padding: EdgeInsets.zero,
                      onSelect: (id) => _openCatalog(categoryId: id),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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


/// Carousel banner di beranda dengan indikator halaman halus.
class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({required this.controller, required this.assets});

  final PageController controller;
  final List<String> assets;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: controller,
            itemCount: assets.length,
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    assets[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'Paket Camping Akhir Pekan — Diskon 15%',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SmoothPageIndicator(
          controller: controller,
          count: assets.length,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.forest,
            dotColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}
