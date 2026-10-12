BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO inventory_transactions
    (item_id, trx_type, qty)
VALUES
    ('BRG001', 'SALE', 1);

COMMIT;