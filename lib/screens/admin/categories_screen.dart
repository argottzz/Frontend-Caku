import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_scope.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/state_views.dart';

/// Kelola Kategori (20). Saat ini read-only: backend hanya menyediakan
/// GET /categories, tanpa create/update/delete.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> _categories = const [];
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
      final data = await AppScope.read(context).catalog.categories();
      if (!mounted) return;
      setState(() => _categories = data);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan saat memuat kategori.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CakuAppBar(title: 'Kelola Kategori', showBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Penambahan, pengubahan, dan penghapusan kategori '
                      'membutuhkan dukungan backend. Saat ini kategori hanya '
                      'dapat dilihat.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingView()
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _categories.isEmpty
                        ? const EmptyView(
                            title: 'Belum ada kategori',
                            message: 'Kategori akan muncul di sini.',
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.forest,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.screen),
                              itemCount: _categories.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final name = (category is Map)
                                    ? (category['nama_kategori'] ??
                                            category['nama'] ??
                                            '-')
                                        .toString()
                                    : category.toString();
                                return Card(
                                  child: ListTile(
                                    title: Text(name),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.forest,
                                          ),
                                          onPressed: null,
                                          tooltip: 'Edit (belum tersedia)',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.error,
                                          ),
                                          onPressed: null,
                                          tooltip: 'Hapus (belum tersedia)',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
