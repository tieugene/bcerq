-- m.tx.p
ALTER TABLE tx DROP CONSTRAINT IF EXISTS tx_pkey;
DROP INDEX IF EXISTS idx_tx_b_id;
