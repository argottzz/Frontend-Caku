import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

class ReturnRentalInput {
  const ReturnRentalInput({
    required this.tanggalKembali,
    required this.kondisi,
    this.catatan,
  });

  final DateTime tanggalKembali;
  final String kondisi;
  final String? catatan;
}

/// Dialog pemrosesan pengembalian barang oleh admin.
Future<ReturnRentalInput?> showReturnRentalDialog(
  BuildContext context, {
  required DateTime tanggalMulai,
}) {
  return showDialog<ReturnRentalInput>(
    context: context,
    builder: (_) => _ReturnRentalDialog(tanggalMulai: tanggalMulai),
  );
}

class _ReturnRentalDialog extends StatefulWidget {
  const _ReturnRentalDialog({required this.tanggalMulai});

  final DateTime tanggalMulai;

  @override
  State<_ReturnRentalDialog> createState() => _ReturnRentalDialogState();
}

class _ReturnRentalDialogState extends State<_ReturnRentalDialog> {
  static const List<String> _kondisiOptions = ['Baik', 'Rusak', 'Hilang'];

  final _catatanController = TextEditingController();
  late DateTime _tanggal = Formatters.dateOnly(DateTime.now());
  String _kondisi = _kondisiOptions.first;
  String? _error;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = Formatters.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal.isAfter(today) ? today : _tanggal,
      firstDate: Formatters.dateOnly(widget.tanggalMulai),
      lastDate: today,
      helpText: 'Tanggal kembali aktual',
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  void _submit() {
    final catatan = _catatanController.text.trim();
    if (catatan.length > 5000) {
      setState(() => _error = 'Catatan maksimal 5000 karakter.');
      return;
    }
    if (_tanggal.isBefore(Formatters.dateOnly(widget.tanggalMulai))) {
      setState(
        () => _error = 'Tanggal kembali tidak boleh sebelum mulai sewa.',
      );
      return;
    }
    Navigator.pop(
      context,
      ReturnRentalInput(
        tanggalKembali: _tanggal,
        kondisi: _kondisi,
        catatan: catatan.isEmpty ? null : catatan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Proses pengembalian'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal kembali aktual',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event_available_rounded, size: 18),
              label: Text(Formatters.dateLong(_tanggal)),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _kondisi,
              decoration: const InputDecoration(labelText: 'Kondisi barang'),
              items: _kondisiOptions
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _kondisi = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              maxLength: 5000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Misalnya: tenda basah atau pasak hilang',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Stok otomatis dikembalikan. Untuk kondisi Rusak atau Hilang, '
              'sesuaikan stok barang secara manual bila perlu.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
