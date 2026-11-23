import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/state_views.dart';
import 'catalog_screen.dart';
import 'item_detail_screen.dart';
import 'widgets/item_card.dart';
import 'cart_screen.dart';

/// Layar beranda customer: sapaan, pencarian, hero, kategori, dan rekomendasi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        services.catalog.items(page: 1, limit: 8),
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.maybeOf(context)?.user;
    final cart = CartScope.of(context);
    final name = user?.nama.split(' ').first ?? 'Sobat CAKU';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.forest,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.xxl,
            ),
            children: [
              _Header(name: name, cartCount: cart.totalQuantity, onCart: _openCart),
              const SizedBox(height: AppSpacing.lg),
              _SearchTrigger(onTap: () => _openCatalog(autofocus: true)),
              const SizedBox(height: AppSpacing.lg),
              _HeroBanner(onTap: () => _openCatalog()),
              const SizedBox(height: AppSpacing.xl),
              if (_categories.isNotEmpty) ...[
                Text('Kategori', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ActionChip(
                        label: Text(category.nama),
                        onPressed: () => _openCatalog(categoryId: category.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rekomendasi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_loading)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    mainAxisExtent: 260,
                  ),
                  itemBuilder: (_, _) => const ItemCardSkeleton(),
                )
              else if (_error != null)
                ErrorView(message: _error!, onRetry: _load)
              else if (_items.isEmpty)
                EmptyView(
                  icon: Icons.terrain_rounded,
                  title: 'Belum ada perlengkapan',
                  message: 'Coba muat ulang nanti.',
                  actionLabel: 'Muat ulang',
                  onAction: _load,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    mainAxisExtent: 260,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () => _openDetail(item),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.cartCount,
    required this.onCart,
  });

  final String name;
  final int cartCount;
  final VoidCallback onCart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Siap berpetualang?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onCart,
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Keranjang',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: AppColors.textOnOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.controlBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cari perlengkapan camping...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'asset/onboarding-1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppColors.forest),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC1F1A14)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Siapkan Petualanganmu!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: 180,
                    child: FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.forest,
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Text('Jelajahi Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}