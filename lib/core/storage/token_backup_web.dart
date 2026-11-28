// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<String?> readTokenBackup() async {
  try {
    final value = html.window.localStorage['caku_token'];
    return (value == null || value.trim().isEmpty) ? null : value.trim();
  } catch (_) {
    return null;
  }
}

Future<void> writeTokenBackup(String value) async {
  try {
    html.window.localStorage['caku_token'] = value;
  } catch (_) {}
}

Future<void> deleteTokenBackup() async {
  try {
    html.window.localStorage.remove('caku_token');
  } catch (_) {}
}
