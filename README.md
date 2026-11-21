# CAKU — Frontend Flutter

Aplikasi mobile penyewaan perlengkapan camping CAKU (customer dan admin).

## Arsitektur

```
Flutter (Android) → REST API Railway (Node.js/Express) → PostgreSQL Aiven
```

Flutter tidak pernah mengakses database secara langsung. Seluruh data diambil
melalui API backend.

## Konfigurasi backend

Satu konfigurasi terpusat di `lib/core/config/api_config.dart`.

| Build | Base URL |
|---|---|
| Release/profile | `https://backend-caku-production.up.railway.app/api` |
| Debug Android (emulator) | `http://10.0.2.2:8000/api` |
| Debug web/desktop | `http://localhost:8000/api` |

Override kapan saja dengan `--dart-define=API_BASE_URL=<origin>`; akhiran
`/api` ditambahkan otomatis.

```powershell
# Production (Railway)
flutter run --dart-define=API_BASE_URL=https://backend-caku-production.up.railway.app

# Development dengan backend lokal
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Build release selalu memakai Railway meskipun tanpa `--dart-define`, dan
cleartext HTTP hanya diizinkan pada manifest debug
(`android/app/src/debug/AndroidManifest.xml`).

## Menjalankan

```powershell
flutter pub get
flutter run -d chrome --web-port=3000 --dart-define=API_BASE_URL=https://backend-caku-production.up.railway.app
flutter build apk --release --dart-define=API_BASE_URL=https://backend-caku-production.up.railway.app
```

## Pemeriksaan mutu

```powershell
dart format lib test
flutter analyze
flutter test
```

## Dokumentasi

- `docs/API_MAPPING.md` — endpoint backend aktual dan pemetaan layar.
