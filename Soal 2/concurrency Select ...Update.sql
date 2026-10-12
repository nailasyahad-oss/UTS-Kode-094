BEGIN;

-- Mengunci baris barang yang akan dijual.
SELECT stock_qty
FROM inventory_items
WHERE item_id = 'BRG001'
FOR UPDATE;

-- Aplikasi memeriksa stok yang tersedia.
-- Jika stok mencukupi, masukkan transaksi penjualan.
INSERT INTO inventory_transactions
    (item_id, trx_type, qty)
VALUES
    ('BRG001', 'SALE', 1);

-- Trigger akan memvalidasi stok dan memperbaruinya.
COMMIT;