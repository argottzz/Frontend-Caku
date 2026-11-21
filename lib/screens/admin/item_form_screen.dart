import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../models/category.dart';
import '../../models/item.dart';
import '../../state/app_scope.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/caku_app_bar.dart';
import '../../widgets/image_source_field.dart';
import '../../widgets/layout.dart';
import '../../widgets/state_views.dart';

/// Formulir tambah/ubah barang untuk admin.
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, this.item});

  final Item? item;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _stokController = TextEditingController();
  final _hargaController = TextEditingController();
  final _dendaController = TextEditingController();

  List<Category> _categories = const [];
  bool _loadingCategories = true;
  String? _categoryError;
  int? _categoryId;
  FileUpload? _image;
  bool _saving = false;
  String? _formError;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _namaController.text = item.nama;
      _deskripsiController.text = item.deskripsi;
      _stokController.text = '${item.stok}';
      _hargaController.text = item.hargaSewaHarian.toStringAsFixed(2);
      _dendaController.text = item.dendaHarian.toStringAsFixed(2);
      _categoryId = item.idKategori;
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    _hargaController.dispose();
    _dendaController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoryError = null;
    });
    try {
      final categories = await AppScope.read(context).catalog.categories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (_categoryId == null && categories.isNotEmpty) {
          _categoryId = categories.first.id;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _categoryError = error.message);
    } catch (error) {
      debugPrint('Kategori error: $error');
      if (mounted) setState(() => _categoryError = 'Gagal memuat kategori.');
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  String? _validateMoney(String? value, {required bool allowZero}) {
    final required = Validators.required(value, label: 'Nominal');
    if (required != null) return required;
    final trimmed = value!.trim();
    if (Validators.money(trimmed) != null) return 'Format nominal tidak valid.';
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return 'Format nominal tidak valid.';
    if (parsed < 0) return 'Nominal tidak boleh negatif.';
    if (!allowZero && parsed <= 0) return 'Nominal harus lebih dari 0.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      setState(() => _formError = 'Pilih kategori barang.');
      return;
    }

    final stok = int.tryParse(_stokController.text.trim());
    if (stok == null || stok < 0) {
      setState(() => _formError = 'Stok harus bilangan bulat non-negatif.');
      return;
    }

    setState(() {
      _saving = true;
      _formError = null;
    });

    try {
      final catalog = AppScope.read(context).catalog;
      if (_isEdit) {
        await catalog.updateItem(
          id: widget.item!.id,
          idKategori: _categoryId!,
          nama: _namaController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          stok: stok,
          hargaSewaHarian: _hargaController.text.trim(),
          dendaHarian: _dendaController.text.trim(),
          image: _image,
        );
      } else {
        await catalog.createItem(
          idKategori: _categoryId!,
          nama: _namaController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          stok: stok,
          hargaSewaHarian: _hargaController.text.trim(),
          dendaHarian: _dendaController.text.trim(),
          image: _image,
        );
      }

      if (!mounted) return;
      AppSnack.success(
        context,
        _isEdit ? 'Barang berhasil diperbarui.' : 'Barang berhasil ditambahkan.',
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _formError = error.fieldError('image') ??
            error.fieldError('nama_item') ??
            error.fieldError('id_kategori') ??
            error.fieldError('stok') ??
            error.fieldError('harga_sewa_harian') ??
            error.fieldError('denda_harian') ??
            error.message;
      });
      AppSnack.error(context, error.message);
    } catch (error) {
      debugPrint('Simpan barang error: $error');
      if (mounted) {
        setState(() => _formError = 'Barang gagal disimpan. Coba lagi.');
        AppSnack.error(context, 'Barang gagal disimpan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: CakuAppBar(
        title: _isEdit ? 'Ubah barang' : 'Tambah barang',
        subtitle: _isEdit ? item?.nama : 'Isi data perlengkapan baru',
        showBack: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveFrame(
              maxWidth: 640,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_formError != null) ...[
                    InlineNotice(
                      message: _formError!,
                      icon: Icons.error_outline_rounded,
                      tone: NoticeTone.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_loadingCategories)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: LoadingView(compact: true),
                    )
                  else if (_categoryError != null)
                    InlineNotice(
                      message: _categoryError!,
                      icon: Icons.error_outline_rounded,
                      tone: NoticeTone.error,
                    )
                  else ...[
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.nama),
                            ),
                          )
                          .toList(growable: false),
                      validator: (value) =>
                          value == null ? 'Kategori wajib dipilih.' : null,
                      onChanged: (value) => setState(() => _categoryId = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _namaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama barang',
                      ),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Spesifikasi, kapasitas, atau catatan',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      validator: (value) {
                        final required = Validators.required(value, label: 'Stok');
                        if (required != null) return required;
                        final parsed = int.tryParse(value!.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Stok harus bilangan bulat non-negatif.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Harga sewa per hari',
                        prefixText: 'Rp ',
                      ),
                      validator: (value) =>
                          _validateMoney(value, allowZero: false),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _dendaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Denda keterlambatan per hari',
                        prefixText: 'Rp ',
                      ),
                      validator: (value) =>
                          _validateMoney(value, allowZero: true),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ImageSourceField(
                      label: 'Foto barang',
                      value: _image,
                      existingUrl: item?.imageUrl,
                      aspectRatio: 4 / 3,
                      onChanged: (upload) => setState(() => _image = upload),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      label: _isEdit ? 'Simpan perubahan' : 'Tambah barang',
                      icon: _isEdit
                          ? Icons.save_rounded
                          : Icons.add_rounded,
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
