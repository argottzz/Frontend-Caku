import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import '../session_landing.dart';
import 'item_detail_screen.dart';
import 'widgets/item_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<Category> _categories = const [];
  List<Item> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int? _categoryId;
  int _page = 1;
  int _total = 0;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadItems(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await AppScope.read(context).catalog.categories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } on ApiException {
      // Kategori bersifat pelengkap; kegagalan tidak menghalangi katalog.
    }
  }

  Future<void> _loadItems({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final result = await AppScope.read(context).catalog.items(
        search: _searchController.text,
        idKategori: _categoryId,
        page: reset ? 1 : _page + 1,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _page = reset ? 1 : _page + 1;
        _items = reset ? result.items : [..._items, ...result.items];
        _total =
            result.pagination?.total ?? (reset ? result.items.length : _total);
        _hasNext = result.pagination?.hasNext ?? false;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (reset) {
        setState(() => _error = error.message);
      } else {
        AppSnack.error(context, error.message);
      }
    } catch (error) {
      debugPrint('Katalog error: $error');
      if (!mounted) return;
      if (reset) {
        setState(() => _error = 'Terjadi kesalahan saat memuat katalog.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadCategories(), _loadItems(reset: true)]);
  }

  void _onSearchChanged(String _) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadItems(reset: true);
    });
  }

  void _selectCategory(int? id) {
    if (_categoryId == id) return;
    setState(() => _categoryId = id);
    _loadItems(reset: true);
  }

  void _addToCart(Item item) {
    final cart = CartScope.read(context);
    final added = cart.add(item);
    if (added) {
      AppSnack.success(context, '${item.nama} ditambahkan ke keranjang.');
    } else {
      AppSnack.info(
        context,
        'Jumlah di keranjang sudah mencapai stok tersedia.',
      );
    }
  }

  Future<void> _openDetail(Item item) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemDetailScreen(initialItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    final cart = CartScope.of(context);

    return Scaffold(
      appBar: CakuAppBar(
        subtitle: 'Sewa perlengkapan camping',
        actions: [
          UserAvatar(
            initials: user?.initials ?? 'C',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SessionLanding(user: user!),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.forest,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveFrame(
                maxWidth: 960,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: _Header(
                  name: user?.nama.split(' ').first ?? 'Sobat CAKU',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsiveFrame(
                maxWidth: 960,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: _CategoryStrip(
                  categories: _categories,
                  selectedId: _categoryId,
                  onSelect: _selectCategory,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsiveFrame(
                maxWidth: 960,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SectionHeader(
                  title: 'Katalog',
                  subtitle: _loading
                      ? 'Memuat perlengkapan...'
                      : '$_total perlengkapan ditemukan',
                ),
              ),
            ),
            ..._buildContent(cart.quantityFor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(int Function(int itemId) quantityFor) {
    if (_loading) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: ResponsiveFrame(
              maxWidth: 960,
              padding: EdgeInsets.zero,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  mainAxisExtent: 288,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemBuilder: (_, _) => const ItemCardSkeleton(),
              ),
            ),
          ),
        ),
      ];
    }

    if (_error != null) {
      return [
        SliverToBoxAdapter(
          child: ErrorView(
            message: _error!,
            onRetry: () => _loadItems(reset: true),
          ),
        ),
      ];
    }

    if (_items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyView(
            icon: Icons.terrain_rounded,
            title: _searchController.text.isEmpty
                ? 'Belum ada perlengkapan'
                : 'Tidak ada hasil',
            message: _searchController.text.isEmpty
                ? 'Admin belum menambahkan barang untuk disewa. Coba muat ulang nanti.'
                : 'Coba kata kunci lain atau ubah kategori yang dipilih.',
            actionLabel: _searchController.text.isEmpty ? 'Muat ulang' : null,
            onAction: _searchController.text.isEmpty ? _refresh : null,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: ResponsiveFrame(
            maxWidth: 960,
            padding: EdgeInsets.zero,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                mainAxisExtent: 288,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ItemCard(
                  key: ValueKey(item.id),
                  item: item,
                  quantityInCart: quantityFor(item.id),
                  onTap: () => _openDetail(item),
                  onAdd: () => _addToCart(item),
                );
              },
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Center(
            child: _hasNext
                ? TextButton.icon(
                    onPressed: _loadingMore
                        ? null
                        : () => _loadItems(reset: false),
                    icon: _loadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more_rounded, size: 18),
                    label: Text(
                      _loadingMore ? 'Memuat...' : 'Muat lebih banyak',
                    ),
                  )
                : Text(
                    'Semua perlengkapan sudah ditampilkan',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
        ),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.forestDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Siap berpetualang?\nLengkapi alat camping-mu.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textOnDark,
                  fontSize: 22,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Pilih perlengkapan, ajukan tanggal sewa, lalu unggah bukti transfer.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.82),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari tenda, sleeping bag, kompor...',
        prefixIcon: const Icon(Icons.search_rounded, size: 21),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        _CategoryPill(
          label: 'Semua',
          selected: selectedId == null,
          onTap: () => onSelect(null),
        ),
        ...categories.map(
          (category) => _CategoryPill(
            label: category.nama,
            selected: selectedId == category.id,
            onTap: () => onSelect(category.id),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.forest : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper kecil agar format harga konsisten di seluruh layar customer.
String pricePerDay(Item item) =>
    '${Formatters.rupiah(item.hargaSewaHarian)}/hari';
