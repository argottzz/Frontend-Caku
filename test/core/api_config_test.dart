import 'package:caku_app/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiConfig.normalize', () {
    test('menambahkan /api pada origin tanpa prefix', () {
      expect(
        ApiConfig.normalize('https://backend-caku-production.up.railway.app'),
        'https://backend-caku-production.up.railway.app/api',
      );
    });

    test('tidak menggandakan /api dan membuang garis miring akhir', () {
      expect(
        ApiConfig.normalize('http://10.0.2.2:8000/api/'),
        'http://10.0.2.2:8000/api',
      );
    });

    test('membuang spasi di awal dan akhir', () {
      expect(
        ApiConfig.normalize('  http://localhost:8000  '),
        'http://localhost:8000/api',
      );
    });
  });
}
