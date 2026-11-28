import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readTokenBackup() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/caku_token.txt');
    if (!await file.exists()) return null;
    final value = await file.readAsString();
    return value.trim().isEmpty ? null : value.trim();
  } catch (_) {
    return null;
  }
}

Future<void> writeTokenBackup(String value) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/caku_token.txt');
    await file.writeAsString(value, flush: true);
  } catch (_) {}
}

Future<void> deleteTokenBackup() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/caku_token.txt');
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
