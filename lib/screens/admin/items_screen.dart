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
import '../../widgets/category_strip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/item_image.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';
import 'item_form_screen.dart';

/// Daftar barang admin: cari, filter kategori, tambah, ubah, hapus.
///
/// Kategori hanya bisa dibaca dari API (tidak ada CRUD kategori), sehingga
/// layar ini tidak menyediakan pengelolaan kategori.
class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  Timer? _debounce;

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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await AppScope.read(context).catalog.categories();
      if (!mounted) return;
      setState(() => _categories = categories);
    } on ApiException {
      // Kategori bersifat pelengkap.
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
        _total = result.pagination?.total ?? _items.length;
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
      debugPrint('Daftar barang error: $error');
      if (!mounted) return;
      if (reset) {
        setState(() => _error = 'Terjadi kesalahan saat memuat barang.');
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadItems(reset: true);
    });
  }

  void _selectCategory(int? id) {
    if (_categoryId == id) return;
    setState(() => _categoryId = id);
    _loadItems(reset: true);
  }

  Future<void> _openForm({Item? item}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => ItemFormScreen(item: item)),
    );
    if (changed == true && mounted) {
      await _loadItems(reset: true);
    }
  }

  Future<void> _delete(Item item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus barang?',
      message:
          '${item.nama} akan dihapus permanen. Barang yang sudah dipakai '
          'transaksi tidak dapat dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await AppScope.read(context).catalog.deleteItem(item.id);
      if (!mounted) return;
      AppSnack.success(context, '${item.nama} berhasil dihapus.');
      await _loadItems(reset: true);
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Hapus barang error: $error');
      if (mounted) AppSnack.error(context, 'Barang gagal dihapus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CakuAppBar(
        title: 'Kelola barang',
        subtitle: 'Tambah, ubah, dan hapus perlengkapan',
        // ItemsScreen adalah tab shell admin, tetapi juga dibuka sebagai rute
        // dari aksi cepat dashboard; sediakan jalan kembali saat itu terjadi.
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah barang'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.forest,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            ResponsiveFrame(
              maxWidth: 960,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 21),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                    ),
                  ),
                  if (_categories.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    CategoryStrip(
                      categories: _categories,
                      selectedId: _categoryId,
                      padding: EdgeInsets.zero,
                      onSelect: _selectCategory,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(
                    title: 'Daftar barang',
                    subtitle: _loading
                        ? 'Memuat perlengkapan...'
                        : '$_total barang ditemukan',
                  ),
                ],
              ),
            ),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ResponsiveFrame(
          maxWidth: 960,
          padding: EdgeInsets.zero,
          child: const ListSkeleton(count: 4, itemHeight: 110),
        ),
      );
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: () => _loadItems(reset: true),
      );
    }

    if (_items.isEmpty) {
      return EmptyView(
        icon: Icons.inventory_2_outlined,
        title: _searchController.text.isEmpty
            ? 'Belum ada barang'
            : 'Tidak ada hasil',
        message: _searchController.text.isEmpty
            ? 'Tambahkan barang pertama menggunakan tombol di bawah.'
            : 'Coba kata kunci lain atau ubah kategori.',
        actionLabel: _searchController.text.isEmpty ? 'Tambah barang' : null,
        onAction: _searchController.text.isEmpty ? () => _openForm() : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ResponsiveFrame(
        maxWidth: 960,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in _items) ...[
              _AdminItemCard(
                item: item,
                onEdit: () => _openForm(item: item),
                onDelete: () => _delete(item),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_hasNext)
              TextButton.icon(
                onPressed: _loadingMore ? null : () => _loadItems(reset: false),
                icon: _loadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more_rounded, size: 18),
                label: Text(_loadingMore ? 'Memuat...' : 'Muat lebih banyak'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '${_items.length} barang ditampilkan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminItemCard extends StatelessWidget {
  const _AdminItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: ItemImage(imageUrl: item.imageUrl),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15, height: 1.25),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Formatters.rupiah(item.hargaSewaHarian)}/hari',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Stok ${item.stok} · Denda '
                  '${Formatters.rupiah(item.dendaHarian)}/hari',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Ubah barang',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Hapus barang',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
