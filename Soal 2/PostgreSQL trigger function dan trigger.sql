-- =========================================
-- 1. TRIGGER FUNCTION
-- =========================================

CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INT;
    v_change INT;
BEGIN
    -- PURCHASE dan SALE menggunakan qty positif.
    IF NEW.trx_type IN ('PURCHASE', 'SALE')
       AND NEW.qty <= 0 THEN
        RAISE EXCEPTION
            'Quantity untuk PURCHASE/SALE harus positif';
    END IF;

    -- ADJUSTMENT menggunakan qty bertanda:
    -- positif = menambah stok, negatif = mengurangi stok.
    IF NEW.trx_type = 'ADJUSTMENT'
       AND NEW.qty = 0 THEN
        RAISE EXCEPTION
            'Quantity ADJUSTMENT tidak boleh nol';
    END IF;

    -- Mengunci baris barang agar transaksi bersamaan
    -- untuk item yang sama diproses secara bergiliran.
    SELECT stock_qty
    INTO v_stock
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Barang dengan ID % tidak ditemukan',
            NEW.item_id;
    END IF;

    -- Menentukan perubahan stok.
    CASE NEW.trx_type
        WHEN 'PURCHASE' THEN
            v_change := NEW.qty;

        WHEN 'SALE' THEN
            v_change := -NEW.qty;

        WHEN 'ADJUSTMENT' THEN
            v_change := NEW.qty;

        ELSE
            RAISE EXCEPTION
                'Jenis transaksi tidak valid: %',
                NEW.trx_type;
    END CASE;

    -- Mencegah stok menjadi negatif.
    IF v_stock + v_change < 0 THEN
        RAISE EXCEPTION
            'Stok tidak mencukupi. Stok saat ini: %, perubahan: %',
            v_stock, v_change;
    END IF;

    -- Memperbarui stok secara otomatis.
    UPDATE inventory_items
    SET stock_qty = stock_qty + v_change
    WHERE item_id = NEW.item_id;

    RETURN NEW;
END;
$$;


-- =========================================
-- 2. TRIGGER
-- =========================================

CREATE TRIGGER trg_inventory_transaction_insert
AFTER INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_and_journal();