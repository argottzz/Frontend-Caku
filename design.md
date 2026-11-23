================================================================================
                    FINAL DESIGN SPECIFICATION — CAKU
         Modern Outdoor Editorial | Forest-Inspired Visual Identity
================================================================================

IDENTITAS DOKUMEN
- Nama Produk        : CAKU (Aplikasi Manajemen Penyewaan Perlengkapan Camping)
- Tagline            : Explore More, Worry Less.
- Peran Penyusun     : Principal Product Designer, Senior UI/UX Designer & Design QA Specialist
- Target Penerima     : AI Programmer (Implementasi Mobile Flutter)
- Status Dokumen     : BASELINE DESAIN FINAL (TERVALIDASI & TERINTEGRASI)
- Jumlah Layar       : 28 Layar / Template Tampilan (1 Template Dual-Mode)
- Frame Acuan Utama  : 390 x 844 px (Responsif untuk layar mobile standar)

================================================================================
BAB 1 — RINGKASAN FINAL
================================================================================

1.1 IDENTITAS DAN TUJUAN CAKU
CAKU adalah aplikasi mobile manajemen penyewaan perlengkapan camping yang
menghubungkan penyewa (Customer) dengan pengelola inventaris (Admin). Aplikasi
ini dirancang untuk menyederhanakan penelusuran katalog perlengkapan camping,
pemesanan alat sewa berdasarkan periode tanggal, verifikasi pembayaran, pemantauan
status transaksi, hingga proses pengembalian barang dan pelaporan operasional.

1.2 ARAH VISUAL & PENYATUAN DESIGN SYSTEM
Modern Outdoor Editorial (Clean White Surface & Reusable Components):
- Seluruh 28 layar menyatu dalam satu bahasa visual yang kohesif berdasarkan
  komponen yang telah ditetapkan: latar bersih **Pure White (`#FFFFFF`)**,
  permukaan kartu/input lembut **Mist Stone (`#F6F7F5`)** dengan garis batas
  tipis (`#E4E7E3`), aksen utama **Forest Pine (`#2A573F`)**, aksen sorotan
  **Coral Ember (`#FF7761`)**, tombol utama berbentuk kapsul (*pill radius
  25 px*), dan **Floating Bottom Navigation Bar** pada layar utama.
- Halaman yang tidak memiliki referensi gambar terpisah (Splash, Jelajahi,
  Checkout, Sewa Saya, Detail Transaksi, Edit Profil, Ubah Password, Form
  Pengajuan Admin, dan seluruh layar Admin) **wajib menggunakan ulang (reuse)**
  komponen UI, token warna, tipografi, radius, dan pola interaksi dari halaman
  utama tanpa menciptakan gaya desain baru yang terpisah.
- Kemurnian Domain Rental: Seluruh layar bebas dari elemen non-sistem (seperti
  *wishlist/love*, *promo code*, *shipping*, *forgot password/OTP*, *follower*,
  maupun navigasi lokasi wisata).

1.3 PRINSIP UX
1. Konsistensi Lintas Layar: Setiap layar menggunakan header, tombol kembali
   lingkaran lembut, kartu Mist Stone, pill button, dan pola feedback yang sama.
2. Kejelasan Hierarki: Informasi terpenting (status transaksi, harga sewa/hari,
   ketersediaan stok unit, dan tindakan utama) menempati posisi visual utama.
3. Pencegahan Kesalahan (Error Prevention): Validasi eksplisit pada periode sewa,
   batas stok, pemeriksaan kondisi pengembalian barang, dan alasan penolakan.
4. Kejujuran Integrasi & State: Tidak ada form atau tombol statis yang berpura-pura
   berfungsi; fitur yang memerlukan verifikasi backend/logic (seperti Edit Profil
   dan Ubah Password) dipetakan secara transparan pada Bab 5.

1.4 RUANG LINGKUP DESAIN & JUMLAH LAYAR
Dokumen ini mencakup 28 layar utuh yang terbagi ke dalam dua peran pengguna:
- Alur Autentikasi & Onboarding (6 Layar): [01] s.d. [06]
- Peran Customer (11 Layar): [07] s.d. [17]
- Peran Admin (11 Layar, termasuk 1 template dual-mode Tambah/Edit Barang): [18] s.d. [28]

================================================================================
BAB 2 — FINAL DESIGN SYSTEM
================================================================================

2.1 COLOR PALETTE (DESIGN TOKENS)
Brand & Surface Tokens:
- Background Utama     : #FFFFFF (Pure White — latar bersih seluruh layar)
- Surface / Card       : #F6F7F5 (Mist Stone — permukaan kartu & field input)
- Elevated Card / Modal: #FFFFFF (Pure White — dengan border tipis #E4E7E3)
- Primary / Brand      : #2A573F (Forest Pine — header blok, CTA utama, tab aktif)
- Soft Brand Tint      : #E7F2EC (Soft Pine Tint — banner promo & pill kategori)
- Accent Block / CTA   : #FF7761 (Coral Ember — CTA sorotan & badge notifikasi)
- Accent Text (on #FFF): #C94632 (Deep Coral — teks aksen di atas latar putih)
- Primary Text         : #1E2621 (Deep Pine Charcoal)
- Secondary Text       : #5A635E (Muted Slate Pine)
- Text on Forest Pine  : #FFFFFF (Pure White)
- Text on Coral Ember  : #1F1512 (Dark Espresso — kontras tinggi di atas #FF7761)
- Control Border       : #727874 (Slate Olive — batas kontrol interaktif)
- Card & Hairline Border: #E4E7E3 (Soft Mist Border — batas kartu & divider)
- Focus / Active Border: #2A573F (Forest Pine — ketebalan 1.5–2 px)
- Decorative Icon Only : #8E9490 (Dilarang untuk teks atau batas kontrol penting)
- Disabled Surface     : #EAECE9 (Soft Ash)
- Disabled Text        : #5A635E (Muted Slate Pine)

Status Tokens (Wajib disertai Ikon + Label Teks):
- Pending   : BG #FFF0D9 | Text #8A4A0B | Border #8A4A0B | Ikon: Jam (schedule)
- Approved  : BG #E7F2EC | Text #2A573F | Border #2A573F | Ikon: Centang (check_circle)
- Ongoing   : BG #E5EFF8 | Text #2E5B7A | Border #2E5B7A | Ikon: Panah Berjalan (autorenew)
- Overdue   : BG #FCE8E8 | Text #A32929 | Border #A32929 | Ikon: Peringatan (warning) | Label: "Terlambat"
- Completed : BG #2A573F | Text #FFFFFF | Border #2A573F | Ikon: Centang Ganda (done_all)
- Rejected  : BG #FCE8E8 | Text #A32929 | Border #A32929 | Ikon: Silang (cancel)

2.2 DESIGN COLOR CONTRAST TARGETS — WCAG 2.2 AA
Catatan Standar: Evaluasi ini menggunakan target kontras WCAG 2.2 Level AA
(Teks normal >= 4.5:1; Teks besar >= 3.0:1; Batas komponen kontrol non-teks >= 3.0:1)
berdasarkan perhitungan luminansi relatif sRGB.

+-----------------------------------+------------+------------+--------+--------+--------+
| Token / Pasangan Warna Uji        | Foreground | Background | Rasio  | Target | Hasil  |
+-----------------------------------+------------+------------+--------+--------+--------+
| Primary Text on Pure White        | #1E2621    | #FFFFFF    |15.17:1 | 4.5:1  | LULUS  |
| Primary Text on Mist Stone Card   | #1E2621    | #F6F7F5    |14.12:1 | 4.5:1  | LULUS  |
| Forest Pine on Pure White         | #2A573F    | #FFFFFF    | 8.43:1 | 4.5:1  | LULUS  |
| Forest Pine on Mist Stone Card    | #2A573F    | #F6F7F5    | 7.84:1 | 4.5:1  | LULUS  |
| White Text on Forest Pine         | #FFFFFF    | #2A573F    | 8.43:1 | 4.5:1  | LULUS  |
| Secondary Text on Pure White      | #5A635E    | #FFFFFF    | 6.08:1 | 4.5:1  | LULUS  |
| Secondary Text on Mist Stone Card | #5A635E    | #F6F7F5    | 5.66:1 | 4.5:1  | LULUS  |
| Deep Coral Text on Pure White     | #C94632    | #FFFFFF    | 4.74:1 | 4.5:1  | LULUS  |
| Dark Espresso on Coral Ember      | #1F1512    | #FF7761    | 6.64:1 | 4.5:1  | LULUS  |
| Disabled Text on Disabled Surface | #5A635E    | #EAECE9    | 5.15:1 | 4.5:1  | LULUS  |
| Status Pending (Text on BG)       | #8A4A0B    | #FFF0D9    | 6.24:1 | 4.5:1  | LULUS  |
| Status Approved (Text on BG)      | #2A573F    | #E7F2EC    | 7.45:1 | 4.5:1  | LULUS  |
| Status Ongoing (Text on BG)       | #2E5B7A    | #E5EFF8    | 6.23:1 | 4.5:1  | LULUS  |
| Status Overdue (Text on BG)       | #A32929    | #FCE8E8    | 6.14:1 | 4.5:1  | LULUS  |
| Status Completed (Text on BG)     | #FFFFFF    | #2A573F    | 8.43:1 | 4.5:1  | LULUS  |
| Status Rejected (Text on BG)      | #A32929    | #FCE8E8    | 6.14:1 | 4.5:1  | LULUS  |
| Control Border on Pure White      | #727874    | #FFFFFF    | 4.49:1 | 3.0:1  | LULUS  |
| Control Border on Mist Stone Card | #727874    | #F6F7F5    | 4.18:1 | 3.0:1  | LULUS  |
| Focus Border on White / Mist Stone| #2A573F    | #FFF/#F6F7 | 7.84:1+| 3.0:1  | LULUS  |
+-----------------------------------+------------+------------+--------+--------+--------+

2.3 TYPOGRAPHY (FONT FAMILY: PLUS JAKARTA SANS)
- Display / H1 : 26 px | Weight 700 (Bold)     | Line-height 1.25 (32.5 px) | Tracking -0.3 px
- Heading / H2 : 20 px | Weight 600 (SemiBold) | Line-height 1.30 (26.0 px) | Tracking -0.2 px
- Title / H3   : 16 px | Weight 600 (SemiBold) | Line-height 1.35 (21.6 px) | Tracking 0 px
- Body         : 14 px | Weight 400 (Regular)  | Line-height 1.50 (21.0 px) | Tracking 0 px
- Body Strong  : 14 px | Weight 600 (SemiBold) | Line-height 1.50 (21.0 px) | Tracking 0 px
- Caption      : 12 px | Weight 400 (Regular)  | Line-height 1.40 (16.8 px) | Tracking 0.1 px
- Caption Bold : 12 px | Weight 600 (SemiBold) | Line-height 1.40 (16.8 px) | Tracking 0.1 px
- Button Label : 15 px | Weight 600 (SemiBold) | Line-height 1.20 (18.0 px) | Tracking 0.2 px

2.4 SPACING SYSTEM (KELIPATAN 4 PX)
- Screen Horizontal Padding : 20 px (kiri & kanan)
- Screen Top/Bottom Margin  : Top min. 16 px; Bottom min. 24 px (+ SafeArea)
- Bottom Scroll Clearance   : 100 px pada layar utama yang memiliki Floating Bottom Bar
- Section Gap               : 20 px antar-kelompok utama
- Card Internal Padding     : 16 px
- List Item Gap             : 12 px antar-kartu dalam daftar vertikal
- Grid Gap                  : 12 px (horizontal & vertikal)
- Form Field Gap            : 16 px antar-input; 6 px antara label dan input
- Inline Element Gap        : 8 px antara ikon dan label teks

2.5 BORDER & RADIUS
- Card / Container Utama   : Radius 16 px
- Floating Bottom Nav Bar  : Radius 22 px (kapsul mengambang di bawah layar)
- Primary & Accent Button  : Radius 25 px (Pill Shape — tinggi 50 px)
- Boxed Text Input         : Radius 14 px
- Filter Chip              : Radius 12 px
- Status Pill / Badge      : Radius 8 px
- Modal & Feedback Popup   : Radius 24 px
- Ketebalan Border:
  - Card & Boxed Input Default : 1.0 px solid #E4E7E3
  - Interactive Control Border : 1.0 px solid #727874
  - Focus / Active Border      : 1.5 px solid #2A573F
  - Error Border               : 1.5 px solid #A32929

2.6 ELEVATION & SHADOW
- Standar Kartu: Latar #F6F7F5 dengan border tipis 1 px #E4E7E3 (Elevation 0)
  sehingga tampilan tetap bersih dan modern di atas #FFFFFF.
- Floating Bottom Navigation Bar: Elevation 6 dengan shadow `Color(0x1A1E2621)`
  (opacity 10%), offset `(0, 4)`, blur `16 px`, ditambah border tipis `1 px #E4E7E3`.
- Sticky Bottom Action Bar (Subhalaman): Elevation 4 dengan shadow
  `Color(0x142A573F)` (opacity 8%), offset `(0, -2)`, blur `8 px`, ditambah
  garis batas atas `1 px #E4E7E3`.

2.7 ICONOGRAPHY
- Menggunakan Material Symbols Rounded / Outlined (stroke weight 1.75–2.0 px)
  secara konsisten di seluruh aplikasi.
- Ukuran Ikon:
  - Floating Bottom Nav : 22–24 px
  - Circular AppBar Action: 20–22 px (dalam lingkaran 44 x 44 px berlatar #F6F7F5)
  - Input Prefix/Suffix : 20 px
  - Status Badge Icon   : 14 px
  - Inline Info Icon    : 16 px

2.8 BUTTON SYSTEM (TAP AREA MINIMUM 44 X 44 PX)
- Primary Pill Button (Forest Pine):
  - Tinggi 50 px, radius 25 px (pill), latar #2A573F, teks #FFFFFF (Button 15px).
  - Loading State: Teks diganti CircularProgressIndicator 20 px (#FFFFFF), non-klik.
  - Disabled State: Latar #EAECE9, teks #5A635E, non-klik.
- Accent Pill Button (Coral Ember):
  - Tinggi 50 px, radius 25 px (pill), latar #FF7761, teks #1F1512 (Button 15px
    SemiBold). Digunakan untuk aksi sorotan (seperti tombol Edit Profil utama
    atau CTA akhir Onboarding 3).
- Secondary / Outlined Pill Button:
  - Tinggi 50 px, radius 25 px, latar #FFFFFF, border 1.5 px #2A573F, teks #2A573F.
- Danger Outlined Pill Button (Tolak / Batalkan / Hapus / Logout):
  - Tinggi 48–50 px, radius 25 px, latar #FFFFFF, border 1.5 px #A32929, teks #A32929.
- Circular Icon Button (Back Button & Header Action):
  - Ukuran 44 x 44 px, bentuk lingkaran, latar #F6F7F5, border 1 px #E4E7E3,
    ikon #1E2621.

2.9 INPUT SYSTEM (REUSABLE BOXED INPUT)
- Tinggi minimum 52 px, latar #F6F7F5, radius 14 px, padding horizontal 16 px.
- Menggunakan pola kotak input bersih dari referensi Login/Register: label
  kecil (`Caption Bold #1E2621`) di bagian atas/dalam kotak atau tepat di atas
  field, dengan ikon aksi (`toggle mata`, `kalender`, `dropdown`) di sisi kanan.
- Placeholder menggunakan warna #5A635E.
- States:
  - Default  : Border 1.0 px #E4E7E3
  - Focused  : Border 1.5 px #2A573F
  - Error    : Border 1.5 px #A32929 + pesan teks error di bawah field (Caption #A32929)
  - Read-Only: Latar #EAECE9, border 1.0 px #E4E7E3, teks #5A635E + ikon gembok 16 px.

2.10 CARD, DIALOG & FEEDBACK POPUP
- Card Standar: Latar #F6F7F5, border 1 px #E4E7E3, radius 16 px, padding 16 px.
  Hindari card bersarang di dalam card kecuali untuk kotak peringatan status
  atau pratinjau media.
- Confirmation & Status Feedback Popup: Mengadopsi modal/bottom-sheet putih
  bersih (`#FFFFFF`, radius `24 px`, padding `24 px`) dengan ikon status
  lingkaran di tengah, judul tebal (`H2 #1E2621`), deskripsi singkat (`Body
  #5A635E`), dan tombol pill (`radius 25 px`) yang selaras dengan alur sistem.
- Form Modal Dialog (Kelola Kategori & Alasan Penolakan): Latar #FFFFFF, radius
  24 px, padding 20 px, mendukung penyesuaian otomatis terhadap ketinggian keyboard
  (`viewInsets.bottom`).

2.11 NAVIGASI DAN LAYOUT (FLOATING BOTTOM NAVIGATION BAR)
- **Keputusan Sidebar:** Tidak menggunakan Sidebar/Drawer; seluruh navigasi
  utama menggunakan satu komponen **Floating Bottom Navigation Bar** bersama.
- **Spesifikasi Floating Bottom Bar:**
  - Posisi: Mengambang di bawah layar (`margin horizontal 20 px`, `margin bottom
    12 px + bottom SafeArea`), tinggi `64 px`, bentuk kapsul membulat penuh
    (`radius 22 px`), latar `#FFFFFF`, border `1 px #E4E7E3`, dan bayangan halus.
  - Komposisi: 4 item navigasi setara rata horizontal, masing-masing berisi ikon
    (`22 px`) di atas label teks (`11–12 px`) dengan jarak vertikal `4 px`.
  - State Aktif: Ikon filled + label Caption Bold warna **Forest Pine (`#2A573F`)**
    (tanpa latar pil tambahan di dalam bar).
  - State Nonaktif: Ikon outlined + label Regular warna **Muted Slate Pine (`#5A635E`)**.
  - Menu Customer (4 Tab):
    1. `Home` ([07])
    2. `Jelajahi` ([08] — sekaligus pintu utama Kategori perlengkapan)
    3. `Sewa Saya` ([12])
    4. `Profil` ([14])
  - Menu Admin (4 Tab):
    1. `Dashboard` ([18])
    2. `Barang` ([19])
    3. `Transaksi` ([22])
    4. `Profil` ([28])
- **Subhalaman (`[09]`–`[11]`, `[13]`, `[15]`–`[17]`, `[20]`–`[21]`, `[23]`–`[27]`):**
  - Menyembunyikan Floating Bottom Bar sepenuhnya.
  - Menggunakan AppBar standar dengan **Circular Back Button** (`44x44 px`) di
    kiri atas dan judul halaman rata tengah (`H3 #1E2621`).

2.12 ATURAN GAMBAR DAN ILUSTRASI
- Product Card (`[07]` Home & `[08]` Jelajahi): Rasio wajib `4:3`, `BoxFit.cover`,
  `Alignment.center`.
- Detail Barang (`[09]`): Rasio wajib `4:3` di dalam bingkai ber-padding horizontal
  `20 px` dengan sudut membulat `radius 20 px`, `BoxFit.cover`, `Alignment.center`.
- Onboarding (`[02]`–`[03]`): Foto layar penuh di separuh atas (`~54%` tinggi
  layar) dengan gradien transisi lembut menuju latar `#FFFFFF` di bawahnya.
- Image Placeholder & Error Fallback: Latar `#EAECE9` dengan ikon perlengkapan/tenda
  berwarna `#5A635E` di tengah.

================================================================================
BAB 3 — FINAL SCREEN SPECIFICATION (28 LAYAR)
================================================================================

--------------------------------------------------------------------------------
[01] SPLASH SCREEN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menampilkan identitas CAKU saat startup & memeriksa sesi
   aktif (Semua pengguna: tamu, Customer, Admin).
2. Struktur Layout & Hierarki: Layar penuh 390 x 844 px tanpa AppBar dan tanpa
   Floating Bottom Bar, selaras dengan palet bersih aplikasi. Hierarki:
   (1) Logo Mark CAKU dalam kontainer lingkaran soft tint (`#E7F2EC`),
   (2) Nama "CAKU", (3) Tagline "Explore More, Worry Less.", (4) Indikator
   loading minimal di bawah.
3. Urutan Komponen: Center Column -> Logo Container (84x84 px, radius 42 px)
   berisi Logo CAKU (#2A573F), SizedBox(16), Text "CAKU", SizedBox(6), Text
   "Explore More, Worry Less."; Bottom Positioned -> CircularProgressIndicator
   (24x24 px).
4. Ukuran, Spacing & Radius: Center alignment; jarak loader dari bottom SafeArea 32 px.
5. Tipografi & Warna: BG #FFFFFF; Logo Container #E7F2EC; Nama H1 26px Bold
   #2A573F; Tagline Body 14px Regular #5A635E; Loader #2A573F.
6. Interaksi: Tidak ada interaksi manual; navigasi dipicu otomatis setelah
   pengecekan sesi selesai.
7. Navigasi: Masuk saat app dibuka -> Keluar otomatis ke [02] Onboarding 1
   (pengguna baru), [05] Login (belum login), [07] Home Customer (role customer),
   atau [18] Dashboard Admin (role admin).
8. UI States: Loading minimal hanya tampil saat pengecekan token/sesi berlangsung;
   langsung berpindah jika sesi siap.
9. Validasi & Pesan Error: Jika pengecekan sesi gagal/timeout karena jaringan,
   arahkan ke [05] Login agar pengguna tidak terjebak di Splash Screen.

--------------------------------------------------------------------------------
[02] ONBOARDING 1 — SEWA PERLENGKAPAN CAMPING
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Memperkenalkan CAKU sebagai platform penyewaan peralatan
   camping (Pengguna baru pertama kali membuka aplikasi).
2. Struktur Layout & Hierarki: 390 x 844 px, tanpa Bottom Bar. Mengadopsi tata
   letak foto layar penuh di separuh atas layar yang menyatu mulus ke latar
   putih `#FFFFFF` melalui gradien transisi lembut, disertai tombol "Lewatkan"
   di kanan atas.
3. Urutan Komponen:
   - Stack Top: Full-bleed Photo (~54% tinggi layar, foto pertama rangkaian
     onboarding) + Bottom White Fade Gradient (`Colors.transparent` -> `#FFFFFF`)
     + Top-Right Pill Button "Lewatkan" (latar `Color(0xD9FFFFFF)`, radius 20 px).
   - Bottom Content Column: H1 rata tengah dengan 1 kata kunci berwarna #2A573F
     dan garis lengkung aksen tipis di bawahnya -> Body deskripsi 2 baris rata
     tengah -> Page Indicator (3 titik, titik 1 aktif) -> Primary Pill Button
     (menggunakan teks yang SAMA PERSIS dengan tombol pada Onboarding 2, misal
     "Lanjut", menggantikan teks lama "Get Started").
4. Ukuran, Spacing & Radius: Padding bawah konten 20 px horizontal; jarak judul
   ke deskripsi 12 px, deskripsi ke indikator 24 px, indikator ke tombol 24 px.
5. Tipografi & Warna: BG #FFFFFF; "Lewatkan" Caption Bold #1E2621; Judul H1
   #1E2621 + kata kunci #2A573F; Deskripsi Body #5A635E; Dot aktif #2A573F
   (lebar 20 px), nonaktif #EAECE9 (8 px); CTA #2A573F teks #FFFFFF (radius 25 px).
6. Interaksi: Tap "Lewatkan" melompat langsung melewati seluruh onboarding ke
   [05] Login; swipe horizontal atau tap CTA berpindah ke [03] Onboarding 2.
7. Navigasi: Masuk dari [01] Splash -> Keluar ke [03] Onboarding 2 atau [05] Login.
8. UI States: Static screen dengan image placeholder (#EAECE9) saat aset dimuat.
9. Validasi & Pesan Error: Tidak ada input form.

--------------------------------------------------------------------------------
[03] ONBOARDING 2 — PILIH PERIODE & CEK STOK
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menjelaskan kemudahan memilih periode tanggal sewa dan
   mengecek ketersediaan stok perlengkapan (Pengguna baru).
2. Struktur Layout & Hierarki: Identik dengan [02] untuk menjaga kesatuan
   rangkaian visual onboarding, menggunakan foto kedua rangkaian onboarding
   dan tombol "Lewatkan" di kanan atas.
3. Urutan Komponen:
   - Stack Top: Full-bleed Photo (~54% tinggi layar, foto kedua) + Bottom White
     Fade Gradient -> `#FFFFFF` + Top-Right Pill Button "Lewatkan".
   - Bottom Content Column: H1 rata tengah dengan penekanan warna #2A573F ->
     Body deskripsi 2 baris rata tengah -> Page Indicator (titik ke-2 aktif) ->
     Primary Pill Button (teks konsisten sesuai implementasi Onboarding 2, misal
     "Lanjut").
4. Ukuran, Spacing & Radius: Identik dengan [02].
5. Tipografi & Warna: Identik dengan [02].
6. Interaksi: Swipe kiri/kanan, tap "Lewatkan" menuju [05] Login, atau tap CTA
   menuju [04] Onboarding 3.
7. Navigasi: Masuk dari [02] -> Keluar ke [04] Onboarding 3 atau [05] Login.
8. UI States: Static screen dengan image placeholder.
9. Validasi & Pesan Error: Tidak ada input form.

--------------------------------------------------------------------------------
[04] ONBOARDING 3 — SIAP BERPETUALANG (DIPERTAHANKAN UTUH)
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengajak pengguna mulai menjelajahi dan menyewa
   perlengkapan camping di CAKU (Pengguna baru).
2. Struktur Layout & Hierarki: Mempertahankan struktur, konten, foto ketiga,
   dan perilaku yang sudah disetujui sebelumnya, TANPA menambahkan tombol
   "Lewatkan" di kanan atas.
3. Urutan Komponen: Image Container (4:3, foto ketiga rangkaian onboarding) ->
   H1 judul Onboarding 3 -> Body deskripsi -> Page Indicator (titik ke-3 aktif) ->
   Primary/Accent Pill Button akhir (sesuai fungsi penyelesaian onboarding).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; radius tombol 25 px.
5. Tipografi & Warna: BG #FFFFFF; Judul H1 #1E2621; Deskripsi Body #5A635E;
   Dot aktif #2A573F; CTA pill sesuai implementasi yang disetujui.
6. Interaksi: Swipe kanan kembali ke [03]; tap tombol akhir menyimpan status
   selesai onboarding dan menuju [05] Login.
7. Navigasi: Masuk dari [03] -> Keluar ke [05] Login.
8. UI States: Static screen dengan image placeholder.
9. Validasi & Pesan Error: Tidak ada input form.

--------------------------------------------------------------------------------
[05] LOGIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Autentikasi masuk ke akun CAKU (Semua pengguna terdaftar:
   Customer dan Admin).
2. Struktur Layout & Hierarki: 390 x 844 px. SingleChildScrollView di atas latar
   bersih #FFFFFF tanpa Bottom Bar, mengadopsi komposisi judul besar rata kiri
   dan kotak input lembut Mist Stone dengan label di atas serta ikon kanan.
   (Tanpa fitur Forgot Password / Reset Password / OTP).
3. Urutan Komponen: Logo CAKU (52x52 px) -> H1 "Selamat Datang Kembali" -> Body
   subjudul -> Boxed Input Email (ikon surat di kanan) -> Boxed Input Password
   (toggle mata di kanan) -> Primary Pill Button "Login" (#2A573F) -> Row teks
   "Belum punya akun? Daftar sekarang".
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; logo ke judul 20 px;
   subjudul ke input email 28 px; antar-input 16 px; input ke CTA 28 px.
5. Tipografi & Warna: BG #FFFFFF; H1 #1E2621; Subjudul Body #5A635E; Input BG
   #F6F7F5 radius 14 px, border default #E4E7E3, Focus #2A573F, Error #A32929;
   CTA #2A573F teks #FFFFFF (radius 25 px).
6. Interaksi: Toggle visibilitas password, tap "Login" memvalidasi & mengirim
   kredensial, tap "Daftar sekarang" menuju [06] Registrasi.
7. Navigasi: Masuk dari [02]–[04] atau Logout -> Keluar ke [06] Registrasi,
   [07] Home Customer (jika role Customer), atau [18] Dashboard Admin (jika role Admin).
8. UI States:
   - Initial: Field kosong, tombol Login aktif.
   - Loading: Tombol Login menampilkan spinner putih & disabled.
   - Error: Feedback popup / snackbar error (#A32929) jika autentikasi gagal.
9. Validasi & Pesan Error:
   - Email kosong -> "Email wajib diisi"
   - Format email salah -> "Format email tidak valid"
   - Password kosong -> "Password wajib diisi"
   - Kredensial salah -> "Email atau password tidak sesuai"

--------------------------------------------------------------------------------
[06] REGISTRASI
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Pendaftaran akun pengguna baru dengan role default Customer
   (Calon pengguna baru).
2. Struktur Layout & Hierarki: 390 x 844 px. AppBar dengan Circular Back Button
   + SingleChildScrollView vertikal di atas latar #FFFFFF menggunakan komponen
   Boxed Input yang sama dengan [05] Login.
3. Urutan Komponen: AppBar (Circular Back Button) -> H1 "Buat Akun CAKU" ->
   Body subjudul -> Boxed Input Nama Lengkap -> Boxed Input Nomor WhatsApp ->
   Boxed Input Email -> Boxed Input Password (toggle mata) -> Boxed Input
   Konfirmasi Password (toggle mata) -> Primary Pill Button "Daftar Sekarang" ->
   Link "Sudah punya akun? Masuk".
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-input 16 px; input
   ke CTA 24 px; bottom padding 32 px.
5. Tipografi & Warna: Konsisten dengan [05] Login.
6. Interaksi: Input teks & numerik telepon, toggle visibilitas pada kedua field
   password, submit pendaftaran, tap link "Masuk".
7. Navigasi: Masuk dari [05] Login -> Keluar kembali ke [05] Login setelah sukses
   atau tap Back/Masuk.
8. UI States:
   - Initial & Loading (spinner pada tombol).
   - Success Popup: Mengadopsi modal/bottom-sheet putih bersih (radius 24 px)
     dengan ikon centang hijau, judul "Pendaftaran Berhasil", deskripsi singkat,
     dan tombol pill "Masuk Sekarang" menuju [05] Login (tanpa popup OTP/email).
   - Error: Feedback error dari server.
9. Validasi & Pesan Error:
   - Nama kosong -> "Nama lengkap wajib diisi"
   - Nomor WA kosong/tidak valid -> "Masukkan nomor WhatsApp yang valid"
   - Email kosong/tidak valid -> "Format email tidak valid"
   - Password kosong/kurang -> "Password minimal sesuai ketentuan sistem"
   - Konfirmasi password tidak cocok -> "Konfirmasi password tidak cocok"

--------------------------------------------------------------------------------
[07] HOME CUSTOMER
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Halaman utama penemuan perlengkapan camping & pintasan
   kategori sewa (Customer — Tab Utama 1).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan **Floating
   Bottom Navigation Bar** di bawah. Hierarki: (1) Brand Logo & Aksi Keranjang/
   Profil, (2) Search Bar + Tombol Filter, (3) Hero Promo Banner 2 Sisi,
   (4) Kategori Populer, (5) Grid Rekomendasi Perlengkapan 2 Kolom.
3. Urutan Komponen:
   - Top AppBar Row: Logo Mark CAKU + teks "CAKU" (H2 Bold #1E2621) di kiri;
     Row 2 Circular Icon Buttons (`44x44 px`, latar #F6F7F5) di kanan:
     (a) Cart Icon Button dengan badge Coral Ember (#FF7761) jumlah item -> [10],
     (b) Profile Icon Button -> tab [14] Profil. (Tanpa ikon kategori di header
     karena kategori berada pada tab Jelajahi di Floating Bottom Bar).
   - Search & Filter Row: Search Trigger Pill (`Expanded`, latar #F6F7F5,
     radius 14 px, ikon search + "Cari perlengkapan camping...") + Square-Rounded
     Filter Icon Button (`48x48 px`, latar #E7F2EC, ikon filter #2A573F).
   - Hero Banner Card: Latar #E7F2EC, radius 16 px, padding 16 px, komposisi
     2 sisi: Kiri [H2 #2A573F "Lengkapi Petualanganmu", Caption #1E2621 subjudul
     2 baris, Small Pill Button #2A573F teks #FFFFFF "Jelajahi Katalog"]; Kanan
     [Foto perlengkapan camping realistis].
   - Section Kategori Populer: Header Row [H3 "Kategori Perlengkapan" + TextButton
     "Lihat Semua" (#2A573F)] -> Horizontal ListView Category Icon Cards (kotak
     ikon membulat 56x56 px radius 14 px latar #F6F7F5 + label kategori 1 baris).
   - Section Rekomendasi: Header Row [H3 "Rekomendasi Perlengkapan" + TextButton
     "Lihat Semua"] -> 2-Column Grid Product Cards (foto 4:3, tanpa ikon love,
     pill kategori kecil, nama barang 2 baris max, harga sewa/hari #2A573F Bold,
     info stok unit).
   - Floating Bottom Navigation Bar (Tab Home aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-section 20 px;
   grid gap 12 px; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Cart Badge
   #FF7761 teks #1F1512; Harga Body Strong #2A573F.
6. Interaksi:
   - Tap Search Bar -> membuka [08] Jelajahi dengan autofocus pada kolom cari.
   - Tap Filter Button / "Lihat Semua" / Category Card -> membuka [08] Jelajahi.
   - Tap Cart Icon -> [10] Keranjang; Tap Profile Icon -> tab [14] Profil.
   - Tap Product Card -> [09] Detail Barang.
7. Navigasi: Masuk dari [01] atau [05] -> Keluar ke [08], [09], [10], [12], [14].
8. UI States: Loading (skeleton kategori & 4 kartu produk), Empty, Error + Retry,
   Success.
9. Validasi & Pesan Error: Tidak ada form input langsung.

--------------------------------------------------------------------------------
[08] JELAJAHI / CATALOG (KATEGORI & PENCARIAN)
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Pencarian, penyaringan kategori, dan pengurutan seluruh
   katalog perlengkapan camping (Customer — Tab Utama 2 pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Menggunakan komponen Search Bar, Category Chips, dan Product
   Card yang seragam dengan [07] Home.
3. Urutan Komponen: AppBar ("Jelajahi" + Circular Cart Icon Button ber-badge) ->
   Row [Search TextField (Expanded, latar #F6F7F5, mendukung autofocus & tombol
   clear `x`) + Sort Icon Button (`48x48 px`, latar #E7F2EC, ikon sort #2A573F)] ->
   Horizontal Category Chips ("Semua" + daftar kategori dari database) ->
   2-Column Product Grid (foto 4:3, pill kategori, nama alat, harga sewa/hari,
   info stok / badge "Stok Habis") -> Floating Bottom Bar (Tab Jelajahi aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; gap Search & Sort 8 px;
   gap chip 8 px; grid gap 12 px; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Chip aktif BG #2A573F teks #FFFFFF; Chip
   nonaktif BG #F6F7F5 border #E4E7E3 teks #1E2621; Badge "Stok Habis" BG
   #EAECE9 teks #5A635E.
6. Interaksi: Ketik kata kunci pencarian, pilih chip kategori, pilih opsi urutkan
   (Terbaru, Harga Terendah, Harga Tertinggi, Nama A-Z), tap kartu barang ->
   [09] Detail Barang.
7. Navigasi: Masuk dari Floating Bottom Bar atau [07] Home -> Keluar ke [09]
   Detail Barang atau [10] Keranjang.
8. UI States: Loading (skeleton 6 kartu), Empty ("Perlengkapan tidak ditemukan"
   + Outlined Pill Button "Reset Filter"), Error + Retry, Success.
9. Validasi & Pesan Error: Pencarian menerima teks bebas; empty state jika
   tidak ada kecocokan.

--------------------------------------------------------------------------------
[09] DETAIL BARANG
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menampilkan informasi lengkap satu perlengkapan camping
   dan menambahkan jumlah unit ke keranjang sewa (Customer — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Mengadopsi layout
   framed rounded image di atas, header 2 kolom (Nama & Harga), deretan kotak
   atribut ringkas, deskripsi, serta Sticky White Action Bar di bawah. (Tanpa
   ikon favorite/love dan tanpa atribut non-sistem).
3. Urutan Komponen:
   - AppBar Row: Circular Back Button (`44x44 px`) di kiri + judul kategori/
     "Detail Barang" (H3 #1E2621) di tengah.
   - Framed Image Container: Padding horizontal 20 px, foto rasio wajib 4:3
     (`BoxFit.cover`, `Alignment.center`), sudut membulat `radius 20 px`.
   - Title & Price Row (2 Kolom): Kiri [H1 Nama Perlengkapan #1E2621]; Kanan
     [H2 Harga Sewa/hari #2A573F rata kanan + Caption "/hari"].
   - Attribute Pill Row: Kotak ringkas berlatar #F6F7F5 (radius 12 px, border
     #E4E7E3) menampilkan data nyata barang CAKU: (1) Kategori Barang, dan
     (2) Ketersediaan Stok Unit (misal "5 Unit Tersedia" atau "Stok Habis").
   - Description Section: Label H3 "Deskripsi" + Body Deskripsi lengkap barang.
   - Sticky White Bottom Bar: Latar #FFFFFF, border atas #E4E7E3, berisi Row
     [Stepper `[-] qty [+]` + Primary Pill Button "Tambah ke Keranjang" (#2A573F)].
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-section 16 px;
   bottom scroll clearance 96 px; Sticky Bar padding 16 px horizontal, 12 px
   vertikal + SafeArea.
5. Tipografi & Warna: BG #FFFFFF; Nama H1 #1E2621; Harga H2 #2A573F; Attribute
   Card BG #F6F7F5; CTA #2A573F teks #FFFFFF (Disabled: BG #EAECE9 teks #5A635E).
6. Interaksi: Tap Back -> kembali; Tap `-` / `+` mengatur kuantitas unit (min. 1,
   maks. sesuai stok tersedia); Tap "Tambah ke Keranjang" menyimpan item ke
   keranjang dan menampilkan snackbar "Ditambahkan ke keranjang" dengan aksi
   "Lihat Keranjang".
7. Navigasi: Masuk dari [07] Home atau [08] Jelajahi -> Keluar kembali ke
   halaman sebelumnya atau ke [10] Keranjang via snackbar.
8. UI States: Loading (skeleton), Error + Retry, Disabled State ("Stok Habis"
   saat stok == 0).
9. Validasi & Pesan Error: Kuantitas tidak dapat melebihi stok tersedia maupun
   kurang dari 1 saat stok > 0.

--------------------------------------------------------------------------------
[10] KERANJANG (MY CART)
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengatur satu periode tanggal sewa untuk semua alat di
   keranjang, mengubah kuantitas, dan memvalidasi stok (Customer — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Mengadopsi tata
   letak Cart Card 2 bagian dan Order Summary Card bersih di bawah (tanpa menu
   titik tiga, tanpa Add to Wishlist, tanpa Promo Code, dan tanpa Shipping).
3. Urutan Komponen:
   - AppBar: Circular Back Button (`44x44 px`) + Judul "Keranjang" rata tengah.
   - Rental Period Card: Kartu #F6F7F5 (radius 16 px, padding 16 px) dengan
     2 kolom pemilih tanggal (Tanggal Mulai & Tanggal Selesai).
   - List Cart Item Cards (BG #F6F7F5, border #E4E7E3, radius 16 px, padding 14 px):
     * Top Row: Thumbnail foto 4:3 (`76x58 px`, radius 12 px) + Kolom tengah
       [Nama Alat Body Strong #1E2621, Category Pill kecil #E7F2EC/#2A573F] +
       Harga/hari rata kanan (Body Strong #2A573F).
     * Divider tipis (`1 px #E4E7E3`).
     * Bottom Row: Peringatan stok merah (#A32929) di kiri jika melebihi stok +
       Kontrol kuantitas rata kanan [Icon Button Hapus (44x44 px) + Pill
       Stepper `[-] qty [+]`].
   - Order Summary Card: Kartu #F6F7F5 (radius 16 px, padding 16 px) berisi
     H3 "Ringkasan Biaya", baris "Durasi Sewa ([N] Hari)", baris "Total Unit",
     Divider, dan baris "Total Biaya" (H2 Bold #2A573F).
   - Sticky Bottom Bar: Primary Pill Button lebar penuh "Lanjutkan Checkout"
     (#2A573F, radius 25 px).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-card 12 px; jarak
   antar-section 20 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5; Date field BG #FFFFFF border
   #727874 (Focus #2A573F); Total H2 #2A573F; CTA #2A573F.
6. Interaksi: Pilih Tanggal Mulai & Tanggal Selesai; ubah jumlah item via stepper;
   tap ikon hapus item (menghapus item + snackbar konfirmasi); tap "Lanjutkan
   Checkout".
7. Navigasi: Masuk dari ikon Cart [07]/[08] atau snackbar [09] -> Keluar ke
   [11] Checkout atau kembali ke halaman sebelumnya.
8. UI States:
   - Empty: Ilustrasi ikon keranjang + teks "Keranjang sewamu masih kosong" +
     Primary Pill Button "Jelajahi Perlengkapan" menuju [08].
   - Validation / Disabled: Jika tanggal belum lengkap atau kuantitas melebihi
     stok tersedia, tombol "Lanjutkan Checkout" dalam Disabled State (#EAECE9).
9. Validasi & Pesan Error:
   - Tanggal selesai sebelum tanggal mulai -> "Tanggal selesai tidak boleh lebih
     awal dari tanggal mulai".
   - Kuantitas melebihi stok -> "Jumlah melebihi stok tersedia ([N] unit)".

--------------------------------------------------------------------------------
[11] CHECKOUT
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengonfirmasi rincian penyewaan, informasi transfer bank,
   dan memproses pembuatan pesanan/bukti bayar (Customer — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   komponen kartu Mist Stone (`#F6F7F5`), pill button, dan pola rincian yang
   konsisten dengan [10] Keranjang.
3. Urutan Komponen: AppBar (Circular Back Button + "Checkout") -> Card Info
   Penyewa & Periode (Nama, WhatsApp, Tanggal Mulai–Selesai, Durasi) -> Card
   Ringkasan Barang -> Card Info Rekening Transfer (Nama Bank, No. Rekening,
   Atas Nama + Small Outlined Pill Button "Salin") -> Upload Box Bukti Transfer
   (kondisional sesuai Skenario A/B) -> Sticky Bottom Bar (Total Pembayaran +
   Primary Pill Button "Buat Pesanan").
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-card 16 px; tinggi
   pratinjau bukti transfer maks. 200 px (`BoxFit.contain`).
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Tombol Salin
   border #2A573F teks #2A573F; Upload Box dashed border #727874; Total H2
   #2A573F; CTA #2A573F.
6. Interaksi:
   - Tap "Salin" menyalin nomor rekening ke clipboard + snackbar "Nomor rekening
     berhasil disalin".
   - Perilaku Upload Bukti & CTA "Buat Pesanan" mengikuti dua skenario integrasi
     (hanya satu skenario aktif sesuai konfirmasi backend):
     * Skenario A (Upload sebelum transaksi dibuat): Upload Box tampil aktif di
       Checkout; tombol "Buat Pesanan" berada dalam Disabled State (#EAECE9)
       hingga bukti transfer berhasil diunggah.
     * Skenario B (Transaksi dibuat terlebih dahulu, lalu upload dengan ID
       transaksi): Tombol "Buat Pesanan" aktif berdasarkan validasi data pesanan;
       setelah transaksi berhasil dibuat, pengguna diarahkan/ditampilkan langkah
       upload bukti pembayaran menggunakan ID transaksi yang baru terbentuk.
7. Navigasi: Masuk dari [10] Keranjang -> Keluar setelah selesai ke [12] Sewa
   Saya atau [13] Detail Transaksi Customer.
8. UI States: Upload States (Empty, Preview + Ganti/Hapus, Progress, Success,
   Failure #A32929); Submission States (Loading spinner, Success Popup /
   navigasi & bersihkan keranjang, Failure feedback).
9. Validasi & Pesan Error: File gambar harus memenuhi format & batas ukuran yang
   diterima sistem; menampilkan pesan error spesifik jika upload/pesanan gagal.

--------------------------------------------------------------------------------
[12] SEWA SAYA / MY RENTALS
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Memantau status dan riwayat seluruh transaksi penyewaan
   perlengkapan (Customer — Tab Utama 3 pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Menggunakan Filter Chips dan Transaction Cards (#F6F7F5) yang
   seragam dengan seluruh aplikasi.
3. Urutan Komponen: AppBar ("Sewa Saya") -> Horizontal Filter Chips (Semua,
   Pending, Approved, Ongoing, Completed, Rejected) -> ListView Transaction
   Cards (Header: ID Transaksi + Status Badge [ikon+teks] + Overdue Badge jika
   telat; Body: Tanggal Mulai–Selesai, jumlah jenis/unit barang; Footer: Total
   Biaya + info estimasi denda berjalan jika telat) -> Floating Bottom Bar
   (Tab Sewa Saya aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-kartu 12 px; Card
   radius 16 px, padding 16 px; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Chip aktif BG
   #2A573F teks #FFFFFF; Chip nonaktif BG #F6F7F5 border #E4E7E3 teks #1E2621;
   Status Badge mengikuti token WCAG AA (Pending #FFF0D9/#8A4A0B, Approved
   #E7F2EC/#2A573F, Ongoing #E5EFF8/#2E5B7A, Completed #2A573F/#FFFFFF,
   Rejected #FCE8E8/#A32929); Overdue Badge BG #FCE8E8 text #A32929 ("Terlambat").
6. Interaksi: Tap chip filter status; pull-to-refresh daftar; tap kartu
   transaksi -> [13] Detail Transaksi Customer.
7. Navigasi: Masuk dari Floating Bottom Bar atau pasca-Checkout [11] -> Keluar
   ke [13] Detail Transaksi Customer.
8. UI States: Loading (skeleton 4 kartu), Empty ("Belum ada transaksi [nama
   filter]" + Primary Pill Button "Mulai Menyewa" jika kosong), Error + Retry,
   Success.
9. Validasi & Pesan Error: Tidak ada input form.

--------------------------------------------------------------------------------
[13] DETAIL TRANSAKSI CUSTOMER
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Melihat rincian lengkap satu transaksi sewa, bukti
   pembayaran, informasi keterlambatan/denda, dan hasil pengembalian (Customer —
   Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   komponen kartu Mist Stone (#F6F7F5), Status Badge, dan Sticky Bottom Bar
   yang konsisten dengan [10] & [11].
3. Urutan Komponen: AppBar (Circular Back Button + "Detail Transaksi") ->
   Header Status & ID (ID Transaksi, Status Badge, Overdue Badge jika telat,
   label turunan jika dibatalkan vs ditolak) -> Overdue Warning Banner
   (kondisional) -> Rental Period Card -> Item List Card -> Payment Proof Card
   (pratinjau gambar + komponen upload kondisional jika Skenario B aktif) ->
   Return Condition Card (kondisional saat Completed) -> Sticky Bottom Bar
   (Danger Outlined Pill Button "Hapus Transaksi" khusus status Pending).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-card 16 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Warning
   Banner BG #FCE8E8 border #A32929 text #A32929; Tombol Hapus border & text #A32929.
6. Interaksi:
   - Tap pratinjau bukti transfer -> membuka tampilan gambar layar penuh (zoom).
   - Kondisional Skenario B (jika transaksi dibuat sebelum upload): Ketika
     status transaksi masih membutuhkan bukti pembayaran dan bukti belum tersedia,
     tampilkan komponen upload (tombol pilih gambar, preview, indikator progres
     upload, status berhasil/gagal). Komponen upload disembunyikan jika bukti
     sudah terverifikasi atau status transaksi tidak lagi mengizinkan upload.
   - Tap "Hapus Transaksi" (hanya tampil saat status Pending) -> memunculkan
     Confirmation Popup -> menghapus transaksi.
   - Pembedaan Status Rejected: Tanpa menambah status database baru, apabila
     backend menyediakan keterangan sumber pembatalan/alasan penolakan, tampilkan
     informasi yang jelas (misal: "Dibatalkan oleh Admin" beserta alasannya vs
     "Permohonan Sewa Ditolak").
7. Navigasi: Masuk dari [12] Sewa Saya -> Keluar kembali ke [12] Sewa Saya.
8. UI States: Loading, Error + Retry, Conditional Blocks (Overdue, Bukti Upload
   Skenario B, Return Info, Cancellation Note), Confirmation Popup + Loading
   Action saat hapus transaksi Pending.
9. Validasi & Pesan Error: Validasi format/ukuran file jika komponen upload
   Skenario B aktif; pesan error jelas jika penghapusan gagal.

--------------------------------------------------------------------------------
[14] PROFIL CUSTOMER
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menampilkan informasi akun Customer, status/akses
   permohonan menjadi Admin, dan menu pengaturan akun (Customer — Tab Utama 4
   pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Mengadopsi tata letak profil horizontal 2 kolom dari referensi
   (Avatar bulat besar di kiri; Nama, info akun, dan tombol aksi sejajar di
   kanan), tanpa fitur sosial (Follower/Following/Bookmark/Follow).
3. Urutan Komponen:
   - AppBar: Judul "Profil" rata kiri (H1 #1E2621).
   - Horizontal Profile Header Row:
     * Kiri: Avatar bulat 76x76 px read-only (foto user jika ada atau lingkaran
       #2A573F dengan inisial nama putih).
     * Kanan: H2 Nama Lengkap (#1E2621), Caption Email & Nomor WhatsApp (#5A635E),
       serta Row 2 Tombol Aksi Sejajar:
       (a) Accent Pill Button kecil "Edit Profil" (#FF7761, teks #1F1512) -> [15],
       (b) Rounded Square Icon Button "Ubah Password" (`40x40 px`, latar #F6F7F5,
           border #E4E7E3, ikon kunci #1E2621) -> [16].
   - Divider tipis (`1 px #E4E7E3`).
   - Admin Application Status Card: Kartu #F6F7F5 (radius 16 px, padding 16 px)
     menampilkan 1 akses terpadu Permohonan Menjadi Admin -> [17].
   - Grouped Menu Card: Kartu #F6F7F5 (radius 16 px) berisi menu "Edit Profil",
     "Ubah Password", dan "Tentang CAKU" (dipisah Divider #E4E7E3).
   - Danger Outlined Pill Button "Logout" (`#A32929`, radius 25 px).
   - Floating Bottom Bar (Tab Profil aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-bagian 20 px;
   tinggi baris menu min. 52 px; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5; Tombol Edit Profil #FF7761
   teks #1F1512; Ikon menu #2A573F; Logout border & teks #A32929.
6. Interaksi: Tap "Edit Profil" -> [15]; Tap ikon/menu "Ubah Password" -> [16];
   Tap kartu Permohonan Admin -> [17]; Tap "Tentang CAKU" -> Info Popup versi
   & deskripsi CAKU; Tap "Logout" -> Confirmation Popup -> keluar ke [05] Login.
7. Navigasi: Masuk dari Floating Bottom Bar atau ikon Profil Home -> Keluar ke
   [15], [16], [17], atau [05].
8. UI States: Loading / Error + Retry; Conditional State Kartu Admin (ajakan
   "Daftar Menjadi Admin" vs status Pending/Approved/Rejected); Confirmation
   Popup saat Logout.
9. Validasi & Pesan Error: Avatar murni informasi visual read-only (tidak ada
   aksi upload/ubah foto profil).

--------------------------------------------------------------------------------
[15] EDIT PROFIL
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Memperbarui Nama Lengkap dan Nomor WhatsApp pengguna
   (Customer & Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   komponen Boxed Input Mist Stone dan Primary Pill Button yang sama dengan
   [05] Login & [06] Registrasi.
3. Urutan Komponen: AppBar (Circular Back Button + "Edit Profil") -> Read-Only
   Boxed Input Email (BG #EAECE9, ikon gembok) -> Editable Boxed Input Nama
   Lengkap -> Editable Boxed Input Nomor WhatsApp -> Primary Pill Button
   "Simpan Perubahan" (#2A573F). (Tanpa kontrol upload avatar).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-field 16 px; jarak
   ke CTA 24 px.
5. Tipografi & Warna: BG #FFFFFF; Field editable BG #F6F7F5 border #E4E7E3
   (Focus #2A573F); Field read-only BG #EAECE9 teks #5A635E; CTA #2A573F.
6. Interaksi: Ubah teks Nama & Nomor WhatsApp; tap "Simpan Perubahan".
7. Navigasi: Masuk dari [14] Profil Customer atau [28] Profil Admin -> Keluar
   kembali ke halaman Profil pemanggil setelah berhasil menyimpan.
8. UI States: Initial (terisi data akun saat ini), Loading Submission (spinner
   pada tombol), Success Popup/Snackbar ("Profil berhasil diperbarui" + pop),
   Failure Feedback (jika endpoint belum tersedia atau gagal).
9. Validasi & Pesan Error (Catatan Integrasi Logic):
   - Nama kosong -> "Nama lengkap tidak boleh kosong"
   - Nomor WA kosong/tidak valid -> "Nomor WhatsApp tidak valid"
   - Catatan Implementasi: Saat ini halaman Edit Profil belum memiliki logic
     backend terhubung; tombol Simpan wajib dihubungkan ke API pembaruan profil
     pengguna yang sebenarnya (lihat Bab 5.9).

--------------------------------------------------------------------------------
[16] UBAH PASSWORD
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengganti kata sandi akun pengguna secara aman (Customer
   & Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan 3
   komponen Boxed Input Password (dengan toggle mata) dan Primary Pill Button
   yang sama dengan [05] Login.
3. Urutan Komponen: AppBar (Circular Back Button + "Ubah Password") -> Boxed
   Input Password Lama (toggle mata) -> Boxed Input Password Baru (toggle mata) ->
   Boxed Input Konfirmasi Password Baru (toggle mata) -> Primary Pill Button
   "Simpan Password" (#2A573F).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-field 16 px; jarak
   ke CTA 24 px.
5. Tipografi & Warna: Konsisten dengan [05] Login & [15] Edit Profil.
6. Interaksi: Toggle visibilitas karakter pada tiap field, validasi input, tap
   "Simpan Password".
7. Navigasi: Masuk dari [14] Profil Customer atau [28] Profil Admin -> Keluar
   kembali ke halaman Profil pemanggil setelah sukses.
8. UI States: Initial, Loading Submission, Success Popup/Snackbar + pop,
   Failure Feedback (pesan error dari server).
9. Validasi & Pesan Error (Catatan Integrasi Logic):
   - Password lama kosong -> "Password lama wajib diisi"
   - Password baru kosong -> "Password baru wajib diisi"
   - Konfirmasi tidak cocok -> "Konfirmasi password baru tidak sesuai"
   - Password lama salah -> "Password lama tidak sesuai"
   - Catatan Implementasi: Saat ini halaman Ubah Password belum memiliki logic
     autentikasi terhubung; wajib diverifikasi dan disambungkan ke mekanisme
     change-password sistem yang sebenarnya (lihat Bab 5.9).

--------------------------------------------------------------------------------
[17] FORM PENGAJUAN ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengajukan permohonan menjadi Admin pengelola inventaris
   dan melihat status atau alasan penolakan pengajuan (Customer — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   kartu Mist Stone (#F6F7F5), Status Pill, Boxed Multiline Input, dan Primary
   Pill Button yang konsisten dengan seluruh aplikasi.
3. Urutan Komponen: AppBar (Circular Back Button + "Permohonan Menjadi Admin") ->
   Info Card tanggung jawab Admin (#F6F7F5) -> Status Card (kondisional jika
   sudah pernah mengajukan) -> Rejection Reason Card (kondisional jika Rejected
   & alasan tersedia) -> Boxed Multiline Textarea "Alasan Pengajuan" (min. 4
   baris, radius 14 px) -> Primary Pill Button "Ajukan Permohonan" / "Ajukan
   Kembali" (#2A573F).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-elemen 16 px;
   textarea padding 14 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5; Textarea BG #F6F7F5 border
   #E4E7E3 (Focus #2A573F); Status Pill mengikuti token Pending/Approved/Rejected.
6. Interaksi: Isi alasan pengajuan (wajib), tap tombol kirim; jika status
   Rejected, form terbuka kembali untuk pengajuan ulang.
7. Navigasi: Masuk dari [14] Profil Customer -> Keluar kembali ke [14].
8. UI States (4 Kondisi Status):
   - Belum Mengajukan: Form aktif + tombol "Ajukan Permohonan".
   - Pending: Badge Pending, tanggal pengajuan & alasan tersimpan (read-only),
     tombol ajukan disembunyikan.
   - Approved: Badge Approved + informasi bahwa akun telah disetujui sebagai
     Admin (dengan catatan login ulang jika pembaruan sesi diperlukan).
   - Rejected: Badge Rejected + kotak alasan penolakan dari Admin + form aktif
     untuk mengajukan kembali.
9. Validasi & Pesan Error:
   - Alasan pengajuan kosong -> "Alasan pengajuan wajib diisi".

--------------------------------------------------------------------------------
[18] DASHBOARD ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Pusat ringkasan operasional penyewaan alat camping,
   statistik prioritas, pendapatan, dan pintasan cepat (Admin — Tab Utama 1
   pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Menggunakan palet, kartu Mist Stone, pill chips, dan Transaction
   Cards yang seragam dengan halaman Customer.
3. Urutan Komponen:
   - Header Row: Logo Mark CAKU + Greeting Admin (H2 #1E2621) di kiri; Badge
     Role "Admin" (#2A573F teks #FFFFFF) di kanan.
   - Revenue Summary Card: Kartu sorotan berlatar #E7F2EC (radius 16 px,
     padding 16 px) menampilkan Total Pendapatan (H1 #2A573F), rincian
     Pendapatan Sewa, dan Pendapatan Denda.
   - 2x2 Stat Grid (Card BG #F6F7F5, border #E4E7E3, radius 16 px):
     Card 1 "Menunggu Persetujuan" (Pending, aksen #8A4A0B), Card 2 "Transaksi
     Terlambat" (Overdue, aksen #A32929), Card 3 "Penyewaan Berlangsung"
     (Ongoing, aksen #2E5B7A), Card 4 "Total Transaksi" -> diikuti Summary
     Strip "Total Inventaris Barang".
   - Quick Actions Row/Grid (Pintasan ke subhalaman non-Bottom Bar):
     (a) "Laporan Pendapatan" -> [25], (b) "Permohonan Admin" (ber-badge
     #FF7761 jika ada antrean) -> [26], (c) "+ Tambah Barang" -> [21].
   - Recent Transactions Section: Header + 3–5 kartu transaksi terbaru.
   - Floating Bottom Bar Admin (Tab Dashboard aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; grid gap 12 px; antar-
   section 20 px; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Stat Card BG #F6F7F5; Quick Action chips
   BG #F6F7F5 border #E4E7E3 teks #1E2621.
6. Interaksi: Tap kartu statistik mengarah ke daftar terfilter terkait (misal
   Pending -> [22] filter Pending); tap Quick Actions; tap Recent Transaction ->
   [23] Detail Transaksi Admin.
7. Navigasi: Masuk dari [01] atau [05] -> Keluar ke [19], [21], [22], [23],
   [25], [26], [28].
8. UI States: Loading (skeleton grid & list), Empty (pada Recent Transactions jika
   kosong), Error + Retry, Success (angka real dari backend, tanpa data dummy).
9. Validasi & Pesan Error: Tidak ada input form langsung.

--------------------------------------------------------------------------------
[19] MANAJEMEN BARANG
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mengelola inventaris perlengkapan camping serta mengakses
   pengelolaan kategori (Admin — Tab Utama 2 pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Menggunakan komponen Search Bar, Filter Chips, dan Item Card
   Mist Stone yang konsisten dengan katalog Customer.
3. Urutan Komponen: AppBar ("Manajemen Barang" + Small Primary Pill Button
   "+ Tambah" #2A573F) -> Search Bar (#F6F7F5) -> Row [Filter Chips (Kategori &
   Stok) + Outlined Pill Button "Kelola Kategori"] -> ListView Item Cards (BG
   #F6F7F5, foto 4:3 `68x52 px` radius 12 px, nama barang, kategori pill,
   harga/hari, info stok, Circular Edit Button 44x44 px, Circular Delete Button
   44x44 px) -> Floating Bottom Bar Admin (Tab Barang aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-kartu 12 px;
   bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Ikon Edit
   #2A573F; Ikon Hapus #A32929; Stok 0 ditampilkan dengan teks #A32929.
6. Interaksi: Search nama barang; filter kategori/stok; tap "Kelola Kategori" ->
   [20]; tap "+ Tambah" -> [21] (Mode Tambah); tap Edit -> [21] (Mode Edit);
   tap Hapus -> Confirmation Popup -> hapus barang.
7. Navigasi: Masuk dari Floating Bottom Bar -> Keluar ke [20] Kelola Kategori
   atau [21] Form Tambah/Edit Barang.
8. UI States: Loading, Empty ("Belum ada perlengkapan"), Error + Retry,
   Confirmation Popup + Loading Action + Success/Failure Feedback saat hapus.
9. Validasi & Pesan Error: Menampilkan pesan error dari backend apabila
   penghapusan barang ditolak karena keterkaitan data transaksi.

--------------------------------------------------------------------------------
[20] KELOLA KATEGORI
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Melihat, mencari, menambah, mengubah, dan menghapus
   kategori perlengkapan camping (Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Subhalaman daftar
   di atas latar #FFFFFF dengan Modal Dialog untuk form Tambah dan Edit kategori.
3. Urutan Komponen: AppBar (Circular Back Button + "Kelola Kategori" + Small
   Primary Pill Button "+ Tambah") -> Search Bar kategori (#F6F7F5) -> ListView
   Category Cards (BG #F6F7F5, Nama kategori + Circular Edit Button 44x44 px +
   Circular Delete Button 44x44 px) -> Modal Dialog Tambah/Edit Kategori (1
   Boxed Input Nama Kategori + Outlined Pill "Batal" & Primary Pill "Simpan") ->
   Confirmation Popup Hapus -> Error/Rejection Info Popup.
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-baris 10 px; Modal
   Dialog radius 24 px, padding 20 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Modal BG
   #FFFFFF; Input BG #F6F7F5 (Focus #2A573F); Tombol Simpan #2A573F; Ikon Hapus
   #A32929.
6. Interaksi:
   - Tambah: Tap "+ Tambah" -> Modal Dialog kosong -> isi nama -> Simpan.
   - Edit: Tap ikon Edit -> Modal Dialog terisi nama lama -> ubah -> Simpan.
   - Hapus: Tap ikon Hapus -> Confirmation Popup ("Yakin ingin menghapus
     kategori [Nama]?") -> konfirmasi -> proses hapus di backend.
7. Navigasi: Masuk dari [19] Manajemen Barang -> Keluar kembali ke [19].
8. UI States:
   - List: Initial Loading, Empty State, Error State + Retry.
   - Modal Form: Validation Error, Loading Submission, Success Feedback (snackbar
     "Kategori berhasil disimpan"), Failure Feedback.
   - Delete Action: Confirmation Popup, Loading Action, Success Feedback
     (snackbar "Kategori berhasil dihapus"), dan Rejected/Failure Feedback
     (popup informasi gagal menghapus — tidak pernah menampilkan pesan sukses
     jika backend menolak penghapusan).
9. Validasi & Pesan Error:
   - Nama kategori kosong -> "Nama kategori wajib diisi".
   - Nama kategori duplikat -> "Nama kategori sudah ada".
   - Kategori masih digunakan oleh barang -> "Kategori tidak dapat dihapus
     karena masih digunakan oleh satu atau lebih barang."

--------------------------------------------------------------------------------
[21] FORM TAMBAH / EDIT BARANG (1 TEMPLATE, 2 MODE)
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menambah perlengkapan camping baru (Mode Tambah) atau
   memperbarui data perlengkapan (Mode Edit) (Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. ScrollView form
   berkelompok di atas latar #FFFFFF menggunakan komponen Boxed Input Mist Stone
   dan Primary Pill Button yang seragam.
3. Urutan Komponen: AppBar (Circular Back Button + Judul dinamis: "Tambah Barang"
   / "Edit Barang") -> Image Upload Box (pratinjau rasio 4:3 radius 16 px +
   tombol pilih/ganti foto) -> Boxed Input Nama Barang -> Boxed Dropdown
   Kategori -> Boxed Multiline Input Deskripsi -> Boxed Input Numerik Harga
   Sewa Harian -> Boxed Input Numerik Denda Harian -> Boxed Input Numerik Stok ->
   Primary Pill Button ("Simpan Barang" / "Simpan Perubahan").
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-field 16 px; jarak
   ke CTA 24 px. Harga Sewa Harian & Denda Harian dapat ditampilkan 2 kolom
   (50:50) pada layar >= 390 px, dan otomatis tersusun vertikal 1 kolom pada
   layar lebih sempit agar nominal tetap terbaca penuh.
5. Tipografi & Warna: BG #FFFFFF; Input & Dropdown BG #F6F7F5 border #E4E7E3
   (Focus #2A573F); Error #A32929; CTA #2A573F.
6. Interaksi: Pilih/ganti foto barang, isi nama, pilih kategori dari dropdown,
   isi deskripsi, isi nominal harga, denda, dan stok, tap tombol Simpan.
7. Navigasi: Masuk dari [18] Dashboard atau [19] Manajemen Barang -> Keluar
   kembali ke halaman pemanggil setelah sukses.
8. UI States:
   - Mode Edit Initial: Seluruh field & foto lama dimuat otomatis.
   - Upload States: Empty Box, Image Preview, Upload Progress, Upload Failure.
   - Form States: Validation Error per field, Loading Submission, Success
     (snackbar + kembali), Failure (snackbar error).
9. Validasi & Pesan Error (Dipisah sesuai Karakteristik Data):
   - Foto (Mode Tambah): "Foto barang wajib diunggah".
   - Nama Barang: "Nama barang wajib diisi".
   - Kategori: "Pilih kategori barang".
   - Deskripsi: "Deskripsi barang wajib diisi".
   - Harga Sewa Harian (numerik format Rupiah): Wajib diisi dan bernilai lebih
     dari 0 -> "Harga sewa harian wajib diisi dan harus lebih dari Rp 0".
   - Denda Harian (numerik format Rupiah): Wajib diisi dan tidak negatif (>= 0,
     nilai 0 mengikuti ketentuan sistem jika diizinkan) -> "Denda harian wajib
     diisi dan tidak boleh negatif".
   - Stok (numerik bilangan bulat / integer): Wajib diisi, tidak negatif (>= 0),
     tanpa pecahan/desimal -> "Stok wajib berupa bilangan bulat minimal 0".

--------------------------------------------------------------------------------
[22] MANAJEMEN TRANSAKSI
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Memantau dan menyaring seluruh transaksi penyewaan dari
   seluruh pelanggan (Admin — Tab Utama 3 pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar. Menggunakan komponen yang identik dengan [12] Sewa Saya untuk
   menjaga keseragaman antarmuka transaksi.
3. Urutan Komponen: AppBar ("Manajemen Transaksi") -> Search Bar (ID Transaksi /
   Nama Pelanggan, BG #F6F7F5) -> Horizontal Filter Chips (Semua, Pending,
   Approved, Ongoing, Overdue, Completed, Rejected) -> ListView Transaction
   Cards (BG #F6F7F5, menampilkan Nama Pelanggan H3 #1E2621, ID Transaksi,
   Status Badge, Overdue Badge, periode sewa, dan total bayar) -> Floating
   Bottom Bar Admin (Tab Transaksi aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-kartu 12 px;
   bottom scroll padding 100 px.
5. Tipografi & Warna: Konsisten dengan [12] Sewa Saya.
6. Interaksi: Ketik search; pilih filter chip; pull-to-refresh; tap kartu
   transaksi -> [23] Detail Transaksi Admin.
7. Navigasi: Masuk dari Floating Bottom Bar atau kartu statistik [18] Dashboard ->
   Keluar ke [23] Detail Transaksi Admin.
8. UI States: Initial Loading (skeleton), Empty State sesuai filter, Error State
   + Retry, Success / Loaded State.
9. Validasi & Pesan Error: Pencarian teks bebas; empty state jika tidak cocok.

--------------------------------------------------------------------------------
[23] DETAIL TRANSAKSI ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Memeriksa detail penyewaan, bukti pembayaran, menghubungi
   pelanggan via WhatsApp, dan memproses perubahan status transaksi (Admin —
   Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   struktur kartu Mist Stone (#F6F7F5) dan Sticky Bottom Action Bar dinamis
   yang seragam dengan [13] Detail Transaksi Customer.
3. Urutan Komponen: AppBar (Circular Back Button + "Detail Transaksi") ->
   Header Status & ID (ID, Status Badge, Overdue Badge jika telat, label
   turunan jika dibatalkan vs ditolak) -> Customer Info Card (Nama, Email,
   WhatsApp + Outlined Pill Button "Hubungi via WhatsApp") -> Rental & Overdue
   Warning Card -> Item List Card -> Payment Proof Card (pratinjau foto dapat
   di-zoom) -> Cancellation/Rejection Note Card (kondisional) -> Conditional
   Sticky Bottom Action Bar.
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-card 16 px. Tombol
   ganda (Tolak | Setujui atau Batalkan | Mulai Penyewaan) memakai rasio lebar
   45:55 dengan gap 12 px dan radius 25 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Tombol
   Setujui / Mulai / Proses Pengembalian #2A573F; Tombol Tolak / Batalkan
   Outlined #A32929.
6. Interaksi:
   - Tap "Hubungi via WhatsApp" -> membuka aplikasi/tautan WhatsApp customer.
   - Tap Bukti Transfer -> tampilan gambar layar penuh (zoom).
   - Aksi Status Kondisional (seluruhnya diawali Confirmation Popup):
     * Status Pending:
       - "Tolak": Membuka Modal Dialog wajib isi Alasan Penolakan -> mengubah
         status menjadi Rejected.
       - "Setujui": Confirmation Popup -> mengubah status menjadi Approved.
     * Status Approved:
       - "Batalkan": Membuka Modal Dialog wajib isi Alasan Pembatalan ->
         mengubah status menjadi Rejected tanpa membuat status database baru.
       - "Mulai Penyewaan": Confirmation Popup -> mengubah status menjadi Ongoing.
     * Status Ongoing:
       - "Proses Pengembalian": Navigasi menuju [24] Proses Pengembalian.
     * Status Completed / Rejected: Tidak ada tombol aksi. Jika status database
       Rejected, tampilkan keterangan turunan ("Dibatalkan oleh Admin" vs
       "Ditolak") beserta alasannya apabila data tersedia dari backend.
7. Navigasi: Masuk dari [18] Dashboard atau [22] Manajemen Transaksi -> Keluar
   ke [24] Proses Pengembalian atau kembali ke [22].
8. UI States: Loading, Error + Retry, Modal Input Alasan Penolakan/Pembatalan
   wajib isi, Confirmation Popup, Loading Action, Success/Failure Feedback.
9. Validasi & Pesan Error: Input alasan penolakan/pembatalan oleh Admin wajib
   diisi ("Alasan wajib diisi sebelum melanjutkan").

--------------------------------------------------------------------------------
[24] PROSES PENGEMBALIAN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Mencatat hasil pemeriksaan kondisi pengembalian barang,
   catatan pemeriksaan, dan menyelesaikan perhitungan denda akhir (Admin —
   Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. ScrollView terstruktur
   di atas latar #FFFFFF + Sticky Bottom CTA.
3. Urutan Komponen: AppBar (Circular Back Button + "Proses Pengembalian") ->
   Rental Summary Header (#F6F7F5) -> ListView Per-Item Return Cards (BG
   #F6F7F5, foto 4:3 kecil, nama barang, jumlah unit disewa, pemilih kondisi
   dengan placeholder "Pilih kondisi" dan opsi: Baik | Rusak | Hilang, input
   catatan opsional per item) -> Fine Calculation Card (keterlambatan hari,
   rincian denda, total denda) -> Sticky Bottom Primary Pill Button "Selesaikan
   Pengembalian" (#2A573F).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-item card 12 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Placeholder
   "Pilih kondisi" #5A635E Control Border #727874; Opsi terpilih: "Baik"
   (#2A573F), "Rusak" (#C94632), "Hilang" (#A32929); Total Denda H2 #A32929
   (jika > 0) atau #2A573F (jika Rp 0).
6. Interaksi:
   - Kondisi awal setiap item adalah BELUM TERPILIH (placeholder "Pilih kondisi").
     Tidak ada opsi yang terpilih otomatis.
   - Admin wajib memilih salah satu kondisi (Baik, Rusak, atau Hilang) untuk
     setiap item transaksi yang tercantum.
   - Admin dapat mengisi catatan kondisi pada tiap item.
   - Tombol "Selesaikan Pengembalian" baru dapat digunakan setelah seluruh item
     memiliki pilihan kondisi -> memicu Confirmation Popup -> submit.
7. Navigasi: Masuk dari [23] Detail Transaksi Admin -> Keluar kembali ke [23]
   (status Completed) atau [22] Manajemen Transaksi setelah sukses.
8. UI States:
   - Initial: Seluruh item dalam keadaan "Pilih kondisi"; tombol "Selesaikan
     Pengembalian" dalam Disabled State (#EAECE9, teks #5A635E).
   - Validation Error: Jika ada item belum dipilih, tampilkan pesan error
     "Harap tentukan kondisi pengembalian untuk semua barang" dan sorot item
     yang belum diperiksa dengan border #A32929.
   - Info Kondisional Stok: Keterangan dampak perubahan stok akibat kondisi
     Baik/Rusak/Hilang hanya ditampilkan apabila aturan backend telah terkonfirmasi.
   - Confirmation Popup, Loading Action, Success Feedback, Failure Feedback.
9. Validasi & Pesan Error: Seluruh item wajib memiliki pilihan kondisi sebelum
   form dapat dikirim.

--------------------------------------------------------------------------------
[25] LAPORAN PENDAPATAN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menyajikan ringkasan dan rincian pemasukan dari biaya sewa
   dan denda berdasarkan rentang tanggal (Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. ScrollView di atas
   latar #FFFFFF menggunakan kartu Mist Stone (#F6F7F5) dan komponen pemilih
   tanggal yang sama dengan [10] Keranjang.
3. Urutan Komponen: AppBar (Circular Back Button + "Laporan Pendapatan") ->
   Date Range Filter Card (Tanggal Mulai & Tanggal Selesai) -> 2x2 Summary Grid
   (Total Transaksi, Pendapatan Sewa, Pendapatan Denda, Total Pendapatan) ->
   Bar Chart Card (batang #2A573F) -> Transaction Breakdown List Cards.
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; grid gap 12 px; antar-
   section 20 px; label sumbu X grafik maks. 6–7 label terlihat agar tidak
   bertumpuk.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Total
   Pendapatan H2 #2A573F; Label grafik Caption #5A635E.
6. Interaksi: Ubah tanggal mulai & selesai untuk memuat ulang laporan; scroll
   rincian transaksi penyumbang pendapatan.
7. Navigasi: Masuk dari Quick Action [18] Dashboard Admin atau menu di [28]
   Profil Admin -> Keluar kembali ke halaman pemanggil.
8. UI States:
   - Loading: Skeleton ringkasan 2x2 dan grafik.
   - Empty: Pesan "Tidak ada data pendapatan pada periode ini" (tanpa grafik dummy).
   - Error: Pesan gagal memuat laporan + tombol "Coba Lagi".
   - Success: Menampilkan angka dan grafik real dari backend.
9. Validasi & Pesan Error: Tanggal selesai tidak boleh lebih awal dari tanggal mulai.

--------------------------------------------------------------------------------
[26] DAFTAR PERMOHONAN ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menampilkan antrean dan riwayat pengajuan perubahan role
   menjadi Admin dari Customer (Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. Menggunakan
   Search Bar, Filter Chips, dan Applicant Cards (#F6F7F5) yang seragam dengan
   [22] Manajemen Transaksi.
3. Urutan Komponen: AppBar (Circular Back Button + "Permohonan Admin") ->
   Search Bar (nama pemohon, BG #F6F7F5) -> Horizontal Filter Chips (Semua,
   Pending, Approved, Rejected) -> ListView Applicant Cards (BG #F6F7F5, Nama
   pemohon, Status Badge, Email & WhatsApp, tanggal pengajuan, ringkasan alasan
   maks. 2 baris).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-kartu 12 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Status Badge
   sesuai token Pending (#FFF0D9/#8A4A0B), Approved (#E7F2EC/#2A573F), Rejected
   (#FCE8E8/#A32929).
6. Interaksi: Cari nama pemohon; pilih filter chip status; tap kartu pemohon ->
   [27] Detail Permohonan Admin.
7. Navigasi: Masuk dari Quick Action [18] Dashboard Admin atau menu di [28]
   Profil Admin -> Keluar ke [27] Detail Permohonan Admin atau kembali.
8. UI States: Initial Loading, Empty State ("Belum ada permohonan menjadi Admin"),
   Error State + Retry, Success / Loaded State.
9. Validasi & Pesan Error: Pencarian teks bebas; empty state jika tidak ditemukan.

--------------------------------------------------------------------------------
[27] DETAIL PERMOHONAN ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Meninjau profil dan alasan lengkap pemohon sebelum
   menyetujui atau menolak permohonan menjadi Admin (Admin — Subhalaman).
2. Struktur Layout & Hierarki: 390 x 844 px tanpa Bottom Bar. ScrollView detail
   pemohon di atas latar #FFFFFF + Sticky Bottom Action Bar khusus saat status
   Pending.
3. Urutan Komponen: AppBar (Circular Back Button + "Detail Permohonan") ->
   Applicant Profile Card (Avatar read-only, Nama, Email, WhatsApp, Tanggal
   Pengajuan, Status Badge) -> Full Reason Card (teks lengkap alasan pengajuan) ->
   Rejection Reason Card (kondisional jika status Rejected) -> Conditional Sticky
   Bottom Bar (Danger Outlined Pill Button "Tolak" + Primary Pill Button
   "Setujui Permohonan") -> Modal Dialog Input Alasan Penolakan Wajib.
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-card 16 px; rasio
   lebar tombol Tolak : Setujui = 45:55 dengan gap 12 px dan radius 25 px.
5. Tipografi & Warna: BG #FFFFFF; Card BG #F6F7F5 border #E4E7E3; Tombol Tolak
   border & teks #A32929; Tombol Setujui #2A573F.
6. Interaksi:
   - Tap "Tolak" -> memunculkan Modal Dialog dengan multiline text input wajib
     berlabel "Alasan Penolakan". Tombol konfirmasi penolakan dalam Disabled
     State (#EAECE9, teks #5A635E) selama alasan belum diisi.
   - Tap "Setujui Permohonan" -> Confirmation Popup -> konfirmasi -> mengubah
     status permohonan menjadi Approved dan role pemohon menjadi Admin.
7. Navigasi: Masuk dari [26] Daftar Permohonan Admin -> Keluar kembali ke [26]
   setelah keputusan berhasil diproses.
8. UI States: Loading, Error + Retry, Conditional Action Bar (hanya tampil saat
   Pending), Modal Validation Error, Confirmation Popup, Loading Action,
   Success & Failure Feedback.
9. Validasi & Pesan Error:
   - Alasan penolakan kosong -> "Alasan penolakan wajib diisi".

--------------------------------------------------------------------------------
[28] PROFIL ADMIN
--------------------------------------------------------------------------------
1. Tujuan & Pengguna: Menampilkan informasi akun Admin yang sedang login dan
   menyediakan akses ke pengaturan akun serta fitur administratif (Admin — Tab
   Utama 4 pada Floating Bottom Bar).
2. Struktur Layout & Hierarki: 390 x 844 px dengan latar #FFFFFF dan Floating
   Bottom Bar Admin. Menggunakan tata letak profil horizontal 2 kolom yang
   identik dengan [14] Profil Customer.
3. Urutan Komponen:
   - AppBar: Judul "Profil Admin" rata kiri (H1 #1E2621).
   - Horizontal Profile Header Row:
     * Kiri: Avatar bulat 76x76 px read-only (foto user jika ada atau lingkaran
       #2A573F dengan inisial nama putih).
     * Kanan: Row [H2 Nama Lengkap + Badge Role "Admin" (#2A573F teks #FFFFFF)],
       Caption Email & WhatsApp (#5A635E), serta Row 2 Tombol Aksi Sejajar:
       (a) Accent Pill Button kecil "Edit Profil" (#FF7761, teks #1F1512) -> [15],
       (b) Rounded Square Icon Button "Ubah Password" (`40x40 px`) -> [16].
   - Divider tipis (`1 px #E4E7E3`).
   - Grouped Menu Card 1 (Operasional Admin — BG #F6F7F5, radius 16 px):
     Laporan Pendapatan -> [25], Permohonan Admin -> [26].
   - Grouped Menu Card 2 (Pengaturan Akun — BG #F6F7F5, radius 16 px):
     Edit Profil -> [15], Ubah Password -> [16], Tentang CAKU.
   - Danger Outlined Pill Button "Logout" (`#A32929`, radius 25 px).
   - Floating Bottom Bar Admin (Tab Profil aktif).
4. Ukuran, Spacing & Radius: Padding horizontal 20 px; antar-kelompok 16–20 px;
   tinggi baris menu min. 52 px dipisah Divider #E4E7E3; bottom scroll padding 100 px.
5. Tipografi & Warna: BG #FFFFFF; Menu Card BG #F6F7F5; Badge Role BG #2A573F
   teks #FFFFFF; Ikon menu #2A573F; Logout border & teks #A32929.
6. Interaksi: Tap Laporan Pendapatan -> [25]; Tap Permohonan Admin -> [26]; Tap
   Edit Profil -> [15]; Tap Ubah Password -> [16]; Tap Tentang CAKU -> Info
   Popup; Tap Logout -> Confirmation Popup -> keluar ke [05] Login.
7. Navigasi: Masuk dari Floating Bottom Bar Admin -> Keluar ke [15], [16],
   [25], [26], atau [05].
8. UI States: Loading / Error + Retry saat memuat profil; Confirmation Popup
   saat Logout.
9. Validasi & Pesan Error: Avatar murni informasi visual read-only (tidak ada
   kontrol upload/ubah foto).

================================================================================
BAB 4 — FINAL USER FLOW
================================================================================

4.1 ALUR ONBOARDING & AUTENTIKASI
[01] Splash Screen -> (Pengguna Baru) -> [02] Onboarding 1 (dengan "Lewatkan")
-> [03] Onboarding 2 (dengan "Lewatkan") -> [04] Onboarding 3 (tanpa "Lewatkan")
-> [05] Login <-> [06] Registrasi.
Dari [05] Login:
- Jika role == Customer -> [07] Home Customer.
- Jika role == Admin    -> [18] Dashboard Admin.

4.2 ALUR CUSTOMER (DISCOVERY -> PENYEWAAN -> PEMBAYARAN -> RIWAYAT)
[07] Home Customer
  |-- Tap Search Bar (autofocus) / Filter / Kategori / Tab Jelajahi -> [08] Jelajahi
  |-- Tap Kartu Barang -> [09] Detail Barang -> Tambah ke Keranjang
  |-- Tap Ikon Keranjang -> [10] Keranjang (atur tanggal sewa & kuantitas)
        |--> Tap "Lanjutkan Checkout" -> [11] Checkout
               |-- Skenario A: Upload bukti transfer -> Buat Pesanan -> [12] Sewa Saya
               |-- Skenario B: Buat Pesanan -> Upload bukti di [13] Detail Transaksi
[12] Sewa Saya -> Tap Kartu Transaksi -> [13] Detail Transaksi Customer
  |-- Jika Pending: Dapat menekan "Hapus Transaksi" (Confirmation Popup).
  |-- Jika Ongoing + melewati tanggal selesai: Menampilkan badge "Terlambat"
      dan estimasi denda berjalan.
  |-- Jika Completed: Menampilkan rincian kondisi & catatan pengembalian.

4.3 ALUR PENGAJUAN ADMIN & PROFIL CUSTOMER
[14] Profil Customer
  |-- Edit Profil -> [15] Edit Profil -> Simpan -> Kembali ke [14]
  |-- Ubah Password -> [16] Ubah Password -> Simpan -> Kembali ke [14]
  |-- Permohonan Admin -> [17] Form Pengajuan Admin -> Kirim -> Status Pending
      (Jika Rejected: tampil alasan penolakan & dapat Ajukan Kembali).

4.4 ALUR OPERASIONAL ADMIN
[18] Dashboard Admin
  |-- Tab Barang -> [19] Manajemen Barang
  |     |-- Kelola Kategori -> [20] Kelola Kategori (Modal Tambah/Edit, Popup Hapus)
  |     |-- Tambah / Edit Barang -> [21] Form Tambah/Edit Barang (Dual-Mode)
  |-- Tab Transaksi -> [22] Manajemen Transaksi -> [23] Detail Transaksi Admin
  |     |-- Pending  -> Tolak (wajib alasan) -> Rejected | Setujui -> Approved
  |     |-- Approved -> Batalkan (wajib alasan) -> Rejected | Mulai Penyewaan -> Ongoing
  |     |-- Ongoing  -> Proses Pengembalian -> [24] Proses Pengembalian
  |                     (pilih kondisi tiap item + catatan -> Selesaikan -> Completed)
  |-- Quick Action / Profil Admin [28]:
        |-- Laporan Pendapatan -> [25] Laporan Pendapatan
        |-- Permohonan Admin -> [26] Daftar Permohonan Admin -> [27] Detail
            Permohonan Admin (Tolak wajib alasan -> Rejected | Setujui -> Approved)

================================================================================
BAB 5 — INTEGRATION DEPENDENCIES (KEBUTUHAN VERIFIKASI AI PROGRAMMER)
================================================================================

Catatan: Seluruh poin di bawah ini merupakan ketergantungan teknis terhadap
backend, API, dan database yang belum dapat diasumsikan oleh UI/UX Designer.
AI Programmer wajib memverifikasi poin berikut terhadap implementasi sistem
yang sebenarnya tanpa mengubah desain antarmuka di luar ketentuan spesifikasi.

5.1 PERHITUNGAN KETERLAMBATAN (OVERDUE) DAN DENDA ([12][13][22][23][24])
- Kebutuhan UI: Menampilkan badge "Terlambat", estimasi denda berjalan saat
  status Ongoing melewati batas tanggal kembali, serta total denda akhir saat
  Proses Pengembalian.
- Data Backend Dibutuhkan: Flag/status `is_overdue`, jumlah hari terlambat,
  estimasi denda berjalan, dan kalkulasi total denda final.
- Bagian Belum Terkonfirmasi: Apakah nominal estimasi denda berjalan dihitung
  dan dikirim langsung oleh API transaksi atau dihitung di sisi klien dari
  `denda_harian` x keterlambatan hari, serta kapan pembaruan status keterlambatan
  dijalankan oleh sistem.

5.2 PEMBATALAN ATAU PENOLAKAN TRANSAKSI YANG TELAH DISETUJUI ([13][23])
- Kebutuhan UI: Membedakan informasi tampilan antara transaksi Pending yang
  ditolak dengan transaksi Approved yang dibatalkan Admin (misal: label turunan
  "Ditolak" vs "Dibatalkan oleh Admin" beserta alasannya) tanpa menambah status
  database baru.
- Data Backend Dibutuhkan: Status transaksi (`Rejected`) beserta metadata atau
  field keterangan/alasan pembatalan maupun penolakan.
- Bagian Belum Terkonfirmasi: Apakah backend menyimpan field alasan/sumber
  pembatalan saat Admin menolak transaksi Pending atau membatalkan transaksi
  Approved.

5.3 WAKTU PENGURANGAN DAN PEMULIHAN STOK ([08][09][10][23][24])
- Kebutuhan UI: Menampilkan sisa stok akurat pada katalog/detail barang,
  validasi keranjang, dan dialog konfirmasi aksi Admin.
- Data Backend Dibutuhkan: Nilai `stok` terbaru pada entitas barang dan respons
  sukses/gagal mutasi transaksi.
- Bagian Belum Terkonfirmasi:
  1. Kapan tepatnya stok dikurangi (saat pesanan dibuat, saat disetujui/Approved,
     atau saat penyewaan dimulai/Ongoing).
  2. Apakah pembatalan transaksi berstatus Approved otomatis memulihkan stok.
  3. Bagaimana aturan pemulihan stok untuk masing-masing kondisi pengembalian
     (Baik, Rusak, Hilang) pada layar [24].

5.4 ALUR UPLOAD BUKTI PEMBAYARAN ([11][13])
- Kebutuhan UI: Menyediakan antarmuka upload bukti transfer pada waktu yang
  tepat sesuai alur pembuatan pesanan.
- Data Backend Dibutuhkan: Endpoint upload gambar (mengembalikan URL gambar)
  dan endpoint pembuatan/pembaruan transaksi.
- Bagian Belum Terkonfirmasi:
  1. Urutan proses aktual: Skenario A (upload bukti terlebih dahulu untuk
     mendapat URL gambar lalu membuat pesanan) atau Skenario B (membuat pesanan
     terlebih dahulu lalu mengunggah bukti menggunakan ID transaksi pada [13]).
  2. Sumber data rekening bank tujuan transfer (API konfigurasi atau konstanta)
     serta batas ukuran dan format file gambar yang diterima endpoint upload.

5.5 KONDISI BARANG SAAT PENGEMBALIAN ([13][24])
- Kebutuhan UI: Input pilihan kondisi (Baik, Rusak, Hilang) dan catatan pada
  layar [24], serta tampilan riwayat kondisi pada layar [13].
- Data Backend Dibutuhkan: Payload pengembalian per item transaksi dan respons
  detail riwayat pengembalian.
- Bagian Belum Terkonfirmasi: Apakah database menyimpan kondisi pengembalian
  pada tingkat item transaksi (1 kondisi untuk keseluruhan kuantitas dalam
  baris item tersebut) atau mendukung pemecahan kondisi per unit fisik (misal:
  dari 3 unit yang disewa, 2 unit Baik dan 1 unit Rusak).

5.6 KETERSEDIAAN BARANG BERDASARKAN PERIODE PENYEWAAN ([08][09][10])
- Kebutuhan UI: Validasi kecukupan stok pada halaman [10] Keranjang setelah
  Customer memilih Tanggal Mulai dan Tanggal Selesai.
- Data Backend Dibutuhkan: Daftar ketersediaan stok atau validasi item pada
  rentang tanggal terpilih, serta nilai durasi hari sewa.
- Bagian Belum Terkonfirmasi:
  1. Apakah sistem memeriksa ketersediaan stok berdasarkan irisan rentang
     tanggal sewa yang dipilih atau hanya menggunakan kolom `stok` statis saat ini.
  2. Rumus durasi sewa yang berlaku (inklusif `(selesai - mulai) + 1` hari atau
     selisih hari `selesai - mulai`).

5.7 DASAR PERHITUNGAN LAPORAN PENDAPATAN ([25])
- Kebutuhan UI: Menampilkan ringkasan 2x2 (Total Transaksi, Pendapatan Sewa,
  Pendapatan Denda, Total Pendapatan), grafik batang, dan rincian transaksi
  sesuai filter rentang tanggal.
- Data Backend Dibutuhkan: Endpoint laporan pendapatan dengan parameter
  `start_date` dan `end_date`.
- Bagian Belum Terkonfirmasi: Definisi tanggal acuan yang digunakan backend
  untuk memfilter transaksi dalam periode laporan (tanggal transaksi dibuat,
  tanggal disetujui, atau tanggal pengembalian selesai) serta status transaksi
  mana saja yang dihitung sebagai pendapatan.

5.8 ALASAN PENOLAKAN PERMOHONAN ADMIN & PEMBARUAN ROLE ([17][27])
- Kebutuhan UI: Input wajib alasan penolakan pada [27] Detail Permohonan Admin
  dan tampilan alasan penolakan pada [17] Form Pengajuan Admin milik Customer,
  serta transisi akses ketika permohonan disetujui.
- Data Backend Dibutuhkan: Field `alasan_penolakan` pada data permohonan/user
  dan pembaruan status/role user.
- Bagian Belum Terkonfirmasi:
  1. Apakah backend menyimpan dan mengembalikan field `alasan_penolakan`.
  2. Apakah Customer yang disetujui menjadi Admin harus melakukan login ulang
     agar token sesi/JWT memuat role `Admin`.

5.9 INTEGRASI LOGIC EDIT PROFIL, UBAH PASSWORD & VALIDASI DATA ([06][15][16][19][20][21])
- Kebutuhan UI: Form Edit Profil ([15]) dan Ubah Password ([16]) telah memiliki
  UI dan validasi klien lengkap, namun saat ini BELUM memiliki logic backend
  yang terhubung.
- Data Backend Dibutuhkan: Endpoint update profil user (nama & nomor WhatsApp),
  endpoint perubahan password (verifikasi password lama & simpan password baru),
  serta aturan validasi master data.
- Bagian Belum Terkonfirmasi:
  1. Ketersediaan dan kontrak API untuk **Edit Profil ([15])** serta pembaruan
     state sesi lokal pengguna setelah profil diubah.
  2. Ketersediaan dan kontrak API/auth provider untuk **Ubah Password ([16])**
     serta panjang minimum password yang berlaku.
  3. Dukungan penyimpanan field `nomor_whatsapp` pada registrasi & edit profil.
  4. Kode/pesan error saat menghapus kategori yang masih terikat barang ([20])
     atau menghapus barang yang memiliki riwayat transaksi ([19]).
  5. Aturan nilai minimum untuk `harga_sewa` dan `denda_harian` ([21]).

================================================================================
BAB 6 — FINAL DESIGN QA CHECKLIST
================================================================================

[x] 1. KONSISTENSI DESIGN SYSTEM TUNGGAL: Seluruh 28 layar (termasuk layar
       tanpa referensi khusus) menggunakan palet warna (#FFFFFF, #F6F7F5,
       #2A573F, #FF7761, #1E2621, #5A635E), tipografi Plus Jakarta Sans,
       komponen Boxed Input, Pill CTA, dan kartu Mist Stone yang seragam.
[x] 2. KESESUAIAN REFERENSI SELEKTIF: Onboarding 1–2 (gradien atas + "Lewatkan"
       + penyamaan teks CTA), Onboarding 3 (dipertahankan utuh), Login/Register
       (tanpa OTP/Forgot Password), Home (Logo, Cart & Profile di header,
       kategori di Floating Bottom Bar), Detail Barang (framed rounded 4:3 +
       atribut nyata), My Cart (tanpa titik tiga, wishlist, promo, shipping),
       dan Profile (layout horizontal 2 kolom bersih) telah terintegrasi penuh.
[x] 3. NAVIGASI FLOATING BOTTOM BAR: Diterapkan konsisten pada 4 tab Customer
       dan 4 tab Admin tanpa Sidebar ganda.
[x] 4. KEJUJURAN INTEGRASI LOGIC: Halaman Edit Profil ([15]) dan Ubah Password
       ([16]) ditandai eksplisit pada Bab 3 & Bab 5 agar AI Programmer
       menyambungkan logic API nyata dan tidak membiarkannya sebagai form statis.
[x] 5. AKSESIBILITAS & KONTRAS: Seluruh pasangan warna teks (>= 4.5:1) dan
       batas kontrol non-teks (>= 3.0:1) telah diverifikasi menggunakan
       luminansi relatif WCAG 2.2 AA, disertai ikon pendamping pada status.
[x] 6. RESPONSIVITAS FLUTTER: Acuan 390 x 844 px dilengkapi aturan SafeArea,
       clearance 100 px untuk Floating Bottom Bar, keyboard avoidance, dan
       adaptasi kolom pada layar sempit.

================================================================================
BAB 7 — FINAL CHANGELOG
================================================================================

1. PENETAPAN PALET WARNA & REUSABLE DESIGN SYSTEM:
   - Memperbarui palet menjadi Pure White (#FFFFFF), Mist Stone (#F6F7F5),
     Forest Pine (#2A573F), dan Coral Ember (#FF7761), serta menyatukan seluruh
     komponen (Circular Back Button, Boxed Input, Pill Button radius 25 px,
     Mist Stone Card, dan Feedback Popup) ke seluruh 28 layar.

2. ADAPTASI SELEKTIF REFERENSI PER HALAMAN:
   - Floating Bottom Bar: Menggunakan kapsul mengambang 4 tab (Home, Jelajahi/
     Kategori, Sewa Saya, Profil untuk Customer; Dashboard, Barang, Transaksi,
     Profil untuk Admin) dan menolak Sidebar ganda.
   - Onboarding ([02]–[04]): Foto full-bleed dengan gradien putih halus dan
     tombol "Lewatkan" pada [02] & [03]; menyamakan teks tombol [02] dengan [03]
     (mengganti "Get Started"); mempertahankan [04] Onboarding 3 secara utuh.
   - Login & Register ([05]–[06]): Menggunakan Boxed Input Mist Stone & feedback
     popup sukses registrasi, serta menghapus total fitur Forgot Password/OTP.
   - Home ([07]): Logo CAKU di kiri, Cart & Profile di kanan (tanpa ikon
     kategori di header), Search Bar + Filter, Hero Banner 2 sisi, Kategori
     Populer, dan Grid Produk 2 kolom tanpa ikon love.
   - Detail Barang ([09]): Menggunakan referensi terbaru (framed rounded 4:3
     image, header 2 kolom Nama & Harga, kotak atribut Kategori & Stok, serta
     Sticky White Action Bar).
   - My Cart ([10]): Menghapus titik tiga, Add to Wishlist, Promo Code, dan
     Shipping; mempertahankan Rental Period Card, kuantitas/hapus, dan total.
   - Profil ([14] & [28]): Menggunakan tata letak horizontal 2 kolom bersih
     tanpa fitur sosial/follower/bookmark.

3. PENYELARASAN HALAMAN TANPA REFERENSI KHUSUS & AUDIT LOGIC:
   - Menerapkan design system yang sama pada Splash ([01]), Jelajahi ([08]),
     Checkout ([11]), Sewa Saya ([12]), Detail Transaksi ([13]), Edit Profil
     ([15]), Ubah Password ([16]), Form Pengajuan Admin ([17]), dan seluruh
     layar Admin ([18]–[27]), serta menambahkan catatan eksplisit kebutuhan
     implementasi logic backend untuk Edit Profil ([15]) dan Ubah Password ([16]).

================================================================================
                    END OF FINAL DESIGN SPECIFICATION
================================================================================