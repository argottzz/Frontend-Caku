# CAKU --- UI/UX Design Guidelines

**Dokumen arahan desain aplikasi Flutter Caku**\
**Arah visual:** Forest-inspired, modern, minimal, natural, dan
fungsional\
**Tagline:** *Explore More, Worry Less.*

------------------------------------------------------------------------

## 1. Tujuan Desain

Tujuan utama desain Caku adalah membangun aplikasi penyewaan
perlengkapan camping yang memiliki nuansa hutan dan alam terbuka, tetapi
tetap terasa modern, profesional, mudah digunakan, dan tidak berlebihan
secara visual.

Desain harus membantu customer menemukan perlengkapan, memahami
informasi penyewaan, melakukan checkout, memantau transaksi, serta
mengetahui kapan dan di mana barang dapat diambil. Di sisi admin, desain
harus mendukung pengelolaan barang, transaksi, pengembalian, dan laporan
operasional secara efisien.

Nuansa hutan harus terasa melalui perpaduan warna, tipografi, fotografi,
ikonografi, tekstur yang sangat halus, dan komposisi layout. Jangan
menerjemahkan tema hutan dengan menambahkan terlalu banyak ilustrasi
pohon, daun, gunung, atau ornamen dekoratif. Hasil akhir harus terlihat
seperti produk digital yang matang, bukan aplikasi bertema alam yang
penuh dekorasi.

### Prinsip utama

1.  **Forest-inspired, not forest-themed overload.** Gunakan karakter
    alam melalui warna dan visual yang terukur, bukan ornamen
    berlebihan.
2.  **Clarity before decoration.** Informasi barang, harga, stok,
    tanggal sewa, status, dan tindakan utama harus mudah ditemukan.
3.  **Consistent experience.** Semua halaman Customer dan Admin harus
    menggunakan satu sistem desain yang sama.
4.  **Mobile-first.** Prioritaskan kenyamanan penggunaan pada layar
    ponsel dan berbagai ukuran perangkat.
5.  **Functional UI.** Setiap tombol, field, filter, kartu, dan navigasi
    harus memiliki fungsi yang jelas.
6.  **Honest interface.** Jangan menampilkan informasi, tombol, status,
    atau data yang belum didukung backend.
7.  **Simple and understandable implementation.** Implementasikan dengan
    struktur Flutter yang mudah dipahami dan tidak berlebihan.

------------------------------------------------------------------------

## 2. Identitas Visual dan Warna

Gunakan tiga warna utama berikut sebagai fondasi identitas visual Caku.
Nilai warna harus digunakan secara konsisten melalui design tokens,
bukan ditulis ulang secara acak pada setiap widget.

  -----------------------------------------------------------------------
  Token                   Hex                     Peran
  ----------------------- ----------------------- -----------------------
  Primary                 `#17322E`               Warna identitas utama,
                                                  app bar, judul penting,
                                                  navigasi aktif, dan CTA
                                                  utama

  Accent                  `#27524B`               Aksen sekunder, elemen
                                                  interaktif, ikon aktif,
                                                  chip terpilih, dan
                                                  variasi permukaan

  Background              `#DCEBE6`               Latar utama bernuansa
                                                  mint-sage yang lembut
  -----------------------------------------------------------------------

### Warna pendukung

Warna pendukung boleh digunakan untuk menjaga keterbacaan dan membedakan
permukaan, tetapi tidak boleh menggeser identitas tiga warna utama.

  -----------------------------------------------------------------------
  Token                   Hex                     Penggunaan
  ----------------------- ----------------------- -----------------------
  Surface                 `#F7FAF8`               Kartu, modal, bottom
                                                  sheet, dan panel konten

  Surface Soft            `#EAF3EF`               Field, area sekunder,
                                                  dan permukaan lembut

  Text Primary            `#172622`               Teks utama

  Text Secondary          `#657772`               Deskripsi, metadata,
                                                  dan label sekunder

  Border                  `#C5D7D0`               Garis pembatas dan
                                                  outline

  Success                 `#28734E`               Berhasil,
                                                  terverifikasi, dan
                                                  selesai

  Warning                 `#A66A24`               Peringatan dan kondisi
                                                  yang perlu diperhatikan

  Error                   `#B54747`               Kesalahan, penolakan,
                                                  dan tindakan berisiko

  Info                    `#356B83`               Informasi tambahan
  -----------------------------------------------------------------------

### Aturan penggunaan warna

-   Primary `#17322E` harus menjadi warna identitas paling kuat.
-   Accent `#27524B` digunakan untuk variasi dan penekanan, bukan
    sebagai pengganti Primary.
-   Background `#DCEBE6` digunakan sebagai latar utama, tetapi area
    dengan teks panjang atau konten padat sebaiknya menggunakan Surface
    agar lebih nyaman dibaca.
-   CTA utama menggunakan Primary dengan teks kontras yang memadai.
-   Jangan menggunakan warna hijau berbeda-beda tanpa alasan sistematis.
-   Jangan membuat seluruh layar menjadi satu bidang hijau gelap.
-   Jangan menggunakan gradien secara berlebihan. Jika digunakan,
    gradien harus sangat halus dan tetap berada dalam keluarga warna
    identitas.
-   Pastikan rasio kontras teks dan latar cukup untuk dibaca.
-   Status transaksi harus dibedakan dengan label dan teks, bukan warna
    saja.

------------------------------------------------------------------------

## 3. Arah Visual: Forest-Inspired

Nuansa hutan Caku harus terasa tenang, segar, membumi, dan dekat dengan
kegiatan outdoor.

### Fotografi

-   Gunakan foto perlengkapan camping yang realistis dan berkualitas.
-   Prioritaskan foto produk yang jelas, tidak terlalu gelap, dan
    memiliki pencahayaan natural.
-   Gunakan foto suasana alam seperti hutan, area camping, pepohonan,
    atau tenda hanya pada area yang memang membutuhkan visual pendukung.
-   Foto produk harus menjadi fokus pada kartu dan halaman detail
    barang.
-   Gunakan rasio gambar yang konsisten pada komponen sejenis.
-   Jangan menggunakan gambar AI yang tampak tidak realistis sebagai
    foto produk.
-   Jangan menggunakan foto dekoratif yang mengganggu keterbacaan
    informasi.

### Bentuk dan ornamen

-   Gunakan sudut komponen yang konsisten dan tidak terlalu membulat.
-   Gunakan garis pembatas tipis dan bayangan lembut jika memang
    membantu pemisahan.
-   Hindari glassmorphism, efek neon, glow, dan efek 3D yang tidak
    relevan.
-   Hindari ornamen daun, ranting, pohon, kompas, atau gunung yang
    ditempelkan pada hampir setiap komponen.
-   Ilustrasi kosong (*empty state*) boleh menggunakan tema outdoor
    secara sederhana.

### Kesan yang ingin dicapai

-   Natural
-   Calm
-   Trustworthy
-   Modern
-   Practical
-   Outdoor-oriented
-   Professional

------------------------------------------------------------------------

## 4. Tipografi

Gunakan **Plus Jakarta Sans** sebagai font utama di seluruh aplikasi.

### Hierarki tipografi

  Gaya                      Penggunaan
  ------------------------- -------------------------------------------
  Display / Heading Large   Judul halaman utama atau headline penting
  Heading Medium            Judul section dan judul halaman
  Heading Small             Judul kartu dan subbagian
  Body Large                Informasi utama dan deskripsi penting
  Body Medium               Isi konten umum
  Body Small                Metadata dan keterangan pendukung
  Label                     Tombol, chip, tab, dan label field

Aturan:

-   Gunakan maksimal beberapa tingkat ukuran yang konsisten.
-   Bedakan hierarki melalui ukuran, weight, dan warna, bukan dengan
    terlalu banyak variasi font.
-   Hindari teks terlalu kecil, terutama untuk harga, tanggal, status,
    dan instruksi.
-   Gunakan line-height yang nyaman.
-   Jangan menggunakan seluruh teks dengan font weight bold.
-   Pastikan angka harga dan tanggal mudah dipindai.

------------------------------------------------------------------------

## 5. Spacing, Radius, dan Elevation

Buat skala ukuran yang konsisten. Hindari memberi padding dan jarak
secara acak pada setiap halaman.

### Spacing scale

Gunakan kelipatan 4 sebagai dasar:

`4, 8, 12, 16, 20, 24, 32, 40`

Pedoman: - 4--8 px untuk jarak elemen kecil. - 12--16 px untuk jarak
dalam komponen. - 20--24 px untuk padding halaman dan jarak
antarkomponen. - 32--40 px untuk pemisah section yang lebih besar.

### Radius

Gunakan radius secara konsisten:

-   Small: 8 px --- label, chip kecil, dan elemen ringkas.
-   Medium: 12 px --- input dan tombol.
-   Large: 16 px --- kartu dan panel.
-   Extra Large: 20--24 px --- modal atau area khusus yang membutuhkan
    penekanan.

Jangan membuat setiap elemen berbentuk kapsul. Gunakan bentuk pill hanya
untuk chip atau kontrol yang memang sesuai.

### Elevation

-   Utamakan pemisahan melalui warna Surface dan Border.
-   Gunakan shadow tipis hanya untuk elemen yang mengambang atau perlu
    dibedakan.
-   Hindari bayangan gelap dan bertumpuk.
-   Jangan menggunakan shadow sebagai dekorasi pada semua kartu.

------------------------------------------------------------------------

## 6. Komponen dan Design System

Bangun komponen reusable untuk menjaga konsistensi. Komponen harus
dibuat ketika pola UI benar-benar berulang, bukan memecah setiap elemen
kecil menjadi abstraksi yang sulit dipahami.

Komponen inti yang perlu distandardisasi:

-   Primary button
-   Secondary button
-   Text button
-   Text field
-   Search field
-   Dropdown / selector
-   Date selector
-   Category chip
-   Status badge
-   Product card
-   Transaction card
-   Section header
-   Empty state
-   Loading state
-   Error state
-   Confirmation dialog
-   Bottom sheet
-   Snackbar / feedback message
-   Admin data row atau data card
-   Image placeholder

Setiap komponen harus memiliki variasi state yang relevan: - Default -
Pressed - Focused - Disabled - Loading - Error, jika berlaku

Jangan membuat komponen yang terlihat sama tetapi memiliki warna,
radius, tinggi, atau padding berbeda tanpa alasan UX.

------------------------------------------------------------------------

## 7. Navigasi dan Struktur Aplikasi

Caku memiliki dua role: **Customer** dan **Admin**. Keduanya harus
memiliki pengalaman visual yang konsisten, tetapi struktur navigasi dan
prioritas informasinya disesuaikan dengan tugas masing-masing.

### Customer

Navigasi harus memudahkan customer melakukan tiga hal utama: 1.
Menemukan perlengkapan camping. 2. Mengelola proses penyewaan. 3.
Memantau transaksi dan profil.

Halaman Customer yang menjadi bagian dari cakupan desain:

-   Splash
-   Onboarding
-   Login
-   Register
-   Home
-   Jelajahi / Katalog
-   Detail Barang
-   Keranjang
-   Checkout
-   Sewa Saya
-   Detail Transaksi
-   Profil
-   Edit Profil
-   Ubah Password
-   Pengajuan Admin

Jika fitur tertentu belum didukung backend, jangan membuatnya
seolah-olah berfungsi. Tandai sebagai belum tersedia, nonaktifkan dengan
penjelasan yang jelas, atau tunda implementasinya sesuai arahan produk.

### Admin

Navigasi Admin harus mengutamakan pekerjaan operasional dan mempercepat
akses ke transaksi yang perlu ditangani.

Halaman Admin yang menjadi bagian dari cakupan desain:

-   Dashboard
-   Manajemen Barang
-   Tambah Barang
-   Edit Barang
-   Manajemen Kategori
-   Manajemen Transaksi
-   Detail Transaksi
-   Proses Pengembalian
-   Laporan
-   Pengajuan Admin
-   Profil Admin

Jangan menyalin layout Customer secara mentah ke Admin. Gunakan design
system yang sama, tetapi susun informasi sesuai kebutuhan kerja Admin.

------------------------------------------------------------------------

## 8. Arahan Desain per Halaman Customer

### 8.1 Splash

Tujuan: - Memperkenalkan identitas Caku. - Memberikan kesan outdoor yang
sederhana dan profesional. - Menampilkan logo dan tagline secara jelas.

Arahan: - Gunakan Primary sebagai warna dominan atau komposisi Primary
dan Background. - Logo menjadi fokus. - Tagline: "Explore More, Worry
Less." - Hindari animasi panjang dan dekorasi berlebihan. - Pastikan
transisi menuju halaman berikutnya tidak terasa lambat.

### 8.2 Onboarding

Tujuan: - Menjelaskan manfaat utama Caku secara singkat.

Arahan: - Gunakan ilustrasi atau foto outdoor yang relevan. - Maksimal
satu pesan utama pada setiap slide. - Sediakan indikator halaman dan
tombol navigasi yang jelas. - Jangan mengulang penjelasan yang sama pada
beberapa slide.

### 8.3 Login dan Register

Tujuan: - Memungkinkan pengguna masuk atau membuat akun dengan proses
yang mudah dipahami.

Arahan: - Layout sederhana dengan fokus pada form. - Label field harus
jelas dan tidak hanya mengandalkan placeholder. - Tampilkan validasi
dekat dengan field terkait. - Sediakan show/hide password. - Berikan
feedback loading dan error. - Jangan menambahkan field yang tidak
dibutuhkan backend.

### 8.4 Home

Tujuan: - Menjadi titik awal eksplorasi perlengkapan camping.

Susunan konten yang disarankan: 1. Sapaan atau identitas pengguna. 2.
Search bar sebagai pintu masuk ke katalog. 3. Kategori perlengkapan. 4.
Rekomendasi atau barang pilihan. 5. Konten pendukung yang benar-benar
bermanfaat. 6. Navigasi utama.

Arahan: - Home tidak boleh terasa seperti halaman katalog penuh. -
Prioritaskan discovery dan rekomendasi. - Gunakan foto produk yang
konsisten. - Hindari terlalu banyak banner promosi. - Jangan menampilkan
section kosong hanya untuk memenuhi layout.

### 8.5 Search Bar Home dan Halaman Jelajahi

Keputusan UX: - Search bar pada Home berfungsi sebagai entry point
menuju halaman Jelajahi. - Saat diketuk, aplikasi membuka halaman
Jelajahi dan langsung memfokuskan search field. - Keyboard dapat
langsung terbuka agar customer bisa segera mengetik. - Jangan
mengharuskan customer mengetuk search field untuk kedua kalinya. - Jika
navigasi dilakukan dengan kata kunci, pertahankan kata kunci tersebut.

Halaman Jelajahi menjadi pusat: - Pencarian barang. - Filter kategori. -
Sorting. - Hasil katalog. - Empty state ketika tidak ada hasil.

Arahan: - Search field harus mudah ditemukan. - Filter dan sorting tidak
boleh memenuhi area atas secara berlebihan. - Filter aktif harus
terlihat dan dapat dihapus. - Hasil pencarian harus memiliki loading,
error, dan empty state. - Pertahankan posisi atau kata kunci ketika
customer kembali dari detail barang jika memungkinkan.

### 8.6 Detail Barang

Tujuan: - Membantu customer memahami barang sebelum menyewa.

Informasi yang perlu diprioritaskan: - Foto barang. - Nama barang. -
Harga sewa per hari. - Stok yang tersedia. - Deskripsi. - Informasi
relevan lainnya yang memang tersedia.

Arahan: - Foto harus menjadi elemen visual utama. - Harga dan satuan
waktu harus jelas. - Tombol tambah ke keranjang harus mudah ditemukan. -
Tampilkan feedback ketika barang berhasil ditambahkan. - Jangan
menampilkan rating, ulasan, atau spesifikasi yang tidak tersedia dari
sistem.

### 8.7 Keranjang

Tujuan: - Memastikan customer dapat memeriksa barang yang akan disewa
sebelum checkout.

Arahan: - Tampilkan setiap barang dengan nama, foto, jumlah, dan
harga. - Tampilkan tanggal mulai dan akhir sewa secara jelas. - Periode
sewa berlaku bersama untuk semua barang dalam satu transaksi. -
Perlihatkan ringkasan biaya dengan transparan. - Perubahan jumlah harus
memperbarui ringkasan secara konsisten. - Berikan konfirmasi sebelum
menghapus barang jika tindakan tersebut berisiko menghilangkan pilihan
customer.

### 8.8 Checkout

Tujuan: - Menyelesaikan penyewaan tanpa membuat customer bingung.

Arahan: - Kelompokkan informasi penyewa, periode sewa, daftar barang,
dan ringkasan biaya. - Tampilkan total biaya dengan jelas. - Instruksi
transfer dan upload bukti pembayaran harus mudah ditemukan. - Jangan
menampilkan nomor rekening atau informasi pembayaran palsu. - Jangan
memaksa customer mengisi data yang tidak digunakan backend. - Berikan
validasi dan feedback upload yang jelas.

### 8.9 Sewa Saya

Tujuan: - Membantu customer memantau seluruh transaksi penyewaan.

Arahan: - Kelompokkan transaksi berdasarkan status atau gunakan filter
status yang mudah dipahami. - Kartu transaksi harus menampilkan
identitas transaksi, tanggal, ringkasan barang, total biaya, dan
status. - Status harus disertai keterangan singkat jika diperlukan. -
Akses ke Detail Transaksi harus jelas. - Jangan hanya mengandalkan warna
badge untuk menjelaskan status.

### 8.10 Detail Transaksi

Tujuan: - Menjadi sumber informasi utama mengenai satu transaksi.

Arahan: - Susun informasi dengan urutan yang mudah dipindai: status,
barang, periode, biaya, pembayaran, dan instruksi tindakan. - Tampilkan
timeline atau tahapan transaksi jika membantu pemahaman. - Bedakan
instruksi berdasarkan status transaksi. - Informasi penting tidak boleh
tersembunyi di balik terlalu banyak menu.

**Instruksi khusus untuk status Approved:**

Ketika pembayaran telah diverifikasi dan transaksi disetujui: -
Tampilkan pesan bahwa pembayaran telah diverifikasi. - Jelaskan bahwa
barang diambil langsung di lokasi penyewaan. - Tampilkan alamat lokasi
pengambilan jika alamat resmi tersedia di sistem. - Tampilkan tanggal
mulai sewa agar customer memahami kapan pengambilan dilakukan. - Jangan
memberi kesan bahwa barang dikirim ke alamat customer. - Jangan
menyatakan barang sudah diterima customer.

Contoh pesan:

> Pembayaran Anda telah diverifikasi dan penyewaan telah disetujui.
> Silakan datang ke lokasi penyewaan Caku untuk mengambil barang sesuai
> jadwal sewa.

**Pemisahan status:** - `Pending`: pembayaran menunggu verifikasi. -
`Approved`: pembayaran valid dan penyewaan disetujui; barang menunggu
pengambilan. - `Ongoing`: barang telah diserahkan kepada customer dan
masa sewa berlangsung. - `Rejected`: transaksi ditolak; tampilkan alasan
jika tersedia. - `Completed`: proses penyewaan telah selesai.

Perubahan status menjadi `Ongoing` dilakukan setelah barang benar-benar
diserahkan, bukan otomatis ketika pembayaran disetujui.

### 8.11 Profil

Tujuan: - Menjadi pusat informasi akun dan akses pengaturan.

Arahan: - Tampilkan identitas pengguna dan menu yang relevan. -
Kelompokkan pengaturan akun secara jelas. - Hindari menampilkan
informasi pribadi yang tidak tersedia. - Jangan menampilkan tombol edit
profil atau ubah password seolah-olah berfungsi jika endpoint backend
belum tersedia.

### 8.12 Edit Profil, Ubah Password, dan Pengajuan Admin

Arahan: - Desain boleh disiapkan sebagai spesifikasi, tetapi
implementasi harus mengikuti kemampuan backend yang benar-benar
tersedia. - Jangan membuat simulasi penyimpanan lokal yang memberi kesan
data sudah tersimpan di server. - Jangan menambahkan input alasan
pengajuan Admin jika API tidak menerima data tersebut. - Tampilkan
status fitur secara jujur jika belum dapat digunakan.

------------------------------------------------------------------------

## 9. Arahan Desain per Halaman Admin

### 9.1 Dashboard

Tujuan: - Memberikan ringkasan kondisi operasional dan pekerjaan yang
perlu dilakukan.

Arahan: - Prioritaskan transaksi yang menunggu tindakan. - Tampilkan
ringkasan angka yang benar-benar berasal dari API. - Gunakan hierarki
informasi yang jelas. - Hindari dashboard yang dipenuhi kartu statistik
tanpa prioritas. - Grafik hanya boleh ditampilkan jika backend
menyediakan data historis yang valid. Jangan membuat grafik dari data
dummy.

### 9.2 Manajemen Barang

Tujuan: - Memudahkan Admin melihat dan mengelola inventaris.

Arahan: - Gunakan foto, nama barang, harga, dan stok sebagai informasi
utama. - Sediakan pencarian dan filter jika didukung. - Aksi edit dan
hapus harus mudah ditemukan tetapi tidak mendominasi. - Konfirmasi
tindakan penghapusan. - Tampilkan feedback jika barang tidak dapat
dihapus karena masih digunakan transaksi.

### 9.3 Tambah dan Edit Barang

Arahan: - Kelompokkan field berdasarkan informasi barang, harga, stok,
dan gambar. - Gunakan label yang jelas. - Validasi input sebelum
submit. - Berikan indikator upload gambar. - Jika foto bersifat opsional
di backend, jangan menjadikannya wajib tanpa keputusan produk. -
Pertahankan nilai form ketika terjadi error yang masih dapat diperbaiki.

### 9.4 Manajemen Kategori

Arahan: - Tampilkan kategori dengan struktur yang mudah dipindai. - Aksi
CRUD hanya diaktifkan jika endpoint backend sudah tersedia. - Jika
kategori masih digunakan oleh barang, tampilkan penjelasan ketika
penghapusan ditolak. - Jangan membuat aksi palsu yang hanya mengubah
tampilan.

### 9.5 Manajemen dan Detail Transaksi

Arahan: - Prioritaskan status dan tindakan yang sah menurut aturan
backend. - Tampilkan detail penyewa, barang, periode, biaya, dan bukti
pembayaran. - Pisahkan tindakan verifikasi pembayaran dari proses
penyerahan barang. - Sediakan konfirmasi untuk tindakan penting. -
Jangan tampilkan tombol transisi status yang tidak didukung backend.

### 9.6 Proses Pengembalian

Arahan: - Tampilkan transaksi yang sedang berlangsung. - Perjelas
tanggal sewa dan informasi keterlambatan yang benar-benar tersedia. -
Kondisi pengembalian mengikuti kontrak backend saat ini: satu kondisi
untuk seluruh transaksi, yaitu `Baik`, `Rusak`, atau `Hilang`, serta
satu catatan. - Jangan membuat pilihan kondisi per barang jika API belum
mendukungnya. - Tampilkan ringkasan sebelum Admin mengonfirmasi
pengembalian.

### 9.7 Laporan

Arahan: - Gunakan ringkasan dan breakdown yang benar-benar disediakan
API. - Jangan menampilkan tren historis atau grafik waktu jika data
historis belum tersedia. - Cantumkan periode laporan jika memang
didukung. - Pastikan angka dan label tidak menyesatkan.

### 9.8 Pengajuan Admin dan Profil Admin

Arahan: - Tampilkan informasi yang benar-benar tersedia. - Sediakan
detail dan status yang jelas. - Alasan penolakan dapat ditampilkan atau
diminta jika memang didukung backend. - Jangan membuat field atau
tindakan yang tidak memiliki dukungan API.

------------------------------------------------------------------------

## 10. Status, Feedback, dan Microinteraction

Setiap aksi yang dilakukan pengguna harus menghasilkan feedback yang
dapat dipahami.

### Status transaksi

  -----------------------------------------------------------------------
  Status                              Makna untuk pengguna
  ----------------------------------- -----------------------------------
  Pending                             Menunggu verifikasi pembayaran

  Approved                            Pembayaran terverifikasi, penyewaan
                                      disetujui, barang menunggu diambil

  Ongoing                             Barang telah diserahkan dan masa
                                      sewa berlangsung

  Rejected                            Transaksi ditolak

  Completed                           Penyewaan selesai
  -----------------------------------------------------------------------

Jangan mengubah makna status hanya demi menyesuaikan desain.

### Feedback wajib

-   Loading ketika mengambil data atau mengirim form.
-   Success ketika aksi berhasil.
-   Error ketika aksi gagal.
-   Empty state ketika data belum tersedia.
-   Confirmation dialog untuk tindakan penting.
-   Disabled state ketika aksi tidak dapat dilakukan.
-   Validasi field yang spesifik dan mudah dipahami.

Animasi harus singkat, fungsional, dan tidak menghambat interaksi.
Hindari animasi dekoratif yang membuat aplikasi terasa lambat.

------------------------------------------------------------------------

## 11. Accessibility dan Responsiveness

-   Pastikan ukuran teks nyaman dibaca.
-   Pastikan kontras teks dan latar memadai.
-   Jangan menyampaikan status hanya dengan warna.
-   Beri label yang jelas pada ikon yang tidak umum.
-   Area sentuh tombol dan kontrol harus nyaman digunakan.
-   Pastikan keyboard tidak menutupi field atau tombol penting.
-   Gunakan scroll yang wajar dan hindari nested scrolling yang tidak
    diperlukan.
-   Periksa layout pada layar kecil maupun besar.
-   Tangani teks panjang, nama barang panjang, dan angka harga yang
    besar tanpa overflow.
-   Berikan safe area yang tepat.

------------------------------------------------------------------------

## 12. Aturan Implementasi Flutter

Dokumen ini merupakan arahan desain dan UX, tetapi implementasi harus
tetap mengikuti struktur project dan kontrak API yang ada.

1.  Periksa struktur project dan komponen yang sudah tersedia sebelum
    mengubah kode.
2.  Gunakan satu sumber design tokens untuk warna, tipografi, spacing,
    radius, dan komponen.
3.  Gunakan komponen reusable untuk pola yang benar-benar berulang.
4.  Jangan menambahkan dependency baru jika Flutter sudah menyediakan
    kemampuan yang diperlukan.
5.  Hindari overengineering, abstraksi berlapis, dan pemecahan file yang
    tidak diperlukan.
6.  Gunakan nama variabel dan widget yang jelas serta mudah dipahami.
7.  Pisahkan tampilan dari logika data secukupnya, tanpa membuat
    arsitektur menjadi rumit.
8.  Integrasikan semua state UI dengan data API yang nyata.
9.  Jangan menggunakan dummy data sebagai pengganti endpoint yang belum
    tersedia pada hasil akhir.
10. Jangan mengubah business logic atau kontrak backend hanya untuk
    memudahkan desain tanpa persetujuan.
11. Tangani loading, error, empty, dan success state.
12. Pastikan semua navigasi, tombol, filter, form, dan interaksi
    benar-benar bekerja.
13. Jangan menghapus perubahan lokal atau pekerjaan lain yang tidak
    terkait.
14. Ikuti branch Git yang sedang ditentukan untuk pekerjaan UI/UX dan
    jangan melakukan merge ke branch utama tanpa persetujuan.

------------------------------------------------------------------------

## 13. Hal yang Tidak Boleh Dilakukan

-   Menghasilkan UI generik yang terlihat seperti template dashboard AI.
-   Menggunakan warna hijau secara berlebihan sampai semua komponen
    terlihat sama.
-   Menggunakan terlalu banyak gradient, shadow, glow, glassmorphism,
    atau ornamen.
-   Mengubah layout setiap halaman tanpa mempertahankan design system.
-   Membuat tombol yang tidak memiliki fungsi.
-   Membuat data, alamat, rekening, status, grafik, atau informasi
    produk palsu.
-   Menganggap pembayaran disetujui berarti barang sudah diterima.
-   Menampilkan fitur yang belum didukung backend sebagai fitur aktif.
-   Mengorbankan keterbacaan demi estetika.
-   Mengubah alur bisnis yang telah disepakati tanpa alasan dan
    konfirmasi.

------------------------------------------------------------------------

## 14. Checklist Evaluasi Hasil Desain

Sebelum menyatakan implementasi selesai, periksa seluruh poin berikut:

### Visual

-   [ ] Identitas Forest-Inspired terasa tanpa ornamen berlebihan.
-   [ ] Primary, Accent, dan Background digunakan konsisten.
-   [ ] Tipografi dan hierarki informasi konsisten.
-   [ ] Spacing, radius, border, dan elevation konsisten.
-   [ ] Foto produk jelas dan memiliki rasio yang konsisten.
-   [ ] Tidak ada elemen yang terlihat seperti template generik.

### UX

-   [ ] Alur navigasi mudah dipahami.
-   [ ] Search bar Home langsung membuka Jelajahi dengan field fokus.
-   [ ] Customer dapat memahami harga, stok, dan periode sewa.
-   [ ] Checkout memiliki ringkasan biaya yang jelas.
-   [ ] Customer memahami bahwa pengambilan dilakukan langsung di
    lokasi.
-   [ ] Status Approved tidak disamakan dengan Ongoing.
-   [ ] Setiap tombol dan kontrol memiliki fungsi.
-   [ ] Loading, error, empty, success, dan disabled state tersedia.
-   [ ] Tidak ada overflow pada ukuran layar yang diuji.

### Integrasi dan kualitas

-   [ ] Tampilan menggunakan data API yang benar.
-   [ ] Tidak ada dummy data yang menyamar sebagai data asli.
-   [ ] Tidak ada fitur yang melampaui kemampuan backend.
-   [ ] Tidak ada perubahan business logic yang tidak disepakati.
-   [ ] Seluruh halaman Customer dan Admin mengikuti design system yang
    sama.
-   [ ] Navigasi dan interaksi diuji.
-   [ ] Tidak ada error atau warning baru yang belum ditangani.

------------------------------------------------------------------------

## 15. Instruksi Akhir untuk AI Programmer

Gunakan dokumen ini sebagai **pedoman utama visual dan UX Caku** ketika
merancang atau mengimplementasikan tampilan aplikasi.

Jangan hanya mengganti warna pada UI lama. Evaluasi komposisi, hierarki,
spacing, navigasi, kepadatan informasi, konsistensi komponen, dan alur
interaksi setiap halaman.

Sebelum melakukan implementasi: 1. Audit tampilan dan struktur kode yang
sudah ada. 2. Petakan halaman yang perlu dipertahankan, diperbaiki, atau
dibangun ulang. 3. Cocokkan setiap rancangan dengan kemampuan API dan
aturan bisnis Caku. 4. Terapkan design system secara konsisten ke
seluruh halaman Customer dan Admin.

Lakukan pekerjaan secara menyeluruh dan berurutan tanpa meminta
persetujuan di setiap tahap. Jika menemukan keterbatasan backend, jangan
membuat fungsi palsu. Catat keterbatasan tersebut dan implementasikan UX
yang paling jujur serta aman sesuai kemampuan sistem.

**Hasil akhir yang diharapkan:** Caku harus terasa sebagai aplikasi
penyewaan perlengkapan camping yang modern, matang, bernuansa hutan,
mudah dipahami, konsisten, dan benar-benar nyaman digunakan --- bukan
sekadar aplikasi yang memiliki warna hijau dan ornamen alam.
