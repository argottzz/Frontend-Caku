# Pemetaan API CAKU (Frontend → Backend)

Sumber kebenaran: source code backend lokal di `..\Backend Caku\src`, diverifikasi
dengan request nyata ke backend lokal `http://localhost:8000/api` yang terhubung
ke PostgreSQL Aiven.

- Prefix seluruh endpoint: `/api`
- Envelope sukses: `{ "success": true, "message": "...", "data": ..., "pagination"?: ..., "token"?: "..." }`
- Envelope gagal: `{ "success": false, "message": "...", "error"?: [{ path, message }] }`
- Autentikasi: `Authorization: Bearer <JWT>`, masa berlaku 1 hari (`JWT_EXPIRES_IN=1d`).
  Middleware memuat ulang user dari database, sehingga role selalu mengikuti database.
- Uang dikirim/diterima sebagai string desimal, contoh `"75000.00"`.
- Tanggal `YYYY-MM-DD`. Durasi sewa inklusif (`tanggal_selesai - tanggal_mulai + 1`).

## Daftar endpoint aktual

| Method | Path | Auth | Role | Request | Response `data` |
|---|---|---|---|---|---|
| GET | `/api/health` | – | – | – | `{ status: "ok" }` |
| POST | `/api/auth/register` | – | – | JSON `{nama, email, password}` | user + `token` |
| POST | `/api/auth/login` | – | – | JSON `{email, password}` | user + `token` |
| GET | `/api/auth/me` | Bearer | customer/admin | – | user |
| GET | `/api/categories` | Bearer | customer/admin | – | `[{id_kategori, nama}]` |
| GET | `/api/items` | Bearer | customer/admin | query `search`, `id_kategori`, `page`, `limit` | item[] + `pagination` |
| GET | `/api/items/:id` | Bearer | customer/admin | – | item |
| POST | `/api/items` | Bearer | admin | multipart: `id_kategori`, `nama_item`, `deskripsi?`, `stok`, `harga_sewa_harian`, `denda_harian`, file `image?` | item |
| PUT | `/api/items/:id` | Bearer | admin | multipart sama; `image` opsional | item |
| DELETE | `/api/items/:id` | Bearer | admin | – | `{ id_items }` |
| GET | `/api/rentals` | Bearer | customer/admin | query `status`, `page`, `limit` | rental[] + `pagination` |
| GET | `/api/rentals/:id` | Bearer | customer/admin | – | rental + `items[]` |
| POST | `/api/rentals` | Bearer | customer | multipart: `tanggal_mulai`, `tanggal_selesai`, `items` (JSON string), file `bukti_transfer` (wajib) | rental + `items[]` |
| DELETE | `/api/rentals/:id` | Bearer | customer | – | `{ id_rental }` (hanya pending milik sendiri) |
| PATCH | `/api/rentals/:id/status` | Bearer | admin | JSON `{status: approved\|ongoing\|rejected}` | rental |
| POST | `/api/rentals/:id/return` | Bearer | admin | JSON `{tanggal_kembali_aktual, kondisi_pengembalian: Baik\|Rusak\|Hilang, catatan_pengembalian?}` | rental + `perlu_penyesuaian_stok` |
| GET | `/api/reports/summary` | Bearer | admin | query `start_date`, `end_date`, `status`, `page`, `limit` | `{ringkasan, rentals}` + `pagination` |
| POST | `/api/admin-applications` | Bearer | customer | JSON pengajuan admin | aplikasi |
| GET | `/api/admin-applications/me` | Bearer | customer/admin | – | aplikasi milik sendiri |
| GET | `/api/admin-applications` | Bearer | admin | – | aplikasi[] |
| GET | `/api/admin-applications/:id` | Bearer | admin | – | aplikasi |
| PATCH | `/api/admin-applications/:id/approve` | Bearer | admin | – | aplikasi |
| PATCH | `/api/admin-applications/:id/reject` | Bearer | admin | – | aplikasi |

Catatan penting:

- `GET /categories`, `GET /items`, `GET /rentals` **wajib token**. Tanpa token
  backend membalas `401`, bukan data publik.
- Customer hanya melihat rental miliknya; admin melihat semua.
- `GET /reports/summary` untuk customer dibalas `403` (terverifikasi).
- Upload: `multer` memory storage, maksimal 5 MB, satu file; MIME + ekstensi +
  magic bytes diperiksa. Field item `image`, field rental `bukti_transfer`.
- Penyimpanan gambar: Cloudinary, `secure_url` absolut dikembalikan pada
  `image_url` / `bukti_transfer_url`; `image` / `bukti_transfer` menyimpan URL yang sama.
- Hapus item yang sudah dipakai rental → `409`. Update/hapus gambar akan menghapus
  aset Cloudinary lama.

## Pemetaan layar → endpoint

### Customer

| Layar | Endpoint | Catatan |
|---|---|---|
| Splash / pemulihan sesi | `GET /auth/me` | Token dari secure storage; `401` → logout. |
| Login | `POST /auth/login` | Rate limit 20 percobaan / 15 menit. |
| Register | `POST /auth/register` | Role otomatis `customer`. |
| Katalog | `GET /categories` + `GET /items` | Search → `search`, filter → `id_kategori`, halaman → `page`/`limit`. |
| Detail barang | `GET /items/:id` | Data dari server; fallback data list. |
| Keranjang | – | Client-side murni; stok divalidasi dari data item dan server saat checkout. |
| Checkout | `POST /rentals` (multipart) | `items` dikirim sebagai string JSON. Bukti transfer wajib. |
| Riwayat sewa | `GET /rentals?page&limit&status` | Hanya rental milik sendiri. |
| Detail sewa | `GET /rentals/:id` | Termasuk `items[]`, `total_bayar`, `total_denda`. |
| Batalkan pengajuan | `DELETE /rentals/:id` | Hanya status `pending`. |
| Profil | `GET /auth/me` | Hanya baca; tidak ada endpoint ubah profil. |
| Ajukan jadi admin | `POST /admin-applications` | Form permohonan dari Profil. |
| Status permohonan | `GET /admin-applications/me` | Ditampilkan di Profil. |

### Admin

| Layar | Endpoint | Catatan |
|---|---|---|
| Dashboard | `GET /reports/summary` | Ringkasan status + pendapatan. |
| Laporan | `GET /reports/summary?start_date&end_date&status` | Filter tanggal berdasarkan `tanggal_mulai`. |
| Daftar barang | `GET /items?search&id_kategori&page&limit` | Sama seperti katalog. |
| Tambah barang | `POST /items` (multipart) | `image` opsional, JPG/JPEG/PNG/WEBP ≤ 5 MB. |
| Ubah barang | `PUT /items/:id` (multipart) | Tanpa file → gambar lama dipertahankan (`COALESCE`). |
| Hapus barang | `DELETE /items/:id` | `409` bila sudah dipakai rental. |
| Proses rental | `GET /rentals` + `PATCH /rentals/:id/status` | Urutan: pending→approved→ongoing; pending→rejected. |
| Pengembalian | `POST /rentals/:id/return` | Hanya status `ongoing`; stok dikembalikan otomatis. |
| Permohonan admin | `GET /admin-applications` | Filter status di klien setelah data dimuat. |
| Detail permohonan | `GET /admin-applications/:id` | Data pemohon + status. |
| Setujui/tolak | `PATCH /admin-applications/:id/approve\|reject` | Tanpa alasan; kontrak hanya menerima aksi. |
| Profil | `GET /auth/me` | Hanya baca. |

## Gap yang terdokumentasi (bukan bug frontend)

1. **Keranjang** – tidak ada endpoint cart. Keranjang disimpan di aplikasi dan
   dikirim sebagai `items[]` saat checkout.
2. **CRUD kategori** – backend hanya menyediakan `GET /categories`. Tidak ada
   create/update/delete kategori, jadi kategori hanya tampil sebagai filter
   (Beranda, Katalog, daftar barang admin) tanpa layar pengelolaan.
3. **Ubah profil & ubah password** – tidak ada endpoint update user/profil
   maupun ganti password. Layar Profil hanya menampilkan data `GET /auth/me`;
   entri Edit Profil dan Ubah Password dihapus agar tidak ada aksi tanpa
   dukungan backend (`desain.md` §8.11–8.12).
4. **Alasan penolakan** – `PATCH /rentals/:id/status` hanya menerima `status`.
   Tidak ada field alasan; dialog penolakan tidak meminta alasan.
5. **Nomor rekening tujuan transfer** – tidak ada di kontrak API. Instruksi
   pembayaran tidak menampilkan nomor rekening karangan.
6. **Admin applications** – didukung penuh oleh backend dan sudah dipakai:
   customer mengajukan lewat Profil (`POST /admin-applications`), admin
   meninjau di layar Permohonan Admin (`GET /admin-applications`,
   `PATCH .../approve|reject`).
7. **Daftar pengguna** – tidak ada endpoint users; admin tidak dapat mengelola akun.

## Status verifikasi

- Backend lokal + Aiven: `GET /api/health` → `200 {"status":"ok"}`.
- Login admin & customer → `200` + `token` + `data.role`.
- Data Aiven melalui API: 5 kategori, 0 item, 0 rental; ringkasan laporan nol.
- Customer → `GET /reports/summary` → `403`.
- **Railway `https://backend-caku-production.up.railway.app` aktif dan sehat**:
  `GET /api/health` → `200 {"success":true,"message":"Server berjalan"}`.
  Path di luar `/api` (mis. `/` atau `/health`) memang `404` karena Express
  hanya memasang route di bawah `/api` — itu perilaku normal, bukan deployment
  mati. `GET /api/categories` tanpa token → `401`, sesuai harapan.
