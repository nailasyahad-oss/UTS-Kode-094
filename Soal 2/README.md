# Pengkodean dan Pemrograman

**Naila Qanitah Syahad** (12030124130094)
Dosen Pengampu: Dr. Totok Dewayanto, S.E., M.Si., Akt.

---

## 1. Otomatisasi Mutasi melalui Database Trigger

### 1.1. Memahami Masalahnya

Soal memberikan dua tabel:

- **`inventory_items`**: menyimpan data barang, jumlah stok, dan biaya per unit.
- **`inventory_transactions`**: menyimpan transaksi `PURCHASE`, `SALE`, atau `ADJUSTMENT`.

Targetnya adalah setiap kali transaksi baru dimasukkan ke `inventory_transactions`, database otomatis memperbarui `stock_qty` pada `inventory_items`.

Contoh sederhana:

| Jenis transaksi | Stok awal | Kuantitas | Stok akhir |
|---|---:|---:|---:|
| `PURCHASE` | 10 | 5 | 15 |
| `SALE` | 10 | 3 | 7 |
| `SALE` melebihi stok | 2 | 5 | Ditolak |

Dengan trigger, aplikasi tidak perlu mengubah stok secara terpisah setelah memasukkan transaksi. Database yang menjalankan logika tersebut secara otomatis.

### 1.2. Penjelasan Kode

| Bagian Kode | Fungsi |
|---|---|
| `CREATE OR REPLACE FUNCTION` | Membuat atau mengganti fungsi trigger. |
| `RETURNS TRIGGER` | Menandakan fungsi digunakan oleh trigger. |
| `NEW` | Mengakses data transaksi yang baru dimasukkan. |
| `SELECT ... FOR UPDATE` | Mengunci baris barang selama transaksi berlangsung. |
| `CASE` | Menentukan perubahan stok berdasarkan jenis transaksi. |
| `RAISE EXCEPTION` | Menolak transaksi apabila kuantitas tidak valid, barang tidak ditemukan, atau stok menjadi negatif. |
| `UPDATE inventory_items` | Memperbarui stok di database. |
| `AFTER INSERT` | Menjalankan fungsi setelah baris transaksi dimasukkan. |

> **Catatan penting mengenai nama fungsi:** soal meminta fungsi bernama `trg_update_stock_and_journal()`, tetapi struktur tabel yang diberikan belum mempunyai tabel jurnal akuntansi maupun informasi akun debit-kredit. Karena itu, kode di atas benar-benar memperbarui stok, tetapi belum menghasilkan jurnal akuntansi. Untuk membuat jurnal otomatis, diperlukan tambahan struktur jurnal dan pemetaan akun. Jangan mengklaim bahwa jurnal sudah tercatat jika tabel dan logika pencatatannya belum dibuat.

Kuantitas `ADJUSTMENT` pada implementasi ini menggunakan tanda **positif** untuk penambahan dan **negatif** untuk pengurangan stok. Konvensi ini perlu dijelaskan karena naskah ujian tidak menetapkan bagaimana kuantitas penyesuaian harus direpresentasikan.

---

## 2. Penanganan Concurrency

### 2.1. Apa Masalahnya?

Misalnya stok barang hanya tersisa 1 unit, lalu dua kasir memproses penjualan masing-masing 1 unit hampir bersamaan. Tanpa penguncian yang benar, kedua kasir berpotensi membaca stok awal yang sama, sehingga total penjualan menjadi 2 unit meskipun stok hanya 1 unit. Kondisi ini disebut **overselling**.

### 2.2. Solusi Menggunakan `SELECT ... FOR UPDATE`

`SELECT ... FOR UPDATE` mengunci baris barang yang sedang diproses. Transaksi lain yang ingin mengunci baris yang sama harus menunggu sampai transaksi pertama selesai.

Jika stok awal hanya 1 unit:

1. Kasir A mendapatkan kunci baris dan memproses penjualan.
2. Kasir B menunggu karena baris barang sedang dikunci.
3. Setelah Kasir A melakukan `COMMIT`, Kasir B membaca stok terbaru ketika memperoleh kunci.
4. Jika stok sudah 0, trigger menjalankan `RAISE EXCEPTION` dan transaksi Kasir B dibatalkan.

Kode contoh ini mengasumsikan aplikasi memeriksa hasil pembacaan stok sebelum melakukan `INSERT`. Trigger tetap menjadi pengendali utama yang mencegah stok negatif, sehingga validasi tidak hanya bergantung pada aplikasi.

> **Penting:** penguncian harus berlangsung dalam transaksi yang sama dengan proses penjualan. Jika penguncian dilepas sebelum penjualan diproses, perlindungannya tidak memadai.

### 2.3. Alternatif Menggunakan Isolasi `SERIALIZABLE`

Alternatif lainnya adalah menjalankan transaksi pada tingkat isolasi `SERIALIZABLE`. Pada tingkat isolasi ini, PostgreSQL memastikan transaksi yang berhasil dapat diperlakukan seolah-olah berjalan dalam urutan serial. Jika terjadi konflik, salah satu transaksi dapat gagal dengan *serialization error* dan harus diulang oleh aplikasi.

Walaupun demikian, `SERIALIZABLE` bukan pengganti penanganan error. Aplikasi harus siap mengulang transaksi yang gagal. Dalam kasus persediaan sederhana, `SELECT ... FOR UPDATE` pada baris barang yang tepat merupakan pendekatan langsung untuk mengendalikan akses bersamaan.

### 2.4. Perbandingan Kedua Metode

| Aspek | `SELECT ... FOR UPDATE` | `SERIALIZABLE` |
|---|---|---|
| **Cara kerja** | Mengunci baris tertentu | Mengendalikan konflik berdasarkan isolasi serial |
| **Keunggulan** | Efisien untuk mengamankan stok barang tertentu | Memberikan jaminan isolasi transaksi yang lebih ketat |
| **Konsekuensi** | Transaksi lain yang membutuhkan baris terkunci harus menunggu | Transaksi dapat gagal dan perlu diulang |
| **Penerapan** | Cocok untuk transaksi stok dengan item tertentu | Cocok ketika aturan transaksi lebih kompleks |

---

## 3. DDL SQL (PostgreSQL)

Bagian ini melengkapi catatan pada bagian 1.2: struktur tabel persediaan belum memiliki tabel jurnal akuntansi maupun informasi akun debit-kredit. DDL berikut menyediakan struktur tersebut, yaitu `chart_of_accounts`, `journal_headers`, dan `journal_lines`.

> **Catatan:** DDL ini baru membuat struktur tabel. Validasi total debit sama dengan total kredit (`Σ Debit = Σ Kredit`) belum ada di dalamnya dan perlu ditambahkan melalui *stored procedure* atau *constraint trigger* pada proses posting jurnal.

```sql
-- =========================================
-- 1. TABEL CHART OF ACCOUNTS
-- =========================================

CREATE TABLE chart_of_accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    account_code VARCHAR(20) NOT NULL UNIQUE,

    account_name VARCHAR(100) NOT NULL,

    normal_balance VARCHAR(6) NOT NULL
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),

    report_classification VARCHAR(20) NOT NULL
        CHECK (
            report_classification IN (
                'ASET',
                'LIABILITAS',
                'EKUITAS',
                'PENDAPATAN',
                'BEBAN'
            )
        )
);


-- =========================================
-- 2. TABEL JOURNAL HEADERS
-- =========================================

CREATE TABLE journal_headers (
    header_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    transaction_date DATE NOT NULL,

    reference_no VARCHAR(50) NOT NULL UNIQUE,

    description TEXT NOT NULL,

    posting_status VARCHAR(10) NOT NULL
        DEFAULT 'DRAFT'
        CHECK (posting_status IN ('DRAFT', 'POSTED'))
);


-- =========================================
-- 3. TABEL JOURNAL LINES
-- =========================================

CREATE TABLE journal_lines (
    line_id BIGINT GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    header_id BIGINT NOT NULL,

    account_id BIGINT NOT NULL,

    debit NUMERIC(15, 2) NOT NULL DEFAULT 0
        CHECK (debit >= 0),

    credit NUMERIC(15, 2) NOT NULL DEFAULT 0
        CHECK (credit >= 0),

    -- Mencegah debit dan kredit sama-sama nol
    CONSTRAINT chk_journal_amount
        CHECK (debit > 0 OR credit > 0),

    -- Relasi ke tabel journal_headers
    CONSTRAINT fk_journal_header
        FOREIGN KEY (header_id)
        REFERENCES journal_headers(header_id)
        ON DELETE RESTRICT,

    -- Relasi ke tabel chart_of_accounts
    CONSTRAINT fk_journal_account
        FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts(account_id)
        ON DELETE RESTRICT
);
```

### 3.1. Ringkasan Tabel

| Tabel | Primary Key | Kolom Penting |
|---|---|---|
| `chart_of_accounts` | `account_id` | `account_code` (unik), `account_name`, `normal_balance` (`DEBIT`/`CREDIT`), `report_classification` (`ASET`, `LIABILITAS`, `EKUITAS`, `PENDAPATAN`, `BEBAN`) |
| `journal_headers` | `header_id` | `transaction_date`, `reference_no` (unik), `description`, `posting_status` (`DRAFT`/`POSTED`, default `DRAFT`) |
| `journal_lines` | `line_id` | `header_id` (FK), `account_id` (FK), `debit`, `credit` |

### 3.2. Constraint pada `journal_lines`

| Constraint | Fungsi |
|---|---|
| `CHECK (debit >= 0)` dan `CHECK (credit >= 0)` | Mencegah nilai nominal negatif. |
| `chk_journal_amount` | Menolak baris jika debit dan kredit sama-sama nol. |
| `fk_journal_header` | `header_id` harus mengacu pada jurnal yang sudah ada. |
| `fk_journal_account` | `account_id` harus mengacu pada akun yang sudah terdaftar. |
| `ON DELETE RESTRICT` | Header atau akun tidak dapat dihapus selama masih direferensikan oleh baris jurnal. |
