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
- `docs/DESIGN_GUIDELINES.md` — arahan UI/UX (nuansa hutan) aplikasi.
- `asset/images/CREDITS.md` — kredit foto stok yang dipakai aplikasi.

## Struktur folder

```text
lib/
  core/       config, network, storage, theme, utils (dipakai lintas fitur)
  data/       service pemanggilan API
  models/     model data
  state/      controller dan AppScope
  widgets/    widget bersama (tombol, kartu, header, dialog)
  screens/
    auth/       login, register
    onboarding/ onboarding
    customer/   home, katalog, cart, checkout, detail item
    admin/      shell, dashboard, barang, laporan
    shared/     layar yang dipakai customer dan admin
                (profil, transaksi, detail transaksi, permohonan admin)
asset/
  fonts/      font Plus Jakarta Sans
  images/
    branding/   logo dan header hutan
    onboarding/ ilustrasi onboarding
    products/   foto produk (sumber unggahan admin, tidak dibundel)
docs/         dokumentasi API dan desain
```
