# Pengkodean dan Pemrograman

**Naila Qanitah Syahad** (12030124130094)
Dosen Pengampu: Dr. Totok Dewayanto, S.E., M.Si., Akt.

---

# Voucher Kas Keluar: Form Entri Jurnal Dinamis

Form web satu halaman (`Voucher Kas Keluar.html`) untuk mencatat voucher kas keluar dengan baris jurnal yang dinamis dan pengecekan keseimbangan debit-kredit secara langsung (*live balancing check*).

## Fitur

- **Metadata voucher**: nomor voucher, tanggal, dan keterangan / dibayar kepada.
- **Baris jurnal dinamis**: baris dapat ditambah atau dihapus (minimal tersisa 1 baris).
- **Pilihan akun**: daftar akun contoh dalam dropdown.
- **Total otomatis**: total debit, total kredit, dan selisih dihitung setiap kali nilai berubah.
- **Indikator keseimbangan**: lencana berubah dari *Tidak Seimbang* (merah) menjadi *Seimbang (Balanced)* (hijau).
- **Tombol simpan terkunci**: tombol *Simpan Voucher* hanya aktif ketika total debit sama dengan total kredit.
- **Modal pesan kustom**: pengganti `alert()` untuk notifikasi sukses dan peringatan.

## Daftar Akun Contoh

| Kode | Nama Akun |
|---|---|
| 1-1110 | Kas Besar / Kecil |
| 1-1120 | Bank BCA |
| 5-1110 | Biaya Gaji |
| 5-1210 | Biaya ATK & Perlengkapan Kantor |
| 5-1310 | Biaya Listrik & Air |
| 5-1410 | Biaya Konsumsi Rapat |
| 2-1110 | Hutang Usaha |

Saat halaman dibuka, form terisi contoh transaksi: **Debit** 5-1210 Biaya ATK & Perlengkapan Kantor Rp150.000 dan **Kredit** 1-1110 Kas Besar / Kecil Rp150.000.

## Cara Menjalankan

1. Simpan file `Voucher Kas Keluar.html`.
2. Buka file tersebut di browser (klik dua kali).
3. Perlu koneksi internet karena Tailwind CSS dan font Inter dimuat dari CDN.

## Fungsi JavaScript Utama

| Fungsi | Kegunaan |
|---|---|
| `formatIDR(amount)` | Memformat angka menjadi mata uang Rupiah. |
| `addRow(defaultAccount, defaultDebit, defaultKredit)` | Menambah baris jurnal baru ke tabel. |
| `removeRow(btn)` | Menghapus baris dan menghitung ulang total. |
| `handleAmountInput(input, type)` | Memicu perhitungan ulang saat nominal diubah. |
| `calculateTotals()` | Menghitung total debit, total kredit, selisih, dan memperbarui status keseimbangan serta tombol simpan. |
| `handleSubmit(event)` | Menangani pengiriman form dan menampilkan pesan sukses. |
| `showModal(...)` / `closeModal()` | Menampilkan dan menutup kotak pesan kustom. |

---

# Analisis Kesesuaian Standar Akuntansi dan Pengendalian Internal

## 1. Kesesuaian Komponen Kas dan Setara Kas

**Status: Sesuai**

Standar akuntansi mendefinisikan kas sebagai saldo kas tunai (*cash on hand*) dan rekening giro (*demand deposits*), sedangkan setara kas adalah investasi jangka pendek yang sangat likuid (berjangka waktu 3 bulan atau kurang sejak perolehan) dan bebas dari risiko perubahan nilai yang signifikan. Pemilihan akun Kas Besar/Kecil maupun Rekening Bank pada form voucher kas keluar memenuhi kriteria komponen kas dan setara kas yang digunakan untuk memenuhi komitmen operasional jangka pendek.

## 2. Pengakuan Arus Kas Keluar Aktivitas Operasi

**Status: Sesuai**

Sesuai ketentuan PSAK 2 / PSAK 207, pengeluaran kas untuk pembayaran kepada pemasok, gaji karyawan, serta beban operasional harian diklasifikasikan sebagai pengeluaran kas dari aktivitas operasi. Transaksi melalui voucher kas keluar mencerminkan penurunan manfaat ekonomik masa depan berupa deplesi kas/setara kas yang diakui sebagai beban atau pelunasan liabilitas.

## 3. Validasi Keseimbangan Pencatatan (Double-Entry System)

**Status: Sesuai**

Pengecekan keseimbangan nominal transaksi (`totalDebit === totalKredit`) sebelum form diposting mendukung keandalan pencatatan akuntansi dan keterandalan penyusunan laporan keuangan.

## 4. Catatan dan Rekomendasi Pengendalian Internal (Asersi Audit)

1. **Validasi posisi normal kas keluar:** secara logika akuntansi, transaksi pengeluaran kas wajib menempatkan akun Kas/Bank di posisi **Kredit** (berkurang) dan akun Beban/Utang/Aset di posisi **Debit**. Sistem perlu memvalidasi posisi akun, bukan hanya keseimbangan matematika nominal.
2. **Penanganan kas yang dibatasi (*restricted cash*):** standar akuntansi mengatur bahwa saldo kas atau bank yang penggunaannya dibatasi oleh aturan hukum atau kontrak tidak boleh disajikan atau dikelola sebagai kas bebas tanpa pengungkapan khusus.
3. **Verifikasi bukti pendukung (asersi audit):** untuk memenuhi asersi eksistensi dan kelengkapan, pengeluaran kas melalui voucher harus diverifikasi dengan dokumen pendukung yang sah (seperti kuitansi, nota, atau bukti transfer) serta otorisasi pihak berwenang.

## Ringkasan

| No. | Aspek | Status |
|---|---|---|
| 1 | Kesesuaian komponen kas dan setara kas | Sesuai |
| 2 | Pengakuan arus kas keluar aktivitas operasi | Sesuai |
| 3 | Validasi keseimbangan pencatatan (double-entry) | Sesuai |
| 4 | Pengendalian internal (posisi normal, restricted cash, bukti pendukung) | Catatan dan rekomendasi |
