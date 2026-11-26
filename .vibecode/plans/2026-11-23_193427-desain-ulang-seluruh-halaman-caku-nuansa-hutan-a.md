# Desain ulang seluruh halaman CAKU — nuansa hutan & alam

## Tujuan

Menyegarkan tampilan **seluruh layar** aplikasi CAKU agar terasa seperti aplikasi
outdoor: putih bersih, hijau pinus yang dalam, dan aksen coral. Bukan sekadar
mengganti warna, tetapi menata ulang hierarki visual (header, kartu, foto,
permukaan) supaya terasa seperti "masuk ke hutan" tanpa mengubah satu pun
logic, routing, API, maupun state.

### Keputusan dari pengguna

| Pertanyaan | Jawaban |
|---|---|
| Arah nuansa hutan | **Putih dengan aksen hijau** — latar tetap putih, hutan datang dari hijau tua, sage, gradien, dan foto |
| Cakupan | **Semua halaman, bertahap** (customer, auth, onboarding, admin) |
| Foto stok | **Boleh menambah foto berlisensi** — disimpan di `asset/`, kredit di README |
| Logo | **Pertahankan logo lama** (`asset/caku-logo.jpg`); logo baru menyusul dari pengguna |

### Warna merek (dari pengguna)

- Primary `#2A563F` — hampir identik dengan token `AppColors.forest` sekarang
  (`0xFF2A573F`, selisih 1 pada kanal hijau). **Token lama dipertahankan** agar
  kontras yang sudah lolos WCAG di halaman lain tidak bergeser; perbedaan satu
  unit tidak terlihat mata.
- Accent `#FF7663` — token sekarang `AppColors.orange = 0xFF7761`. Sama, dipertahankan.
- Background `#FFFFFF` — sudah `AppColors.background`.

Kesimpulan: identitas merek **sudah** memakai palet yang diminta. Yang berubah
adalah cara palet itu dipakai, bukan nilainya.

---

## Pendekatan

1. **Perluas sistem token** di `lib/core/theme/app_colors.dart` dan
   `lib/core/theme/app_theme.dart` dengan keluarga warna hutan (sage, moss,
   pine tint, krem kabut) dan aturan komponen baru. Karena hampir semua layar
   sudah memakai `AppColors.*` (lihat tabel pemakaian di bawah), memperbarui
   token + komponen bersama otomatis merambat ke seluruh aplikasi.
2. **Tambah komponen bersama baru** yang menjadi "wajah hutan" aplikasi:
   `ForestHeader` (header bergambar hutan + gradien hijau), `ForestPattern`
   (motif kontur/pepohonan halus untuk latar kosong), dan `ForestHeroCard`.
3. **Rapikan layar satu per satu** dalam tiga tahap yang bisa dicek terpisah,
   dengan pola yang sama untuk semua: header → isi → aksi bawah.

---

## Perubahan token & tema

### `lib/core/theme/app_colors.dart`

Tambahkan (tidak menghapus token lama, karena 38 file memakainya):

| Token baru | Nilai | Pemakaian |
|---|---|---|
| `pine` | `#1B3A2B` | hijau terdalam untuk header & teks di atas foto |
| `forest` | tetap `#2A573F` | primary, CTA, ikon aktif |
| `moss` | `#4F7A5C` | aksen sekunder, grafik, badge lembut |
| `sage` | `#8FB39B` | garis, ilustrasi, ikon dekoratif |
| `sageLight` | `#DCE8DF` | permukaan kartu berwarna |
| `forestSurface` | ganti menjadi `#EAF2EC` | tint hijau lebih segar (nilai lama `#E7F2EC`) |
| `mist` | `#F3F6F3` | permukaan kartu default (menggantikan `surface` abu) |
| `cream` | tetap `#F6F7F5` | bingkai logo (logo berlatar krem, harus tetap serasi) |
| `bark` | `#6B5A45` | teks sekunder hangat bila diperlukan di atas krem |
| `sand` | `#F7EFE3` | blok promosi/editorial |
| `orangeSurface` | tetap | sorotan aksen |

### `lib/core/theme/app_theme.dart`

- `scaffoldBackgroundColor` tetap putih.
- `cardTheme`: permukaan `mist`, border `sageLight` 1px, radius 20 (`AppRadius.lg` naik 16→20).
- `filledButtonTheme`: radius tetap pill, tinggi 52, warna `forest`.
- `appBarTheme`: latar transparan di atas `ForestHeader`, ikon `white`.
- Tipografi: tambah `displaySmall` 22px w700 untuk judul section, dan naikkan
  `headlineLarge` dari 20 → 22 agar hierarki lebih tegas.
- `navigationBarTheme` (sudah ditimpa `CakuBottomNav`, cukup diselaraskan).

---

## Komponen bersama

| File | Perubahan |
|---|---|
| `lib/widgets/forest_header.dart` **(baru)** | `ForestHeader`: gambar hutan (`asset/forest-header.jpg`) `BoxFit.cover` + overlay gradien `pine`→transparan, tinggi 150–190 px (opsional `hero: true` setinggi 280 px). Isi: judul besar putih, sub-judul krem, slot aksi. Dipakai Home, Dashboard, Katalog, Sewa Saya, Profil. |
| `lib/widgets/forest_pattern.dart` **(baru)** | `ForestPattern`: lapisan `CustomPainter` bergaris kontur/topografi warna `sage` opacity 0.12 untuk latar kosong (empty state, splash, auth panel). Tanpa aset, tanpa data. |
| `lib/widgets/caku_app_bar.dart` | Mode baru `onImage: true` → ikon & judul putih, tanpa bayangan, tombol kembali lingkaran kaca (`white` 15% + blur). Dipakai di layar yang punya `ForestHeader`. |
| `lib/widgets/caku_bottom_nav.dart` | Pill putih, border `sageLight`, shadow hijau `0x1A2A573F`; ikon aktif `forest` dengan indikator titik kecil di bawah label; nonaktif `textSecondary`. |
| `lib/screens/customer/widgets/item_card.dart` | Foto 4:3, radius 20, badge kategori `sageLight`/`forest`, harga `forest` w800, garis atas tipis `sageLight`. |
| `lib/widgets/rental_card.dart` | Header kartu diberi strip tipis `forestSurface`, status badge mengikuti token status (tidak berubah), total `forest`. |
| `lib/widgets/state_views.dart` | `EmptyView`/`ErrorView` memakai `ForestPattern` + ikon lingkaran `sageLight`. |
| `lib/widgets/app_buttons.dart` | `PrimaryButton` hijau pinus (tetap), `SecondaryButton` border `sage`, `DangerButton` tetap merah. |
| `lib/widgets/status_filter_bar.dart` | Pill aktif `forest`, nonaktif `mist` + border `sageLight`. |
| `lib/widgets/feedback_dialog.dart`, `confirm_dialog.dart` | Radius 24, ikon dalam lingkaran `sageLight`/`errorSurface` (sudah, cukup penyelarasan warna). |
| `lib/widgets/layout.dart` | `BrandBackdrop` diganti `ForestPattern` + gradien `forestSurface`. |

### Aset baru

- `asset/forest-header.jpg` — foto hutan pinus berkabut. Kandidat terpilih:
  Pexels #10195041 (Adrian Newell) atau #13534013 (Johannes Plenio).
  Diunduh, di-resize ke lebar 1600 px, lalu didaftarkan di `pubspec.yaml`.
- `README.md` — tambah bagian **Kredit Aset** dengan nama fotografer, platform,
  dan URL foto.

---

## Tahapan kerja

### Tahap 1 — Sistem desain (fondasi)

1. Tambah token warna baru di `app_colors.dart`.
2. Perbarui `app_theme.dart`: kartu, tombol, AppBar, tipografi.
3. Buat `forest_pattern.dart` dan `forest_header.dart`.
4. Unduh `forest-header.jpg`, daftarkan di `pubspec.yaml`, tulis kredit di README.
5. `flutter analyze` + `flutter test`.

**Cek:** buka Home lama — warna kartu, tombol, dan bottom bar berubah tanpa error.

### Tahap 2 — Splash, Onboarding, Auth

6. `splash_screen.dart`: latar `ForestPattern` + gradien hijau, logo tetap,
   tagline di atas kontur.
7. `onboarding_screen.dart` halaman 1 & 2: hero tetap 58% tetapi overlay
   gradien `pine` di bawah foto; judul & deskripsi di atas kartu putih
   menumpuk; dots aktif `forest`. **Halaman 3 tidak disentuh** (batasan pengguna).
8. `auth_shell.dart`: panel merek kiri jadi `ForestHeader` vertikal dengan
   `ForestPattern`; form tetap seperti sekarang (putih, tanpa kartu).
9. `login_screen.dart`, `register_screen.dart`: hanya warna ikon & tautan ke
   `forest`/`moss`; logic tidak berubah.

**Cek:** jalur baru → onboarding → login → register → modal gagal.

### Tahap 3 — Customer

10. `home_screen.dart`: ganti header teks dengan `ForestHeader` hero 240px
    (foto hutan + sapaan + keranjang/profil di atas foto); search trigger pill
    `mist`; kategori jadi kartu ikon 56px `sageLight`; grid produk memakai
    `ItemCard` baru.
11. `catalog_screen.dart`: AppBar putih + `ForestPattern` tipis di atas grid,
    chip kategori mengikuti `status_filter_bar` baru.
12. `item_detail_screen.dart`: hero foto lebih tinggi (4:3 → 4:5 di ponsel),
    overlay gradien bawah, judul di kartu putih menumpuk (sudah ada, tinggal
    warna & radius), bar aksi bawah `forest`.
13. `cart_screen.dart`, `checkout_screen.dart`: kartu `mist`/radius 20,
    ringkasan biaya di kartu `forestSurface`, CTA tetap hijau.
14. `rentals_screen.dart`, `rental_detail_screen.dart`: `ForestHeader` ringkas
    + filter pill baru.
15. `profile_screen.dart`: header profil di atas blok `forest` dengan
    `ForestPattern`; avatar lingkaran krem; kartu menu `mist`.

### Tahap 4 — Admin

16. `admin/dashboard_screen.dart`: hero pendapatan gradien `pine`→`forest` +
    `ForestPattern`; stat tile `mist` dengan ikon `sageLight`.
17. `admin/items_screen.dart`, `categories_screen.dart`, `item_form_screen.dart`:
    kartu, FAB `forest`, input mengikuti tema.
18. `admin/reports_screen.dart`: grafik batang `forest`/`moss`; kartu ringkasan.
19. `admin_applications_screen.dart`, `admin_application_detail_screen.dart`,
    `admin_application_screen.dart`: badge status tetap, kartu diselaraskan.
20. `edit_profile_screen.dart`, `change_password_screen.dart`,
    `session_landing.dart`: penyelarasan warna & radius saja.

**Cek tiap tahap:** `flutter analyze` bersih, `flutter test` hijau, lalu render
web di 390×844 dan 320×640 untuk memastikan tidak ada overflow.

---

## Yang dipakai ulang (tidak dibangun baru)

- `AppColors`, `AppSpacing`, `AppRadius` — seluruh aplikasi sudah bergantung
  padanya (38 file memakai `AppColors.*`).
- `PrimaryButton` / `SecondaryButton` / `DangerButton` di `app_buttons.dart`.
- `ItemImage` + `BrandImagePlaceholder` (fallback merek bila gambar gagal).
- `CakuBottomNav`, `CakuAppBar`, `StatusBadge`, `StockBadge`, `InlineNotice`.
- `showFeedbackDialog` (baru dibuat) untuk modal feedback.
- Foto onboarding & produk yang sudah ada di `asset/`.

---

## Tidak dikerjakan

- Tidak ada perubahan logic, routing, API, model data, atau state management.
- Logo tidak diganti (menunggu logo baru dari pengguna).
- Tidak menambah fitur baru (favorit, ulasan, wishlist, filter lokasi).
- Halaman 3 onboarding tidak diubah selain warna token yang otomatis ikut.
- Tidak mengubah nama teks tombol, label menu, atau route.
- Tema gelap tidak dibuat.

---

## Verifikasi

1. `flutter analyze` → harus `No issues found!`
2. `flutter test` → 36/36 lulus (test login, katalog, keranjang, checkout,
   dashboard, laporan, kartu rental, kartu barang).
3. Render manual (Chrome, `flutter run -d chrome`):
   - 390×844: Splash → Onboarding → Login → Register → Home → Katalog →
     Detail → Keranjang → Checkout → Sewa Saya → Profil → Login sebagai admin
     → Dashboard → Barang → Transaksi → Profil Admin.
   - 320×640: Home, Detail Produk, Keranjang, Profil (cek overflow bar aksi).
4. Kontras teks putih di atas foto header: pastikan overlay gradien cukup
   gelap (≥ 4.5:1) di area judul, termasuk saat foto terang.
5. Cek setiap aset baru dimuat dan kredit tertulis di README.
