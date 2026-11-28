import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/category_strip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/feedback_dialog.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';

/// Manajemen Kategori untuk admin: daftar, tambah, ubah nama, dan hapus.
///
/// Semua data berasal dari API (`GET/POST/PATCH/DELETE /categories`).
/// Kategori yang masih dipakai barang ditolak backend dengan `409`; halaman
/// ini menampilkan penjelasan tersebut apa adanya, tanpa mengubah data barang.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.loadCategories});

  /// Sumber data opsional untuk pengujian; produksi memakai [CatalogService].
  final Future<List<Category>> Function()? loadCategories;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> _categories = const [];
  bool _loading = true;
  bool _saving = false;
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
      final loader = widget.loadCategories;
      final categories = loader != null
          ? await loader()
          : await AppScope.read(context).catalog.categories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (error) {
      debugPrint('Kategori error: $error');
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat kategori.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm({Category? category}) async {
    final nama = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryFormDialog(category: category),
    );
    if (nama == null || !mounted) return;

    final isEdit = category != null;

    setState(() => _saving = true);

    try {
      final catalog = AppScope.read(context).catalog;
      if (isEdit) {
        await catalog.updateCategory(id: category.id, nama: nama);
      } else {
        await catalog.createCategory(nama: nama);
      }

      if (!mounted) return;
      AppSnack.success(
        context,
        isEdit
            ? 'Kategori berhasil diperbarui.'
            : 'Kategori berhasil ditambahkan.',
      );
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Simpan kategori error: $error');
      if (mounted) {
        AppSnack.error(context, 'Kategori gagal disimpan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(Category category) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus kategori?',
      message:
          '"${category.nama}" akan dihapus permanen. Kategori yang masih '
          'digunakan barang tidak dapat dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _saving = true);

    try {
      await AppScope.read(context).catalog.deleteCategory(category.id);
      if (!mounted) return;
      AppSnack.success(context, 'Kategori berhasil dihapus.');
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;

      // Backend menolak dengan 409 ketika kategori masih dipakai barang.
      // Penjelasan ditampilkan sebagai dialog agar tidak terlewat.
      if (error.isConflict) {
        await showFeedbackDialog(
          context,
          title: 'Kategori tidak dapat dihapus',
          message: error.message,
          success: false,
        );
      } else {
        AppSnack.error(context, error.message);
      }
    } catch (error) {
      debugPrint('Hapus kategori error: $error');
      if (mounted) AppSnack.error(context, 'Kategori gagal dihapus.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CakuAppBar(
        title: 'Manajemen Kategori',
        showBack: Navigator.of(context).canPop(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah kategori'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.forest,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            if (_saving) const LinearProgressIndicator(minHeight: 2),
            ResponsiveFrame(
              maxWidth: 720,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: SectionHeader(
                title: 'Daftar kategori',
                subtitle: _loading
                    ? 'Memuat kategori...'
                    : '${_categories.length} kategori tersedia',
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
          maxWidth: 720,
          padding: EdgeInsets.zero,
          child: const ListSkeleton(count: 4, itemHeight: 68),
        ),
      );
    }

    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if (_categories.isEmpty) {
      return EmptyView(
        icon: Icons.category_outlined,
        title: 'Belum ada kategori',
        message: 'Tambahkan kategori pertama agar barang dapat dikelompokkan.',
        actionLabel: 'Tambah kategori',
        onAction: _saving ? null : () => _openForm(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.bottomClearance,
      ),
      child: ResponsiveFrame(
        maxWidth: 720,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final category in _categories) ...[
              _CategoryRow(
                category: category,
                enabled: !_saving,
                onEdit: () => _openForm(category: category),
                onDelete: () => _delete(category),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kategori yang masih dipakai barang tidak dapat dihapus. '
              'Ubah nama kategori bila hanya ingin memperbaruinya.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris kategori: ikon, nama, tombol ubah, dan tombol hapus.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.forestSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              categoryIconFor(category.nama),
              size: 20,
              color: AppColors.moss,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              category.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14, height: 1.3),
            ),
          ),
          IconButton(
            tooltip: 'Ubah kategori',
            onPressed: enabled ? onEdit : null,
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Hapus kategori',
            onPressed: enabled ? onDelete : null,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog tambah/ubah kategori. Mengembalikan nama yang sudah di-trim,
/// atau `null` bila dibatalkan.
class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});

  final Category? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.category?.nama ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _namaController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Ubah nama kategori' : 'Tambah kategori'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _namaController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Nama kategori',
            hintText: 'Contoh: Peralatan Memasak',
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Nama kategori wajib diisi.';
            if (text.length > 100) {
              return 'Nama kategori maksimal 100 karakter.';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
