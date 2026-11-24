import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/category_strip.dart';
import '../../widgets/forest_header.dart';
import '../../widgets/state_views.dart';
import 'cart_screen.dart';
import 'item_detail_screen.dart';
import 'widgets/item_card.dart';

/// Halaman Jelajahi: pusat pencarian, filter kategori, sorting, dan hasil
/// katalog. Dibuka dari Beranda, bukan sebagai tab navigasi.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    this.autofocusSearch = false,
    this.initialSearch,
    this.initialCategoryId,
  });

  final bool autofocusSearch;
  final String? initialSearch;
  final int? initialCategoryId;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
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
  String _sort = 'default';

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
    }
    _categoryId = widget.initialCategoryId;
    _loadCategories();
    _loadItems(reset: true);
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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

  void _resetFilters() {
    _searchController.clear();
    _searchDebounce?.cancel();
    setState(() {
      _categoryId = null;
      _sort = 'default';
    });
    _loadItems(reset: true);
  }

  bool get _hasActiveFilter =>
      _searchController.text.trim().isNotEmpty || _categoryId != null;

  List<Item> get _sortedItems {
    final items = List<Item>.from(_items);
    switch (_sort) {
      case 'price_asc':
        items.sort((a, b) => a.hargaSewaHarian.compareTo(b.hargaSewaHarian));
        break;
      case 'price_desc':
        items.sort((a, b) => b.hargaSewaHarian.compareTo(a.hargaSewaHarian));
        break;
      case 'name_asc':
        items.sort((a, b) => a.nama.compareTo(b.nama));
        break;
      case 'name_desc':
        items.sort((a, b) => b.nama.compareTo(a.nama));
        break;
      default:
        break;
    }
    return items;
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CartScreen()),
    );
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
    final cart = CartScope.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.forest,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                child: ForestHeader(
                  height: 168,
                  eyebrow: 'Katalog CAKU',
                  title: 'Jelajahi',
                  subtitle: 'Temukan perlengkapan untuk petualanganmu.',
                  actions: [
                    if (canPop)
                      ForestHeaderAction(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Kembali',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
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
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SearchField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _onSearchChanged,
                        onClear: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SortButton(
                      value: _sort,
                      onChanged: (value) => setState(() => _sort = value),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CategoryStrip(
                categories: _categories,
                selectedId: _categoryId,
                onSelect: _selectCategory,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _loading
                            ? 'Memuat perlengkapan...'
                            : '$_total perlengkapan ditemukan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (_hasActiveFilter)
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset filter'),
                      ),
                  ],
                ),
              ),
            ),
            ..._buildContent(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_loading) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          sliver: SliverToBoxAdapter(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: itemGridDelegate,
              itemBuilder: (_, _) => const ItemCardSkeleton(),
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

    final items = _sortedItems;

    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Perlengkapan tidak ditemukan',
            message: 'Coba ubah kata kunci atau kategori yang dipilih.',
            actionLabel: 'Reset filter',
            onAction: _resetFilters,
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        sliver: SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: itemGridDelegate,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemCard(
                key: ValueKey(item.id),
                item: item,
                onTap: () => _openDetail(item),
              );
            },
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
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

/// Tombol sorting ringkas: ikon di bar, pilihan di menu.
class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

  static const Map<String, String> _options = {
    'default': 'Urutkan: relevan',
    'price_asc': 'Harga termurah',
    'price_desc': 'Harga termahal',
    'name_asc': 'Nama A-Z',
    'name_desc': 'Nama Z-A',
  };

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = value != 'default';

    return PopupMenuButton<String>(
      tooltip: 'Urutkan',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in _options.entries)
          PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(
                  entry.key == value
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: entry.key == value
                      ? AppColors.moss
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(entry.value),
              ],
            ),
          ),
      ],
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active ? AppColors.moss : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: active ? AppColors.moss : AppColors.border,
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: active ? AppColors.white : AppColors.moss,
        ),
      ),
    );
  }
}
